import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:summer/models/chat_message.dart';
import 'package:summer/models/character_card.dart';
import 'package:summer/models/chat_session.dart';
import 'package:summer/models/tool.dart';
import 'package:summer/services/api_service.dart';
import 'package:summer/services/storage_service.dart';
import 'package:summer/services/voice_service.dart';
import 'package:summer/services/tools_service.dart';

// 导入重构后的组件
import 'package:summer/chat/tool_call_handler.dart';
import 'package:summer/chat/message_processor.dart';
import 'package:summer/chat/stream_response_result.dart';
import 'package:summer/chat/refresh_counter_manager.dart';
import 'package:summer/chat/special_command_handler.dart';
import 'package:summer/chat/version_group_manager.dart';

class CharacterChatController extends ChangeNotifier {
  final int characterCardId;

  CharacterCard? _characterCard;
  ChatSession? _chatSession;
  List<ChatMessage> _messages = [];           // 存储所有消息（包括未选中版本）
  bool _isLoading = true;
  bool _isGenerating = false;
  bool _dateFormatInitialized = false;

  // 管理器实例
  late MessageProcessor _messageProcessor;
  late ToolCallHandler _toolCallHandler;
  late RefreshCounterManager _refreshCounterManager;
  late SpecialCommandHandler _specialCommandHandler;
  late VersionGroupManager _versionGroupManager;
  
  // 当前工具会话
  ToolSession? _currentToolSession;
  ChatMessage? _currentAggregatedMessage;

  CharacterChatController({required this.characterCardId});

  // ============= 公开 Getters =============
  CharacterCard? get characterCard => _characterCard;
  
  /// 返回用于UI显示的消息列表（每个版本组只显示选中的版本，且隐藏内部工具消息）
  List<ChatMessage> get messages {
    // 1. 找出所有未隐藏的消息
    final visibleMessages = _messages.where((m) => m.isHidden != true).toList();
    
    // 2. 按版本组分组，只保留 isChosen == true 的消息
    final Map<String?, ChatMessage> chosenPerGroup = {};
    for (final msg in visibleMessages) {
      final groupId = msg.versionGroup;
      if (groupId == null || !msg.isChosen) continue;
      chosenPerGroup[groupId] = msg;
    }
    
    // 3. 构建最终显示列表：无版本组消息 + 每个版本组选中的消息
    final displayList = <ChatMessage>[];
    for (final msg in visibleMessages) {
      if (msg.versionGroup == null) {
        displayList.add(msg);
      } else if (chosenPerGroup.containsKey(msg.versionGroup) && 
                 chosenPerGroup[msg.versionGroup] == msg) {
        displayList.add(msg);
      }
    }
    
    // 4. 按时间排序
    displayList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List.unmodifiable(displayList);
  }
  
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  bool get dateFormatInitialized => _dateFormatInitialized;

  /// 获取特定版本组的所有消息（包括未选中的），用于版本导航
  List<ChatMessage> getVersionsForGroup(String groupId) {
    return _messages
        .where((m) => m.versionGroup == groupId)
        .toList()
      ..sort((a, b) => a.versionOrder.compareTo(b.versionOrder));
  }

  // ============= 初始化 =============
  Future<void> initialize() async {
    await Future.wait([
      _initializeDateFormatting(),
      _loadSessionAndMessages(),
    ]);
  }

  Future<void> _initializeDateFormatting() async {
    _dateFormatInitialized = true;
    notifyListeners();
  }

