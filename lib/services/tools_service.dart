// tools_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:summer/tools/tool_list.dart';

import '../models/tool.dart';
import '../models/chat_message.dart';
import '../services/storage_service.dart';

class ToolsService {
  static final ToolsService _instance = ToolsService._internal();
  factory ToolsService() => _instance;
  ToolsService._internal();

  // 工具执行器映射
  final Map<String, Function(Map<String, dynamic>)> _toolHandlers = {};

  /// 初始化工具处理器（从 tool_list 注册）
  void initialize() {
    final handlers = PredefinedTools.getHandlers();
    handlers.forEach((name, handler) {
      _registerToolHandler(name, handler);
    });
  }

  /// 注册工具处理器
  void _registerToolHandler(String toolName, Function(Map<String, dynamic>) handler) {
    _toolHandlers[toolName] = handler;
  }

  /// 获取会话启用的工具列表
  static Future<List<Tool>> getEnabledToolsForSession(String sessionId) async {
    final session = await IsarStorageService.getSession(int.parse(sessionId));
    if (session == null) return [];

    if (session.enabledTools) {
      return await getAllAvailableTools();
    } else {
      return [];
    }
  }

  /// 获取所有可用工具（预定义 + 自定义）
  static Future<List<Tool>> getAllAvailableTools() async {
    final predefinedTools = PredefinedTools.getAllPredefinedTools();
    // final customTools = await IsarStorageService.getAllCustomTools();
    return [...predefinedTools]; // 可添加 customTools
  }

  /// 执行单个工具调用
  static Future<ToolResponse> executeToolCall(ToolCall toolCall) async {
    debugPrint('尝试执行工具: ${toolCall.name}');
    debugPrint('工具参数: ${toolCall.arguments}');
    debugPrint('当前注册的工具: ${_instance._toolHandlers.keys.join(', ')}');

    try {
      final handler = _instance._toolHandlers[toolCall.name];
      if (handler == null) {
        debugPrint('未找到工具处理器: ${toolCall.name}');

        final possibleMatch = _instance._findSimilarTool(toolCall.name);
        if (possibleMatch != null) {
          debugPrint('找到相似工具: $possibleMatch');
          final result = await _instance._toolHandlers[possibleMatch]!(toolCall.arguments);
          return ToolResponse(
            toolCallId: toolCall.id,
            content: result,
            isError: false,
          );
        }

        return ToolResponse(
          toolCallId: toolCall.id,
          content: '未知工具: ${toolCall.name}，可用工具: ${_instance._toolHandlers.keys.join(', ')}',
          isError: true,
        );
      }

      final result = await handler(toolCall.arguments);
      debugPrint('工具执行成功: $result');

      return ToolResponse(
        toolCallId: toolCall.id,
        content: result,
        isError: false,
      );
    } catch (e) {
      debugPrint('工具执行失败: $e');
      return ToolResponse(
        toolCallId: toolCall.id,
        content: '工具执行失败: $e',
        isError: true,
      );
    }
  }

  /// 查找相似工具名
  String? _findSimilarTool(String name) {
    for (var key in _toolHandlers.keys) {
      if (key.contains(name) || name.contains(key)) {
        return key;
      }
    }
    return null;
  }

  /// 批量执行工具调用（串行执行）
  static Future<List<ToolResponse>> executeToolCalls(List<ToolCall> toolCalls) async {
    final responses = <ToolResponse>[];
    for (var toolCall in toolCalls) {
      final response = await executeToolCall(toolCall);
      responses.add(response);
    }
    return responses;
  }

  /// 批量执行工具调用（并发执行）- 新增
  static Future<List<ToolResponse>> executeToolCallsConcurrently(List<ToolCall> toolCalls) async {
    final futures = toolCalls.map((toolCall) => executeToolCall(toolCall));
    return await Future.wait(futures);
  }

