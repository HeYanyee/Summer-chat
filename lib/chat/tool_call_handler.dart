import 'dart:convert';

import 'package:summer/models/chat_message.dart';
import 'package:summer/models/chat_session.dart';
import 'package:summer/models/tool.dart';
import 'package:summer/services/tools_service.dart';
import 'dart:developer' as developer;

class ToolCallHandler {
  static const int maxToolCallRounds = 5;
  
  final ChatSession session;
  final Future<void> Function(ChatMessage) onMessageAdded;
  final void Function() onNotifyListeners;
  
  // 新增：回调用于更新工具会话
  final Future<void> Function(ToolSession) onToolSessionUpdate;
  
  ToolCallHandler({
    required this.session,
    required this.onMessageAdded,
    required this.onNotifyListeners,
    required this.onToolSessionUpdate,  // 新增参数
  });
  
  /// 处理工具调用并返回是否成功执行
  /// 新版本：支持工具会话聚合，不创建单独的tool消息
  Future<bool> handleToolCalls({
    required List<ToolCall> toolCalls,
    required ToolSession toolSession,  // 新增：传入当前工具会话
    required int roundNumber,           // 新增：当前轮次编号
    String? intermediateThinking,       // 新增：AI的中间思考内容
    
    String? groupId,
    int? versionOrder,
  }) async {
    try {
      developer.log('=' * 30, name: 'ToolCallHandler');
      developer.log('开始处理第 $roundNumber 轮工具调用，数量: ${toolCalls.length}', name: 'ToolCallHandler');
      
      // 1. 解析并记录工具调用信息
      final toolCallInfos = <ToolCallInfo>[];
      
      for (var toolCall in toolCalls) {
        developer.log('处理工具调用:', name: 'ToolCallHandler');
        developer.log('  - id: ${toolCall.id}', name: 'ToolCallHandler');
        developer.log('  - name: ${toolCall.name}', name: 'ToolCallHandler');
        
        // 解析参数
        final args = _parseArguments(toolCall.arguments);
        developer.log('  - 解析后的参数: $args', name: 'ToolCallHandler');
        
        // 创建 ToolCallInfo
        final toolCallInfo = ToolCallInfo(
          id: toolCall.id,
          name: toolCall.name,
          arguments: args,
          executeTime: DateTime.now(),
        );
        toolCallInfos.add(toolCallInfo);
      }
      
      // 2. 创建 ToolRound 并添加到会话
      final toolRound = ToolRound(
        roundNumber: roundNumber,
        timestamp: DateTime.now(),
        toolCalls: toolCallInfos,
        results: [],
        intermediateThinking: intermediateThinking,  // 设置AI的中间思考内容
      );
      
      toolSession.addRound(toolRound);
      
      // 3. 更新UI（显示工具调用开始）
      await onToolSessionUpdate(toolSession);
      onNotifyListeners();
      
      // 4. 执行工具调用（并发执行以提高效率）
      developer.log('执行工具调用...', name: 'ToolCallHandler');
      
      final toolResponses = await _executeToolsConcurrently(toolCallInfos);
      
      // 5. 创建结果信息并更新 round
      final resultInfos = <ToolResultInfo>[];
      
      for (var i = 0; i < toolResponses.length; i++) {
        final response = toolResponses[i];
        final toolCallInfo = toolCallInfos[i];
        
        developer.log('工具响应:', name: 'ToolCallHandler');
        developer.log('  - 工具: ${toolCallInfo.name}', name: 'ToolCallHandler');
        developer.log('  - 成功: ${!response.isError}', name: 'ToolCallHandler');
        developer.log('  - 内容长度: ${response.content.length}', name: 'ToolCallHandler');
        
        // 解析结果内容
        final resultContent = _parseResultContent(response.content);
        
        final resultInfo = ToolResultInfo(
          toolCallId: response.toolCallId,
          result: resultContent,
          success: !response.isError,
          error: response.isError ? response.content : null,
          executionTime: Duration.zero, // TODO: 记录实际执行时间
        );
        resultInfos.add(resultInfo);
        
        // 可选：如果需要保留原始tool消息用于调试，可以创建隐藏消息
        if (_shouldKeepDebugMessages) {
          await _createHiddenToolMessage(response);
        }
      }
      
      // 更新 round 的结果
      toolRound.results = resultInfos;
      toolRound.duration = DateTime.now().difference(toolRound.timestamp);
      
      // 6. 将工具结果添加到上下文（创建内部消息，但不显示在UI）
      await _addToolResultsToContext(resultInfos);
      
      // 7. 更新UI（显示工具调用完成）
      await onToolSessionUpdate(toolSession);
      onNotifyListeners();
      
      return true;
      
    } catch (e, stackTrace) {
      developer.log('工具调用失败: $e', name: 'ToolCallHandler', error: e, stackTrace: stackTrace);
      
      // 记录错误到会话
      toolSession.fail(e.toString());
      await onToolSessionUpdate(toolSession);
      onNotifyListeners();
      
      return false;
    }
  }
  
  /// 解析工具调用参数（统一处理各种类型）
  Map<String, dynamic> _parseArguments(dynamic arguments) {
    if (arguments is StringBuffer) {
      final argsStr = arguments.toString();
      if (argsStr.isNotEmpty) {
        try {
          return Map<String, dynamic>.from(jsonDecode(argsStr));
        } catch (e) {
          developer.log('解析StringBuffer参数失败: $e', name: 'ToolCallHandler');
          return {};
        }
      }
      return {};
    } else if (arguments is Map) {
      return Map<String, dynamic>.from(arguments);
    } else if (arguments is String) {
      if (arguments.isNotEmpty) {
        try {
          return Map<String, dynamic>.from(jsonDecode(arguments));
        } catch (e) {
          developer.log('解析String参数失败: $e', name: 'ToolCallHandler');
          return {};
        }
      }
      return {};
    } else {
      return {};
    }
  }
  
