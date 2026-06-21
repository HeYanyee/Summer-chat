import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/chat_message.dart';
import '../../models/chat_session.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class ChatController extends ChangeNotifier {
  final int sessionId;

  ChatSession? _session;
  List<ChatMessage> messages = [];
  bool isLoading = true;
  bool isGenerating = false;
  bool dateFormatInitialized = false;

  ChatController({
    required this.sessionId,
  });

  ChatSession? get session => _session;

  Future<void> initialize() async {
    await _initializeDateFormatting();
    await _loadSessionAndMessages();
  }

  Future<void> _initializeDateFormatting() async {
    // 日期格式化初始化
    dateFormatInitialized = true;
    notifyListeners();
  }

  set session(ChatSession? s) {
    _session = s;
    notifyListeners();
  }

  Future<void> _loadSessionAndMessages() async {
    try {
      _session = await IsarStorageService.getSession(sessionId);
      messages = await IsarStorageService.getMessages(sessionId);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages() async {
    if (isLoading) return; // 如果正在加载，则不执行
    isLoading = true;
    notifyListeners();
    
    try {
      messages = await IsarStorageService.getMessages(sessionId);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    // 清理上一版本组中未选定的候选
    await _cleanupUnusedVersions();

    isGenerating = true;
    notifyListeners();

    try {
      final userMsg = ChatMessage()
        ..id = DateTime.now().millisecondsSinceEpoch.toString()
        ..sessionId = sessionId
        ..content = text
        ..role = 'user'
        ..timestamp = DateTime.now();
      
      await IsarStorageService.saveMessage(userMsg);
      messages.add(userMsg);
      notifyListeners();

      await _generateResponse();
    } catch (e) {
      _handleError(e);
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> sendImageMessage(List<Map<String, dynamic>> contentList) async {
    if (contentList.isEmpty) return;

    // 清理上一版本组未选中的候选
    await _cleanupUnusedVersions();

    isGenerating = true;
    notifyListeners();

    try {
      // 将结构化内容转换为JSON字符串存储
      final String contentJson = jsonEncode(contentList);

      final userMsg = ChatMessage()
        ..id = DateTime.now().millisecondsSinceEpoch.toString()
        ..sessionId = sessionId
        ..content = contentJson  // 存储为JSON字符串
        ..role = 'user'
        ..timestamp = DateTime.now();
      
      await IsarStorageService.saveMessage(userMsg);
      messages.add(userMsg);
      notifyListeners();

      await _generateResponse();  // 复用原有的响应生成逻辑
    } catch (e) {
      _handleError(e);
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> _generateResponse() async {
    try {
      if(_session!.character!=null){
        _session!.characterCard = await IsarStorageService.searchCharacterCard(_session!.character!);
      }
      final contextMessages = _getContextMessages(_session!.maxContextLength);
      final stream = ApiService.sendMessageStream(
        messages: contextMessages,
        session: _session!,
      );

      String aiContent = '';
      ChatMessage? aiMessage;

      await for (final response in stream) {
        if (response.content != null) {
          aiContent += response.content!;
          if (aiMessage == null) {
            aiMessage = ChatMessage()
              ..id = '${DateTime.now().millisecondsSinceEpoch}'
              ..sessionId = sessionId
              ..role = 'assistant'
              ..content = aiContent
              ..timestamp = DateTime.now();
            messages.add(aiMessage); // add immediately
          } else {
            aiMessage.content = aiContent;
          }
        }
        notifyListeners();
      }

      if (aiMessage != null) await IsarStorageService.saveMessage(aiMessage);  //save时也会更新lastMsgContent
    } catch (e) {
      _handleError(e);
    }
  }

  List<ChatMessage> _getContextMessages(int maxContextLength) {
    // Include assistant_reasoning only when its associated assistant message
    // is included.  Afterwards merge reasoning entries so the provider sees
    // a unified content field.  This keeps old chats compatible.
    final raw = messages.where((msg) => msg.role != 'notice').toList();
    final List<ChatMessage> filtered = [];

    for (var i = 0; i < raw.length; i++) {
      final msg = raw[i];
      if (msg.role == 'assistant_reasoning') {
        ChatMessage? prevAssistant;
        for (var j = i - 1; j >= 0; j--) {
          if (raw[j].role == 'assistant') {
            prevAssistant = raw[j];
            break;
          }
        }
        if (prevAssistant == null) continue;
        if (prevAssistant.versionGroup == null || prevAssistant.isChosen) filtered.add(msg);
      } else {
        if (msg.versionGroup == null || msg.isChosen) filtered.add(msg);
      }
    }

    final List<ChatMessage> merged = [];
    for (var msg in filtered) {
      if (msg.role == 'assistant_reasoning' && merged.isNotEmpty && merged.last.role == 'assistant') {
        merged.last.content = merged.last.content + msg.content;
      } else {
        merged.add(msg);
      }
    }

    final startIndex = merged.length > maxContextLength
        ? merged.length - maxContextLength
        : 0;

    return merged.sublist(startIndex);
  }

  Future<void> regenerateLastMessage() async {
    if (messages.isEmpty) return;

    // 找到最后一条助手回答
    ChatMessage? lastAi;
    try {
      lastAi = messages.lastWhere((m) => m.role == 'assistant');
    } catch (_) {
      lastAi = null;
    }
    if (lastAi == null) return;

    // 创建或使用现有组ID
    final groupId = lastAi.versionGroup ?? '${sessionId}_${DateTime.now().millisecondsSinceEpoch}';
    // 标记旧版本为非选中
    lastAi.versionGroup = groupId;
    lastAi.versionOrder = 0;
    lastAi.isChosen = false;
    await IsarStorageService.updateMessage(lastAi);

    // 新建占位消息用于显示流
    final newMsg = ChatMessage()
      ..id = DateTime.now().millisecondsSinceEpoch.toString()
      ..sessionId = sessionId
      ..role = 'assistant'
      ..content = ''
      ..timestamp = DateTime.now()
      ..versionGroup = groupId
      ..versionOrder = lastAi.versionOrder + 1
      ..isChosen = true;
    messages.add(newMsg);

    isGenerating = true;
    notifyListeners();
    try {
      // 直接使用已有 _generateResponse 流逻辑，但把 aiMessage/assistant_reasoning 替换为 newMsg/newReasoning
      if (_session!.character != null) {
        _session!.characterCard = await IsarStorageService.searchCharacterCard(_session!.character!);
      }
      final contextMessages = _getContextMessages(_session!.maxContextLength);
      final stream = ApiService.sendMessageStream(
        messages: contextMessages,
        session: _session!,
      );

      String aiContent = '';

      await for (final response in stream) {
        if (response.content != null) {
          aiContent += response.content!;
          newMsg.content = aiContent;
          notifyListeners();
        }
      }

      await IsarStorageService.saveMessage(newMsg);
    } catch (e) {
      _handleError(e);
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> setGenerating(bool value) async {
    isGenerating = value;
    notifyListeners();
  }

  /// 清除上一版本组中未被选中的候选
  Future<void> _cleanupUnusedVersions() async {
    if (messages.isEmpty) return;
    ChatMessage? lastAi;
    try {
      lastAi = messages.lastWhere((m) => m.role=='assistant' && m.versionGroup!=null);
    } catch (_) {
      lastAi = null;
    }
    if (lastAi == null) return;
    final group = lastAi.versionGroup!;
    final toRemove = messages.where((m) => m.versionGroup==group && !m.isChosen).toList();
    if (toRemove.isNotEmpty) {
      await IsarStorageService.deleteMessagesList(toRemove);
      messages.removeWhere((m) => toRemove.contains(m));
    }
  }

  /// 计算消息在版本组内的索引和总数（1-based）
  Map<String,int> getVersionInfo(ChatMessage msg) {
    if (msg.versionGroup == null) return {'index':0,'total':0};
    final siblings = messages.where((m)=>m.versionGroup==msg.versionGroup).toList();
    siblings.sort((a,b)=>a.versionOrder.compareTo(b.versionOrder));
    final idx = siblings.indexWhere((m)=>m.id==msg.id);
    return {
      'index': idx==-1 ? 0 : idx+1,
      'total': siblings.length,
    };
  }

  /// 选择指定版本
  Future<void> chooseVersion(ChatMessage msg) async {
    if (msg.versionGroup == null) return;
    final group = msg.versionGroup!;
    // Update both in-memory list and database without reloading everything. Reloading
    // was causing problems when our Isar schema didn't yet include the version
    // properties – after a reload the field would be null and our UI filter would
    // show all messages. By modifying the existing message objects we keep the
    // versionGroup/isChosen information intact and simply refresh the listeners.
    for (var m in messages.where((m) => m.versionGroup == group)) {
      m.isChosen = (m.id == msg.id);
      await IsarStorageService.updateMessage(m);
    }
    // notify UI to rebuild; messages list already updated in memory
    notifyListeners();
  }

  Future<void> handleRollback(ChatMessage targetMessage) async {
    await IsarStorageService.deleteMessagesAfter(
      sessionId, 
      targetMessage.timestamp,
    );
    await _loadSessionAndMessages();
  }

  void _handleError(dynamic error) {
    final errorMsg = ChatMessage()
        ..id = (DateTime.now().millisecondsSinceEpoch + 4).toString()
        ..sessionId = sessionId
        ..role = 'notice'
        ..content = "系统错误：${error.toString()}"
        ..timestamp = DateTime.now();
    
    messages.add(errorMsg);
    IsarStorageService.saveMessage(errorMsg);
    notifyListeners();
  }
}