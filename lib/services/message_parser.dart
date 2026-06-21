import 'package:summer/models/chat_message.dart';
import 'package:summer/models/tool.dart';  // 这里可以安全引用

/// 消息解析器 - 负责解析 ChatMessage 中的复杂数据
class MessageParser {
  /// 从 ChatMessage 解析工具会话数据
  static ToolSessionData? parseToolSession(ChatMessage message) {
    if (message.toolSessionDataJson == null || message.toolSessionDataJson!.isEmpty) {
      return null;
    }
    try {
      return ToolSessionData.fromJsonString(message.toolSessionDataJson!);
    } catch (e) {
      return null;
    }
  }
  
  /// 判断是否为工具会话消息
  static bool isToolSessionMessage(ChatMessage message) {
    return message.isToolSession == true;
  }
  
  /// 获取消息的显示内容（自动处理工具会话）
  static String getDisplayContent(ChatMessage message) {
    if (isToolSessionMessage(message)) {
      final sessionData = parseToolSession(message);
      if (sessionData != null && sessionData.session.finalContent != null) {
        return sessionData.session.finalContent!;
      }
    }
    return message.content;
  }
  
  /// 获取消息的详细描述（用于调试）
  static String getDescription(ChatMessage message) {
    if (isToolSessionMessage(message)) {
      final sessionData = parseToolSession(message);
      if (sessionData != null) {
        return 'ToolSession: ${sessionData.session.summary}';
      }
    }
    
    if (message.isToolCall) {
      return 'ToolCall: ${message.toolName}';
    }
    
    if (message.isToolResponse) {
      return 'ToolResponse: ${message.isToolError ? "Error" : "Success"}';
    }
    
    return '${message.role}: ${message.content.length > 50 ? message.content.substring(0, 50) : message.content}';
  }
  
  /// 批量解析消息列表中的工具会话
  static List<ChatMessage> resolveToolSessions(List<ChatMessage> messages) {
    // 这个方法可以在需要时预解析所有工具会话
    // 但通常不需要，因为解析是轻量的
    return messages;
  }
}