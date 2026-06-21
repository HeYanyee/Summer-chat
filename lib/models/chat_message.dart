import 'package:isar/isar.dart';
import 'dart:convert';

part 'chat_message.g.dart'; // 需要运行 build_runner 生成

/// 聊天消息模型，适配 Isar 数据库
@collection
class ChatMessage {
  Id isarId = Isar.autoIncrement; // Isar 主键

  late String id; // 消息唯一标识
  @Index()
  int? sessionId; // 所属会话ID
  late String content; // 消息内容
  late String role; // 角色（user/assistant/system/tool/notice）
  
  // 工具调用相关字段（用于兼容旧格式）
  String? toolCallId; // 工具调用ID（用于关联工具调用和结果）
  String? toolName;   // 工具名称
  String? toolArguments; // 工具调用参数（JSON字符串）
  String? toolResponse;  // 工具执行结果
  bool isToolError = false; // 工具执行是否出错
  
  // 新增：工具会话聚合相关字段（只存储JSON，不存储对象）
  @Index()
  bool? isToolSession;      // 是否为工具会话消息（聚合消息）
  String? toolSessionDataJson; // 工具会话数据（JSON格式，存储ToolSessionData）
  bool? isHidden;           // 是否隐藏（用于内部工具结果消息，不在UI显示）
  
  late DateTime timestamp; // 时间戳
  String? versionGroup;    // 同一轮生成的所有候选
  int versionOrder = 0;    // 该候选在组内的序号
  bool isChosen = true;    // 用户当前选中的那个

  @Index()
  bool isFavorite = false; // 是否收藏

  ChatMessage();

  // 便于旧数据迁移的构造函数
  ChatMessage.fromOld({
    required this.id,
    this.sessionId,
    required this.content,
    required this.role,
    required DateTime? timestamp,
    this.isFavorite = false,
  }) : timestamp = timestamp ?? DateTime.now();

  // 批量从json字符串解析消息列表
  static List<ChatMessage> listFromJson(String jsonString) {
    final List<dynamic> messagesJson = jsonDecode(jsonString);
    return messagesJson
        .map((msg) => ChatMessage.fromJson(msg))
        .toList();
  }