  /// 执行工具调用并返回详细结果（用于工具会话）- 新增
  static Future<ToolExecutionDetail> executeToolCallWithDetail(ToolCall toolCall) async {
    final startTime = DateTime.now();
    
    try {
      final response = await executeToolCall(toolCall);
      final executionTime = DateTime.now().difference(startTime);
      
      return ToolExecutionDetail(
        toolCallId: toolCall.id,
        toolName: toolCall.name,
        arguments: toolCall.parsedArguments,
        result: response.content,
        success: !response.isError,
        error: response.isError ? response.content : null,
        executionTime: executionTime,
      );
    } catch (e) {
      final executionTime = DateTime.now().difference(startTime);
      return ToolExecutionDetail(
        toolCallId: toolCall.id,
        toolName: toolCall.name,
        arguments: toolCall.parsedArguments,
        result: null,
        success: false,
        error: e.toString(),
        executionTime: executionTime,
      );
    }
  }

  /// 批量执行工具调用并返回详细信息（并发）- 新增
  static Future<List<ToolExecutionDetail>> executeToolCallsWithDetails(List<ToolCall> toolCalls) async {
    final futures = toolCalls.map((toolCall) => executeToolCallWithDetail(toolCall));
    return await Future.wait(futures);
  }

  // ==================== 消息创建方法 ====================

  /// 从工具响应创建聊天消息（旧格式，保留兼容）
  static ChatMessage createToolResponseMessage({
    required String sessionId,
    required ToolResponse response,
  }) {
    return ChatMessage.createToolResponseMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_${response.toolCallId}',
      sessionId: int.parse(sessionId),
      toolCallId: response.toolCallId,
      content: response.content,
      isError: response.isError,
    );
  }

  /// 从工具调用创建聊天消息（旧格式，保留兼容）
  static ChatMessage createToolCallMessage({
    required String sessionId,
    required ToolCall toolCall,
  }) {
    return ChatMessage.createToolCallMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_${toolCall.id}',
      sessionId: int.parse(sessionId),
      toolCallId: toolCall.id,
      toolName: toolCall.name,
      arguments: toolCall.parsedArguments,
    );
  }

  /// 创建隐藏的工具响应消息（用于上下文，不在UI显示）- 新增
  static ChatMessage createHiddenToolResponseMessage({
    required String sessionId,
    required ToolExecutionDetail detail,
  }) {
    return ChatMessage.createHiddenToolMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_hidden_${detail.toolCallId}',
      sessionId: int.parse(sessionId),
      toolCallId: detail.toolCallId,
      result: detail.result,
      isError: !detail.success,
    );
  }

  /// 创建工具会话聚合消息 - 新增
  static ChatMessage createToolSessionMessage({
    required String sessionId,
    required ToolSession toolSession,
    bool isExpanded = false,
  }) {
    final sessionData = ToolSessionData(
      session: toolSession,
      isExpanded: isExpanded,
    );
    
    final message = ChatMessage.createAssistantMessage(
      id: toolSession.id,
      sessionId: int.parse(sessionId),
      content: toolSession.finalContent ?? '',
      timestamp: toolSession.startTime,
    );
    
    message.isToolSession = true;
    message.toolSessionDataJson = sessionData.toJsonString();
    
    return message;
  }

  /// 更新工具会话聚合消息 - 新增
  static void updateToolSessionMessage(ChatMessage message, ToolSession toolSession) {
    if (!message.isToolSessionMessage) return;
    
    final sessionData = ToolSessionData(
      session: toolSession,
      isExpanded: false, // 保持原有展开状态
    );
    
    message.content = toolSession.finalContent ?? message.content;
    message.toolSessionDataJson = sessionData.toJsonString();
  }

  // ==================== 工具管理方法 ====================

  static Future<void> saveCustomTool(Tool tool) async {
    await IsarStorageService.saveTool(tool);
  }

  static Future<void> deleteTool(String toolId) async {
    await IsarStorageService.deleteTool(toolId);
  }

  static Future<void> setToolEnabled(String toolId, bool enabled) async {
    final tool = await IsarStorageService.getTool(toolId);
    if (tool != null) {
      tool.enabled = enabled;
      await IsarStorageService.saveTool(tool);
    }
  }

  static Future<void> enableToolsForSession(String sessionId, List<String> toolIds) async {
    final session = await IsarStorageService.getSession(int.parse(sessionId));
    if (session != null) {
      session.enabledTools = true;
      await IsarStorageService.updateSession(session);
    }
  }

  // ==================== 辅助方法 ====================

  /// 获取工具执行器（用于调试）
  static Set<String> getRegisteredTools() {
    return Set.from(_instance._toolHandlers.keys);
  }

  /// 检查工具是否已注册
  static bool isToolRegistered(String toolName) {
    return _instance._toolHandlers.containsKey(toolName);
  }
}