  Future<void> _loadSessionAndMessages() async {
    try {
      _characterCard = await IsarStorageService.getCharacterCardById(characterCardId);
      _chatSession = _characterCard!.session.value;
      _messages = await IsarStorageService.getMessages(_chatSession!.id);
      
      _initManagers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initManagers() {
    _messageProcessor = MessageProcessor(
      session: _chatSession!,
      characterCard: _characterCard!,
      messages: _messages,
    );
    
    _toolCallHandler = ToolCallHandler(
      session: _chatSession!,
      onMessageAdded: _saveAndAddMessage,
      onNotifyListeners: notifyListeners,
      onToolSessionUpdate: _updateToolSession,
    );
    
    _refreshCounterManager = RefreshCounterManager(
      characterCard: _characterCard!,
    );
    
    _specialCommandHandler = SpecialCommandHandler(
      session: _chatSession!,
      characterCard: _characterCard!,
      onMessageAdded: _saveAndAddMessage,
      onGenerateResponse: _generateResponseWithoutSave,
      onCharacterCardUpdated: updateCharacterCard, // 新增
    );
    
    _versionGroupManager = VersionGroupManager(
      sessionId: _chatSession!.id,
      messages: _messages,
    );
  }

  // ============= 消息操作 =============
  Future<void> loadMessages() async {
    if (_isLoading) return;
    await _performWithLoadingState(() async {
      _messages = await IsarStorageService.getMessages(_chatSession!.id);
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    await _cleanupUnusedVersions();
    
    if (await _specialCommandHandler.handleCommand(text)) {
      // 重新读取角色卡
      loadMessages();
      notifyListeners();
      return;
    }
    
    await _performWithGeneratingState(() async {
      await _saveUserMessage(text);
      await _checkAndHandleRefresh();
      await _generateResponse();  // 新消息使用新的版本组
    });
  }

  Future<void> sendImageMessage(List<Map<String, dynamic>> contentList) async {
    if (contentList.isEmpty) return;
    
    await _performWithGeneratingState(() async {
      final contentJson = jsonEncode(contentList);
      await _saveUserMessage(contentJson, isImage: true);
      await _generateResponse();
    });
  }

  /// 重新生成最后一条助手消息（支持工具会话聚合消息）
  Future<void> regenerateLastMessage() async {
    final lastAssistant = _getLastAssistantMessage();
    final lastUser = _getLastUserMessage();
    if (lastAssistant == null) return;

    // 如果最后一条是用户消息（异常情况），直接生成新回复
    if (lastUser != null && lastUser.timestamp.isAfter(lastAssistant.timestamp)) {
      await _performWithGeneratingState(() async {
        await _checkAndHandleRefresh();
        await _generateResponse();
      });
      return;
    }

    // 确定版本组ID和新的版本序号
    var groupId = lastAssistant.versionGroup;
    if (groupId == null) {
      // 第一次重新生成时，为旧消息创建版本组
      groupId = _versionGroupManager.createGroupId();
      lastAssistant.versionGroup = groupId;
      lastAssistant.versionOrder = 0;
      await IsarStorageService.updateMessage(lastAssistant);
    }
    final nextVersionOrder = lastAssistant.versionOrder + 1;
    
    // 将旧版本标记为非选中（包括同组内所有隐藏消息）
    await _versionGroupManager.markVersionUnchosen(groupId);
    
    // 开始重新生成（会创建新版本）
    await _performWithGeneratingState(() async {
      await _generateResponse(
        versionGroup: groupId,
        versionOrder: nextVersionOrder,
      );
    });
  }

  /// 切换消息版本（支持工具会话聚合消息及其关联的隐藏消息）
  Future<void> chooseVersion(ChatMessage message) async {
    // VersionGroupManager 会处理同组所有消息（包括隐藏消息）的 isChosen 状态
    await _versionGroupManager.chooseVersion(message);
    // 刷新 UI（messages getter 会自动过滤出新的选中版本）
    notifyListeners();
  }

  Future<void> handleRollback(ChatMessage targetMessage) async {
    await IsarStorageService.deleteMessagesAfter(
      _chatSession!.id, 
      targetMessage.timestamp,
    );
    await _loadSessionAndMessages();
  }

  // ============= 工具会话管理（支持版本） =============
  void _startToolSession({String? versionGroup, int? versionOrder}) {
    _currentToolSession = ToolSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      chatSessionId: _chatSession!.id.toString(),
      startTime: DateTime.now(),
      status: ToolSessionStatus.executing,
    );
    
    // 创建聚合消息，并设置版本信息
    _currentAggregatedMessage = ToolsService.createToolSessionMessage(
      sessionId: _chatSession!.id.toString(),
      toolSession: _currentToolSession!,
    );
    _currentAggregatedMessage!.versionGroup = versionGroup;
    _currentAggregatedMessage!.versionOrder = versionOrder ?? 0;
    _currentAggregatedMessage!.isChosen = true;   // 新版本默认选中
    _currentAggregatedMessage!.isHidden = false;

    _messages.add(_currentAggregatedMessage!);
    notifyListeners();
  }
  
  Future<void> _updateToolSession(ToolSession toolSession) async {
    _currentToolSession = toolSession;
    if (_currentAggregatedMessage != null) {
      ToolsService.updateToolSessionMessage(_currentAggregatedMessage!, toolSession);
      await IsarStorageService.saveMessage(_currentAggregatedMessage!);
      notifyListeners();
    }
  }

  Future<void> _updateToolSessionUI() async {
    if (_currentAggregatedMessage != null) {
      ToolsService.updateToolSessionMessage(_currentAggregatedMessage!, _currentToolSession!);
    }
  }
  
  Future<void> _completeToolSession(String? finalContent) async {
    if (_currentToolSession == null) return;
    
    if (finalContent != null && finalContent.isNotEmpty) {
      _currentToolSession!.complete(finalContent);
    } else {
      _currentToolSession!.complete(_currentAggregatedMessage?.content ?? '');
    }
    
    if (_currentAggregatedMessage != null) {
      ToolsService.updateToolSessionMessage(_currentAggregatedMessage!, _currentToolSession!);
      await IsarStorageService.saveMessage(_currentAggregatedMessage!);
    }
    
    _currentToolSession = null;
    _currentAggregatedMessage = null;
  }
  
  Future<void> _cancelToolSession() async {
    if (_currentToolSession == null) return;
    
    _currentToolSession!.cancel();
    if (_currentAggregatedMessage != null) {
      ToolsService.updateToolSessionMessage(_currentAggregatedMessage!, _currentToolSession!);
      await IsarStorageService.saveMessage(_currentAggregatedMessage!);
    }
    
    _currentToolSession = null;
    _currentAggregatedMessage = null;
  }

  // ============= 核心生成逻辑（支持版本组） =============
  Future<void> _generateResponse({String? versionGroup, int? versionOrder}) async {
    // 确定版本组ID：若未传入则创建新组
    final effectiveGroupId = versionGroup ?? _versionGroupManager.createGroupId();
    final effectiveVersionOrder = versionOrder ?? 0;
    
    // 开始工具会话，传入版本信息
    _startToolSession(
      versionGroup: effectiveGroupId,
      versionOrder: effectiveVersionOrder,
    );
    
    try {
      final session = _chatSession!;
      if (_characterCard != null) {
        session.characterCard = _characterCard;
      }
      
      String accumulatedFinalContent = '';
      
      for (int round = 0; round < ToolCallHandler.maxToolCallRounds; round++) {
        developer.log('=' * 50, name: 'GenerateResponse');
        developer.log('第 ${round + 1} 轮, 版本组: $effectiveGroupId', name: 'GenerateResponse');
        
        // 获取用于API的上下文（只包含当前选中的版本）
        final contextMessages = await _getContextMessagesForApi();
        final enabledTools = await ToolsService.getEnabledToolsForSession(_chatSession!.id.toString());
        
        final stream = ApiService.sendMessageStream(
          messages: contextMessages,
          session: session,
          tools: enabledTools,
        );

        final result = await _processStreamResponse(stream, round);
        
        if (result.aiContent.isNotEmpty) {
          accumulatedFinalContent = result.aiContent;
          if (_currentAggregatedMessage != null) {
            _currentAggregatedMessage!.content = accumulatedFinalContent;
            notifyListeners();
          }
        }
        
        // 若无工具调用，结束生成
        if (!result.hasToolCalls) {
          await _completeToolSession(accumulatedFinalContent);
          if (_characterCard?.autoReadReply == true && accumulatedFinalContent.isNotEmpty) {
            VoiceService().textToSpeech(accumulatedFinalContent, _currentAggregatedMessage?.id ?? '');
          }
          break;
        }
        
        // 处理工具调用，传入版本组ID，使内部消息继承同一版本组
        final success = await _toolCallHandler.handleToolCalls(
          toolCalls: result.toolCalls,
          toolSession: _currentToolSession!,
          roundNumber: round,
          intermediateThinking: result.intermediateThinking,  // 传递AI的中间思考内容
        );
        
        if (!success) {
          await _completeToolSession(accumulatedFinalContent.isEmpty ? '工具调用失败' : accumulatedFinalContent);
          break;
        }
      }
      
      if (_currentToolSession != null && _currentToolSession!.status == ToolSessionStatus.executing) {
        await _completeToolSession(accumulatedFinalContent.isEmpty ? '已达到最大工具调用次数' : accumulatedFinalContent);
      }
      
    } catch (e) {
      developer.log('生成响应错误: $e', name: 'GenerateResponse', error: e);
      await _cancelToolSession();
      _handleError(e);
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
  
  /// 获取用于API调用的上下文消息（基于当前选中的版本）
  Future<List<ChatMessage>> _getContextMessagesForApi() async {
    // 从数据库获取所有消息
    final allMessages = await IsarStorageService.getMessages(_chatSession!.id);
    
    // 过滤：排除 notice 消息，但保留隐藏的工具消息
    var filtered = allMessages.where((msg) => msg.role != 'notice').toList();
    
    // 应用版本选择逻辑：每个版本组只保留 isChosen == true 的消息
    final Map<String?, ChatMessage> chosenPerGroup = {};
    for (final msg in filtered) {
      final groupId = msg.versionGroup;
      if (groupId == null) continue;
      if (msg.isChosen) {
        chosenPerGroup[groupId] = msg;
      }
    }
    
    final contextList = <ChatMessage>[];
    for (final msg in filtered) {
      if (msg.versionGroup == null) {
        contextList.add(msg);   // 无版本组的消息全部保留
      } else if (chosenPerGroup.containsKey(msg.versionGroup) && 
                 chosenPerGroup[msg.versionGroup] == msg) {
        contextList.add(msg);   // 只保留选中的版本消息
      }
    }
    
    // 按时间排序并截取最近的消息
    contextList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (contextList.length > _chatSession!.maxContextLength) {
      return contextList.sublist(contextList.length - _chatSession!.maxContextLength);
    }
    return contextList;
  }

  Future<StreamResponseResult> _processStreamResponse(
    Stream stream, 
    int round,
  ) async {
    var result = StreamResponseResult.initial();
    String accumulatedContent = '';
    String accumulatedThinking = '';  // 新增：累积思考内容
    final Map<String, ToolCall> accumulatedToolCalls = {};

    await for (final response in stream) {
      if (response.content != null && response.content!.isNotEmpty) {
        accumulatedContent += response.content!;
        accumulatedThinking = accumulatedContent;//thinkingMatches.last.group(1)?.trim() ?? '';
        
        if (_currentAggregatedMessage != null) {
          _currentToolSession!.finalContent = accumulatedContent;
          _currentAggregatedMessage!.content = accumulatedContent;
          _updateToolSessionUI(); // 实时更新工具会话消息内容
          notifyListeners();
        }
      }
      
      if (response.toolCalls != null) {
        for (var toolCall in response.toolCalls!) {
          if (!accumulatedToolCalls.containsKey(toolCall.id)) {
            accumulatedToolCalls[toolCall.id] = ToolCall(
              id: toolCall.id,
              name: toolCall.name,
              arguments: StringBuffer(),
            );
          }
          if (toolCall.arguments != null && toolCall.arguments.isNotEmpty) {
            (accumulatedToolCalls[toolCall.id]!.arguments as StringBuffer)
                .write(toolCall.arguments);
          }
        }
      }
    }

    final finalToolCalls = accumulatedToolCalls.values.map((tc) {
      final args = tc.arguments is StringBuffer 
          ? (tc.arguments as StringBuffer).toString()
          : tc.arguments;
      return ToolCall(id: tc.id, name: tc.name, arguments: args);
    }).toList();
    
    if (finalToolCalls.isNotEmpty && accumulatedContent.isEmpty) {
      result = result.copyWith(
        hasToolCalls: true, 
        toolCalls: finalToolCalls,
        intermediateThinking: accumulatedThinking.isNotEmpty ? accumulatedThinking : null,
      );
    } else if (finalToolCalls.isNotEmpty && accumulatedContent.isNotEmpty) {
      result = result.copyWith(
        hasToolCalls: true,
        toolCalls: finalToolCalls,
        aiContent: accumulatedContent,
        intermediateThinking: accumulatedThinking.isNotEmpty ? accumulatedThinking : null,
      );
    } else {
      result = result.copyWith(
        hasToolCalls: false,
        aiContent: accumulatedContent,
        intermediateThinking: accumulatedThinking.isNotEmpty ? accumulatedThinking : null,
      );
    }
    
    if (result.toolCalls.isNotEmpty) {
      sleep(const Duration(milliseconds: 500));
    }
    
    return result;
  }

  // 无保存的生成（用于特殊命令，保持原有逻辑）
  Future<String> _generateResponseWithoutSave(String text) async {
    try {
      final session = _chatSession!;
      session.characterCard = _characterCard;
      
      final userMsg = ChatMessage.createSystemMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _chatSession!.id,
        content: text,
      );
      _messages.add(userMsg);
      notifyListeners();

      final contextMessages = _messageProcessor.getContextMessages(session.maxContextLength);
      final stream = ApiService.sendMessageStream(
        messages: contextMessages,
        session: session,
      );

      String aiContent = '';
      ChatMessage? aiMessage;

      await for (final response in stream) {
        if (response.content != null) {
          aiContent += response.content!;
          if (aiMessage == null) {
            aiMessage = _createAssistantMessage(aiContent, 0);
            _messages.add(aiMessage);
          } else {
            aiMessage.content = aiContent;
          }
          notifyListeners();
        }
      }
      return aiContent;
    } catch (e) {
      developer.log('生成响应失败: $e', name: 'GenerateWithoutSave', error: e);
      return 'Error: ${e.toString()}';
    }
  }

  // ============= 辅助方法 =============
  ChatMessage? _getLastAssistantMessage() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].role == 'assistant') return _messages[i];
    }
    return null;
  }
  