  /// 解析结果内容（尝试解析为JSON）
  dynamic _parseResultContent(String content) {
    try {
      // 尝试解析为JSON
      final decoded = jsonDecode(content);
      return decoded;
    } catch (e) {
      // 如果不是JSON，返回原始字符串
      return content;
    }
  }
  
  /// 并发执行工具调用
  Future<List<ToolResponse>> _executeToolsConcurrently(
    List<ToolCallInfo> toolCalls,
  ) async {
    // 转换为 ToolCall 格式
    final toolCallsForExecution = toolCalls.map((info) => ToolCall(
      id: info.id,
      name: info.name,
      arguments: info.arguments,
    )).toList();
    
    // 并发执行所有工具
    final futures = toolCallsForExecution.map((toolCall) async {
      try {
        final responses = await ToolsService.executeToolCalls([toolCall]);
        
        return responses.first;
      } catch (e) {
        // 如果执行失败，返回错误响应
        return ToolResponse(
          toolCallId: toolCall.id,
          content: '工具执行失败: $e',
          isError: true,
        );
      }
    });
    
    return await Future.wait(futures);
  }
  
  /// 将工具结果添加到上下文（创建内部消息，不显示在UI）
  Future<void> _addToolResultsToContext(List<ToolResultInfo> results) async {
    for (final result in results) {
      // 创建内部工具结果消息
      final internalMsg = ChatMessage()
        ..id = '${DateTime.now().millisecondsSinceEpoch}_${result.toolCallId}'
        ..sessionId = session.id
        ..role = 'tool'
        ..content = jsonEncode({
          'result': result.result,
          'success': result.success,
          'error': result.error,
        })
        ..toolCallId = result.toolCallId
        ..isHidden = true  // 标记为隐藏，不在UI显示
        ..timestamp = DateTime.now();
      
      await onMessageAdded(internalMsg);
    }
  }
  
  /// 创建隐藏的工具消息（用于调试）
  Future<void> _createHiddenToolMessage(ToolResponse response) async {
    final debugMsg = ChatMessage()
      ..id = '${DateTime.now().millisecondsSinceEpoch}_debug_${response.toolCallId}'
      ..sessionId = session.id
      ..role = 'tool'
      ..content = response.content
      ..toolCallId = response.toolCallId
      ..isHidden = true
      ..timestamp = DateTime.now();
    
    await onMessageAdded(debugMsg);
  }
  
  /// 创建工具调用超时提示消息
  ChatMessage createTimeoutNotice() {
    return ChatMessage()
      ..id = DateTime.now().millisecondsSinceEpoch.toString()
      ..sessionId = session.id
      ..role = 'notice'
      ..content = '工具调用次数过多，已自动停止'
      ..timestamp = DateTime.now();
  }
  
  /// 是否保留调试消息（可通过配置控制）
  bool get _shouldKeepDebugMessages => false;  // 默认false，不保存调试消息
  
  // ============= 辅助方法（兼容旧版本） =============
  
  /// 兼容旧版本的handleToolCalls方法
  /// 如果不想立即修改所有调用代码，可以保留此方法
  @Deprecated('使用新版本的handleToolCalls，传入ToolSession参数')
  Future<bool> handleToolCallsLegacy({
    required List<ToolCall> toolCalls,
    String? groupId,
    int? versionOrder,
  }) async {
    // 创建一个临时会话用于处理
    final tempSession = ToolSession(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatSessionId: session.id.toString(),
      startTime: DateTime.now(),
    );
    
    return handleToolCalls(
      toolCalls: toolCalls,
      toolSession: tempSession,
      roundNumber: 0,
      groupId: groupId,
      versionOrder: versionOrder,
    );
  }
}

// ============= 扩展方法：为 ChatMessage 添加工具会话支持 =============

extension ChatMessageExtension on ChatMessage {
  /// 获取工具会话数据（如果消息包含工具会话）
  ToolSessionData? get toolSessionData {
    if (toolSessionDataJson == null || toolSessionDataJson!.isEmpty) {
      return null;
    }
    try {
      return ToolSessionData.fromJsonString(toolSessionDataJson!);
    } catch (e) {
      developer.log('解析工具会话数据失败: $e', name: 'ChatMessageExtension');
      return null;
    }
  }
  
  /// 设置工具会话数据
  set toolSessionData(ToolSessionData? data) {
    toolSessionDataJson = data?.toJsonString();
  }
  
  /// 是否为工具会话消息
  bool get isToolSessionMessage => isToolSession == true;
}

// ============= 新增：工具会话管理器 =============

class ToolSessionManager {
  ToolSession? _currentSession;
  
  /// 开始新的工具会话
  ToolSession startNewSession(String chatSessionId) {
    _currentSession = ToolSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      chatSessionId: chatSessionId,
      startTime: DateTime.now(),
    );
    return _currentSession!;
  }
  
  /// 获取当前会话
  ToolSession? get currentSession => _currentSession;
  
  /// 结束当前会话
  void endCurrentSession({String? finalContent, bool success = true}) {
    if (_currentSession == null) return;
    
    if (success) {
      _currentSession!.complete(finalContent);
    } else {
      _currentSession!.fail('会话异常结束');
    }
    _currentSession = null;
  }
  
  /// 取消当前会话
  void cancelCurrentSession() {
    if (_currentSession == null) return;
    _currentSession!.cancel();
    _currentSession = null;
  }
  
  /// 是否有活跃会话
  bool get hasActiveSession => _currentSession != null && 
      _currentSession!.status == ToolSessionStatus.executing;
}