// ==================== 新增：工具执行详情类 ====================

/// 工具执行详情（用于记录到 ToolSession）
class ToolExecutionDetail {
  final String toolCallId;
  final String toolName;
  final Map<String, dynamic> arguments;
  final dynamic result;
  final bool success;
  final String? error;
  final Duration executionTime;
  final DateTime timestamp;
  
  ToolExecutionDetail({
    required this.toolCallId,
    required this.toolName,
    required this.arguments,
    this.result,
    required this.success,
    this.error,
    required this.executionTime,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// 转换为 ToolResultInfo
  ToolResultInfo toToolResultInfo() {
    return ToolResultInfo(
      toolCallId: toolCallId,
      result: result,
      success: success,
      error: error,
      executionTime: executionTime,
      timestamp: timestamp,
    );
  }
  
  /// 转换为 ToolCallInfo
  ToolCallInfo toToolCallInfo() {
    return ToolCallInfo(
      id: toolCallId,
      name: toolName,
      arguments: arguments,
      executeTime: timestamp,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'toolCallId': toolCallId,
      'toolName': toolName,
      'arguments': arguments,
      'result': result,
      'success': success,
      'error': error,
      'executionTimeMs': executionTime.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory ToolExecutionDetail.fromJson(Map<String, dynamic> json) {
    return ToolExecutionDetail(
      toolCallId: json['toolCallId'] as String,
      toolName: json['toolName'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
      result: json['result'],
      success: json['success'] as bool,
      error: json['error'] as String?,
      executionTime: Duration(milliseconds: json['executionTimeMs'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// ==================== 新增：工具会话构建器 ====================

/// 工具会话构建器 - 用于方便地构建 ToolSession
class ToolSessionBuilder {
  final String chatSessionId;
  final List<ToolRound> _rounds = [];
  String? _finalContent;
  
  ToolSessionBuilder({required this.chatSessionId});
  
  /// 添加一轮工具调用
  Future<ToolRound> addRound(
    int roundNumber,
    List<ToolCall> toolCalls,
  ) async {
    final startTime = DateTime.now();
    
    // 转换为 ToolCallInfo
    final toolCallInfos = toolCalls.map((tc) => ToolCallInfo(
      id: tc.id,
      name: tc.name,
      arguments: tc.parsedArguments,
      executeTime: startTime,
    )).toList();
    
    // 执行工具调用
    final details = await ToolsService.executeToolCallsWithDetails(toolCalls);
    final results = details.map((d) => d.toToolResultInfo()).toList();
    
    final round = ToolRound(
      roundNumber: roundNumber,
      timestamp: startTime,
      toolCalls: toolCallInfos,
      results: results,
      duration: DateTime.now().difference(startTime),
    );
    
    _rounds.add(round);
    return round;
  }
  
  /// 添加一轮工具调用（使用已执行的结果）
  void addRoundWithResults(ToolRound round) {
    _rounds.add(round);
  }
  
  /// 设置最终内容
  void setFinalContent(String content) {
    _finalContent = content;
  }
  
  /// 构建 ToolSession
  ToolSession build() {
    return ToolSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      chatSessionId: chatSessionId,
      startTime: _rounds.isNotEmpty ? _rounds.first.timestamp : DateTime.now(),
      rounds: _rounds,
      finalContent: _finalContent,
      status: ToolSessionStatus.completed,
      endTime: DateTime.now(),
    );
  }
}