  ChatMessage? _getLastUserMessage() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].role == 'user') return _messages[i];
    }
    return null;
  }

  Future<void> updateCharacterCard(CharacterCard card) async {
    _characterCard = card;
    if (_chatSession != null) {
      _refreshCounterManager = RefreshCounterManager(characterCard: card);
      _specialCommandHandler = SpecialCommandHandler(
        session: _chatSession!,
        characterCard: card,
        onMessageAdded: _saveAndAddMessage,
        onGenerateResponse: _generateResponseWithoutSave,
      );
    }
    await IsarStorageService.saveCharacterCard(card);
    notifyListeners();
  }

  Future<void> _saveUserMessage(String content, {bool isImage = false}) async {
    final userMsg = ChatMessage.createUserMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _chatSession!.id,
      content: isImage ? content : '{time:${DateTime.now()},\ntext:$content}',
    );
    await IsarStorageService.saveMessage(userMsg);
    _messages.add(userMsg);
    notifyListeners();
  }

  Future<void> _saveAndAddMessage(ChatMessage message) async {
    _messages.add(message);
    await IsarStorageService.saveMessage(message);
    notifyListeners();
  }

  ChatMessage _createAssistantMessage(String content, int round) {
    return ChatMessage.createAssistantMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_$round',
      sessionId: _chatSession!.id,
      content: content,
    );
  }

  Future<void> _checkAndHandleRefresh() async {
    final needsRefresh = await _refreshCounterManager.checkAndUpdateCount();
    if (needsRefresh) {
      await _specialCommandHandler.handleCommand(
        SpecialCommands.refreshShortMemory.primaryCommand
      );
    }
  }

  Future<void> _cleanupUnusedVersions() async {
    final toRemove = await _versionGroupManager.cleanupUnusedVersions();
    if (toRemove.isNotEmpty) {
      _messages.removeWhere((m) => toRemove.contains(m));
      notifyListeners();
    }
  }

  void _handleError(dynamic error) {
    developer.log('系统错误: $error', name: 'CharacterChatController', error: error);
    final errorMsg = ChatMessage.createNoticeMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _chatSession!.id,
      content: "系统错误：${error.toString()}",
    );
    _messages.add(errorMsg);
    IsarStorageService.saveMessage(errorMsg);
    notifyListeners();
  }

  // ============= 状态管理 =============
  Future<void> _performWithLoadingState(Future<void> Function() action) async {
    _isLoading = true;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _performWithGeneratingState(Future<void> Function() action) async {
    _isGenerating = true;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      _handleError(e);
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> setGenerating(bool value) async {
    _isGenerating = value;
    notifyListeners();
  }

  Map<String, int> getVersionInfo(ChatMessage message) {
    return _messageProcessor.getVersionInfo(message);
  }
}