  // 便于 JSON 互转
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId ?? -1,
      'content': content,
      'role': role,
      'toolCallId': toolCallId,
      'toolName': toolName,
      'toolArguments': toolArguments,
      'toolResponse': toolResponse,
      'isToolError': isToolError,
      'isToolSession': isToolSession,
      'toolSessionDataJson': toolSessionDataJson,
      'isHidden': isHidden,
      'timestamp': timestamp.toIso8601String(),
      'versionGroup': versionGroup,
      'versionOrder': versionOrder,
      'isChosen': isChosen,
      'isFavorite': isFavorite,
    };
  }

  // 转换为简短JSON（用于API调用）
  Map<String, dynamic> toShortJson() {
    return {
      'content': content,
      'role': role,
      if (toolCallId != null) 'tool_call_id': toolCallId,
      if (toolName != null) 'name': toolName,
    };
  }

  // 转换为API格式的消息（用于发送给AI模型）
  Map<String, dynamic> toApiMessage() {
    if (role == 'tool') {
      return {
        'role': 'tool',
        'tool_call_id': toolCallId,
        'content': content,
      };
    } else if (role == 'assistant' && toolCallId != null) {
      return {
        'role': 'assistant',
        'content': null,
        'tool_calls': [
          {
            'id': toolCallId,
            'type': 'function',
            'function': {
              'name': toolName,
              'arguments': toolArguments,
            }
          }
        ],
      };
    } else {
      return {
        'role': role,
        'content': content,
      };
    }
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage()
      ..id = json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString()
      ..sessionId = json['sessionId'] as int? ?? -1
      ..content = json['content'] as String? ?? ''
      ..role = json['role'] as String? ?? 'user'
      ..toolCallId = json['toolCallId'] as String?
      ..toolName = json['toolName'] as String?
      ..toolArguments = json['toolArguments'] as String?
      ..toolResponse = json['toolResponse'] as String?
      ..isToolError = json['isToolError'] as bool? ?? false
      ..isToolSession = json['isToolSession'] as bool?
      ..toolSessionDataJson = json['toolSessionDataJson'] as String?
      ..isHidden = json['isHidden'] as bool?
      ..timestamp = DateTime.parse(json['timestamp'] as String? ?? DateTime.now().toIso8601String())
      ..versionGroup = json['versionGroup'] as String?
      ..versionOrder = json['versionOrder'] as int? ?? 0
      ..isChosen = json['isChosen'] as bool? ?? true
      ..isFavorite = json['isFavorite'] as bool? ?? false;
  }

  // ============= 便捷属性 =============
  
  /// 是否为用户消息
  bool get isUser => role == 'user';
  
  /// 是否为助手消息
  bool get isAssistant => role == 'assistant';
  
  /// 是否为系统消息
  bool get isSystem => role == 'system';
  
  /// 是否为工具消息（旧格式）
  bool get isTool => role == 'tool';
  
  /// 是否为通知消息
  bool get isNotice => role == 'notice';
  
  /// 是否为工具调用消息（旧格式）
  bool get isToolCall => role == 'assistant' && toolCallId != null;
  
  /// 是否为工具响应消息（旧格式）
  bool get isToolResponse => role == 'tool';
  
  /// 是否为工具会话聚合消息（新格式）
  bool get isToolSessionMessage => isToolSession == true;
  
  /// 是否应该隐藏（内部消息，不在UI显示）
  bool get shouldHide => isHidden == true;
  
  /// 是否为可见消息（用于UI显示）
  bool get isVisible => !shouldHide;
  
  /// 获取解析后的工具参数（旧格式）
  @ignore
  Map<String, dynamic>? get parsedToolArguments {
    if (toolArguments == null || toolArguments!.isEmpty) return null;
    try {
      final decoded = jsonDecode(toolArguments!);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============= 工厂方法 =============
  
  /// 创建用户消息
  static ChatMessage createUserMessage({
    required String id,
    int? sessionId,
    required String content,
    DateTime? timestamp,
  }) {
    return ChatMessage()
      ..id = id
      ..sessionId = sessionId
      ..role = 'user'
      ..content = content
      ..timestamp = timestamp ?? DateTime.now()
      ..isChosen = true;
  }
  
  /// 创建助手消息
  static ChatMessage createAssistantMessage({
    required String id,
    int? sessionId,
    required String content,
    DateTime? timestamp,
    String? versionGroup,
    int versionOrder = 0,
  }) {
    return ChatMessage()
      ..id = id
      ..sessionId = sessionId
      ..role = 'assistant'
      ..content = content
      ..timestamp = timestamp ?? DateTime.now()
      ..versionGroup = versionGroup
      ..versionOrder = versionOrder
      ..isChosen = versionOrder == 0;
  }
  
  /// 创建系统消息
  static ChatMessage createSystemMessage({
    required String id,
    int? sessionId,
    required String content,
    DateTime? timestamp,
  }) {
    return ChatMessage()
      ..id = id
      ..sessionId = sessionId
      ..role = 'system'
      ..content = content
      ..timestamp = timestamp ?? DateTime.now();
  }
  
  /// 创建通知消息
  static ChatMessage createNoticeMessage({
    required String id,
    int? sessionId,
    required String content,
    DateTime? timestamp,
  }) {
    return ChatMessage()
      ..id = id
      ..sessionId = sessionId
      ..role = 'notice'
      ..content = content
      ..timestamp = timestamp ?? DateTime.now();
  }
  
  /// 创建工具调用消息（旧格式，保留用于兼容）
  static ChatMessage createToolCallMessage({
    required String id,
    int? sessionId,
    required String toolCallId,
    required String toolName,
    required Map<String, dynamic> arguments,
    DateTime? timestamp,
  }) {
    return ChatMessage()
      ..id = id
      ..sessionId = sessionId
      ..role = 'assistant'
      ..content = ''
      ..toolCallId = toolCallId
      ..toolName = toolName
      ..toolArguments = jsonEncode(arguments)
      ..timestamp = timestamp ?? DateTime.now();
  }

  /// 创建工具响应消息（旧格式，保留用于兼容）
  static ChatMessage createToolResponseMessage({
    required String id,
    int? sessionId,
    required String toolCallId,
    required String content,
    bool isError = false,
    DateTime? timestamp,
  }) {
    return ChatMessage()
      ..id = id
      ..sessionId = sessionId
      ..role = 'tool'
      ..content = content
      ..toolCallId = toolCallId
      ..isToolError = isError
      ..timestamp = timestamp ?? DateTime.now();
  }
  
  /// 创建隐藏的内部工具消息（用于上下文，不在UI显示）
  static ChatMessage createHiddenToolMessage({
    required String id,
    int? sessionId,
    required String toolCallId,
    required dynamic result,
    bool isError = false,
    DateTime? timestamp,
  }) {
    return ChatMessage()
      ..id = id
      ..sessionId = sessionId
      ..role = 'tool'
      ..content = jsonEncode({
        'result': result,
        'success': !isError,
        'error': isError ? result.toString() : null,
      })
      ..toolCallId = toolCallId
      ..isToolError = isError
      ..isHidden = true
      ..timestamp = timestamp ?? DateTime.now();
  }

  // ============= 辅助方法 =============
  
  /// 复制消息
  ChatMessage copyWith({
    String? id,
    int? sessionId,
    String? content,
    String? role,
    String? toolCallId,
    String? toolName,
    String? toolArguments,
    String? toolResponse,
    bool? isToolError,
    bool? isToolSession,
    String? toolSessionDataJson,
    bool? isHidden,
    DateTime? timestamp,
    String? versionGroup,
    int? versionOrder,
    bool? isChosen,
    bool? isFavorite,
  }) {
    return ChatMessage()
      ..id = id ?? this.id
      ..sessionId = sessionId ?? this.sessionId
      ..content = content ?? this.content
      ..role = role ?? this.role
      ..toolCallId = toolCallId ?? this.toolCallId
      ..toolName = toolName ?? this.toolName
      ..toolArguments = toolArguments ?? this.toolArguments
      ..toolResponse = toolResponse ?? this.toolResponse
      ..isToolError = isToolError ?? this.isToolError
      ..isToolSession = isToolSession ?? this.isToolSession
      ..toolSessionDataJson = toolSessionDataJson ?? this.toolSessionDataJson
      ..isHidden = isHidden ?? this.isHidden
      ..timestamp = timestamp ?? this.timestamp
      ..versionGroup = versionGroup ?? this.versionGroup
      ..versionOrder = versionOrder ?? this.versionOrder
      ..isChosen = isChosen ?? this.isChosen
      ..isFavorite = isFavorite ?? this.isFavorite;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'ChatMessage(id: $id, role: $role, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}, timestamp: $timestamp)';
  }
}