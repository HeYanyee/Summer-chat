// models/tool.dart

import 'dart:convert';

/// 工具参数属性的定义
class ToolParameterProperty {
  final String type;        
  final String description; 
  final List<String>? enumValues; // 明确指定为 List<String>?
  
  ToolParameterProperty({
    required this.type,
    required this.description,
    this.enumValues,
  });
  
  // 修改返回类型为 dynamic，因为值可以是 String 或 List
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{  // 使用 <String, dynamic> 而不是 <String, String>
      'type': type,
      'description': description,
    };
    
    if (enumValues != null) {
      json['enum'] = enumValues; // 现在 List<String> 可以赋值给 dynamic
    }
    
    return json;
  }
  
  factory ToolParameterProperty.fromJson(Map<String, dynamic> json) {
    return ToolParameterProperty(
      type: json['type'] as String,
      description: json['description'] as String,
      enumValues: (json['enum'] as List?)?.map((e) => e as String).toList(),
    );
  }
}

/// 工具参数定义
class ToolParameters {
  final String type;
  final Map<String, ToolParameterProperty> properties;
  final List<String> required;
  
  ToolParameters({
    this.type = 'object',
    required this.properties,
    this.required = const [],
  });
  
  Map<String, dynamic> toJson() {
    final propertiesJson = <String, dynamic>{};
    properties.forEach((key, value) {
      propertiesJson[key] = value.toJson();  // 这里调用上面的 toJson()
    });
    
    return {
      'type': type,
      'properties': propertiesJson,
      'required': required,  // required 是 List<String>
    };
  }

  factory ToolParameters.fromJson(Map<String, dynamic> json) {
    final propertiesJson = json['properties'] as Map<String, dynamic>;
    final properties = <String, ToolParameterProperty>{};
    
    propertiesJson.forEach((key, value) {
      properties[key] = ToolParameterProperty.fromJson(value as Map<String, dynamic>);
    });
    
    return ToolParameters(
      type: json['type'] as String,
      properties: properties,
      required: (json['required'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

/// 工具定义
class Tool {
  final String id;          // 工具唯一标识
  final String name;        // 工具名称（模型调用的函数名）
  final String description; // 工具描述
  final ToolParameters parameters; // 参数定义
  late final bool enabled;       // 是否启用
  
  Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.parameters,
    this.enabled = true,
  });
  
  /// 转换为OpenAI兼容的格式
  Map<String, dynamic> toFunctionJson() {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': parameters.toJson(),
      },
    };
  }
  
  /// 转换为存储格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parameters': parameters.toJson(),
      'enabled': enabled,
    };
  }
  
  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      parameters: ToolParameters.fromJson(json['parameters'] as Map<String, dynamic>),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
  
  /// 创建工具实例的快捷方法
  factory Tool.create({
    required String name,
    required String description,
    required ToolParameters parameters,
    bool enabled = true,
  }) {
    return Tool(
      id: _generateToolId(name),
      name: name,
      description: description,
      parameters: parameters,
      enabled: enabled,
    );
  }
  
  static String _generateToolId(String name) {
    return 'tool_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// 工具调用（模型发起的调用请求）
class ToolCall {
  final String id;
  final String name;
  final dynamic arguments;
  final String? type;
  final int? index; // 添加 index 字段用于流式调用

  ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
    this.type,
    this.index,
  });

  // 从 JSON 创建（包括流式格式）
  factory ToolCall.fromJson(Map<String, dynamic> json) {
    // 处理流式格式（包含 index）
    if (json.containsKey('index')) {
      return ToolCall(
        id: json['id'] ?? '',
        name: json['function']?['name'] ?? '',
        arguments: json['function']?['arguments'] ?? '',
        type: json['type'],
        index: json['index'],
      );
    }
    
    // 处理普通格式
    return ToolCall(
      id: json['id'] ?? json['index'].toString(),
      name: json['function']['name'],
      arguments: json['function']['arguments'],
      type: json['type'],
    );
  }

    Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'type': type ?? 'function',
      'function': {
        'name': name,
        'arguments': arguments,
      },
    };
    
    // 如果有 index（流式场景），添加到 JSON
    if (index != null) {
      json['index'] = index;
    }
    
    return json;
  }

  ToolCall copyWith({
      String? id,
      String? name,
      dynamic arguments,
      String? type,
      int? index,
    }) {
      return ToolCall(
        id: id ?? this.id,
        name: name ?? this.name,
        arguments: arguments ?? this.arguments,
        type: type ?? this.type,
        index: index ?? this.index,
      );
    }

  // 获取解析后的参数
  Map<String, dynamic> get parsedArguments {
    if (arguments is Map) {
      return Map<String, dynamic>.from(arguments);
    } else if (arguments is String) {
      try {
        final parsed = jsonDecode(arguments);
        if (parsed is Map) {
          return Map<String, dynamic>.from(parsed);
        }
      } catch (e) {
        // 解析失败，返回空 Map
      }
    }
    return {};
  }

  // 转换为 API 格式
  Map<String, dynamic> toApiFormat() {
    return {
      'id': id,
      'type': type ?? 'function',
      'function': {
        'name': name,
        'arguments': arguments is String 
            ? arguments 
            : jsonEncode(arguments),
      },
    };
  }
}

/// 工具执行结果
class ToolResponse {
  final String toolCallId;   // 对应的工具调用ID
  final String content;      // 执行结果内容
  final bool isError;        // 是否执行错误
  final Duration? executionTime;
  
  ToolResponse({
    required this.toolCallId,
    required this.content,
    this.isError = false,
    this.executionTime,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'tool_call_id': toolCallId,
      'content': content,
      'isError': isError,
      'executionTimeMs': executionTime?.inMilliseconds,
    };
  }
  
  factory ToolResponse.fromJson(Map<String, dynamic> json) {
    return ToolResponse(
      toolCallId: json['tool_call_id'] as String,
      content: json['content'] as String,
      isError: json['isError'] as bool? ?? false,
      executionTime: json['executionTimeMs'] != null 
          ? Duration(milliseconds: json['executionTimeMs'] as int)
          : null,
    );
  }
}


/// 工具调用历史记录
class ToolCallHistory {
  final String id;
  final String sessionId;
  final ToolCall toolCall;
  final ToolResponse? response;
  final DateTime timestamp;
  
  ToolCallHistory({
    required this.id,
    required this.sessionId,
    required this.toolCall,
    this.response,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'toolCall': toolCall.toJson(),
      'response': response?.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory ToolCallHistory.fromJson(Map<String, dynamic> json) {
    return ToolCallHistory(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      toolCall: ToolCall.fromJson(json['toolCall'] as Map<String, dynamic>),
      response: json['response'] != null 
          ? ToolResponse.fromJson(json['response'] as Map<String, dynamic>)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// ============= 新增：工具调用会话相关类 =============

/// 工具调用会话状态
enum ToolSessionStatus {
  executing,  // 执行中
  completed,  // 已完成
  failed,     // 失败
  cancelled,  // 已取消
}

/// 工具调用信息（用于记录单个工具调用）
class ToolCallInfo {
  final String id;                    // 工具调用ID
  final String name;                  // 工具名称
  final Map<String, dynamic> arguments; // 参数
  DateTime? executeTime;              // 执行时间
  
  ToolCallInfo({
    required this.id,
    required this.name,
    required this.arguments,
    this.executeTime,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arguments': arguments,
      'executeTime': executeTime?.toIso8601String(),
    };
  }
  
  factory ToolCallInfo.fromJson(Map<String, dynamic> json) {
    return ToolCallInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
      executeTime: json['executeTime'] != null 
          ? DateTime.parse(json['executeTime'] as String)
          : null,
    );
  }
  
  ToolCallInfo copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? arguments,
    DateTime? executeTime,
  }) {
    return ToolCallInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      executeTime: executeTime ?? this.executeTime,
    );
  }
}

/// 工具执行结果信息
class ToolResultInfo {
  final String toolCallId;            // 对应的工具调用ID
  final dynamic result;               // 执行结果
  final bool success;                 // 是否成功
  final String? error;                // 错误信息（如果失败）
  final Duration executionTime;       // 执行耗时
  final DateTime timestamp;           // 完成时间戳
  
  ToolResultInfo({
    required this.toolCallId,
    required this.result,
    required this.success,
    this.error,
    required this.executionTime,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'toolCallId': toolCallId,
      'result': result,
      'success': success,
      'error': error,
      'executionTimeMs': executionTime.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory ToolResultInfo.fromJson(Map<String, dynamic> json) {
    return ToolResultInfo(
      toolCallId: json['toolCallId'] as String,
      result: json['result'],
      success: json['success'] as bool,
      error: json['error'] as String?,
      executionTime: Duration(milliseconds: json['executionTimeMs'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
  
  /// 获取结果摘要（用于UI显示）
  String get summary {
    if (!success) return '执行失败: ${error ?? "未知错误"}';
    
    // 根据结果类型生成摘要
    if (result is Map && (result as Map).containsKey('summary')) {
      return (result as Map)['summary'] as String;
    }
    
    if (result is List) {
      return '返回 ${(result as List).length} 条结果';
    }
    
    if (result is String && result.length > 50) {
      return '${result.substring(0, 50)}...';
    }
    
    return '执行成功 (${executionTime.inMilliseconds}ms)';
  }
}

/// 单轮工具调用记录
class ToolRound {
  final int roundNumber;              // 轮次编号（从0开始）
  final DateTime timestamp;           // 开始时间戳
  final List<ToolCallInfo> toolCalls; // 本轮的工具调用列表
  List<ToolResultInfo> results;       // 工具执行结果列表
  String? intermediateThinking;       // AI的中间思考（如果有）
  Duration duration;                  // 本轮总耗时
  
  ToolRound({
    required this.roundNumber,
    required this.timestamp,
    required this.toolCalls,
    this.results = const [],
    this.intermediateThinking,
    Duration? duration,
  }) : duration = duration ?? Duration.zero;
  
  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'timestamp': timestamp.toIso8601String(),
      'toolCalls': toolCalls.map((tc) => tc.toJson()).toList(),
      'results': results.map((r) => r.toJson()).toList(),
      'intermediateThinking': intermediateThinking,
      'durationMs': duration.inMilliseconds,
    };
  }
  
  factory ToolRound.fromJson(Map<String, dynamic> json) {
    return ToolRound(
      roundNumber: json['roundNumber'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      toolCalls: (json['toolCalls'] as List)
          .map((tc) => ToolCallInfo.fromJson(tc as Map<String, dynamic>))
          .toList(),
      results: (json['results'] as List)
          .map((r) => ToolResultInfo.fromJson(r as Map<String, dynamic>))
          .toList(),
      intermediateThinking: json['intermediateThinking'] as String?,
      duration: Duration(milliseconds: json['durationMs'] as int),
    );
  }
  
  /// 本轮是否成功（所有工具调用都成功）
  bool get isSuccessful {
    return results.isNotEmpty && 
           results.every((r) => r.success) &&
           results.length == toolCalls.length;
  }
  
  /// 获取本轮耗时统计
  Duration get totalDuration {
    if (results.isEmpty) return Duration.zero;
    final maxTime = results.map((r) => r.executionTime).reduce((a, b) => 
      a > b ? a : b
    );
    return maxTime;
  }
}

/// 工具调用会话（代表一次完整的工具调用会话，可能包含多轮）
class ToolSession {
  final String id;                     // 会话唯一标识
  final String chatSessionId;          // 所属聊天会话ID
  final DateTime startTime;            // 开始时间
  final List<ToolRound> rounds;        // 多轮工具调用记录
  String? finalContent;                // 最终回答内容
  DateTime? endTime;                   // 结束时间
  ToolSessionStatus status;            // 会话状态
  String? errorMessage;                // 错误信息（如果失败）
  
  ToolSession({
    required this.id,
    required this.chatSessionId,
    required this.startTime,
    List<ToolRound>? rounds,
    this.finalContent,
    this.endTime,
    this.status = ToolSessionStatus.executing,
    this.errorMessage,
  }) : rounds = rounds ?? [];  // 关键：使用 [] 而不是 const []
  
  // 添加方法
  void addRound(ToolRound round) {
    rounds.add(round);
  }
  
  void addRounds(List<ToolRound> newRounds) {
    rounds.addAll(newRounds);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatSessionId': chatSessionId,
      'startTime': startTime.toIso8601String(),
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'finalContent': finalContent,
      'endTime': endTime?.toIso8601String(),
      'status': status.index,
      'errorMessage': errorMessage,
    };
  }
  
  factory ToolSession.fromJson(Map<String, dynamic> json) {
    return ToolSession(
      id: json['id'] as String,
      chatSessionId: json['chatSessionId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      rounds: (json['rounds'] as List)
          .map((r) => ToolRound.fromJson(r as Map<String, dynamic>))
          .toList(),
      finalContent: json['finalContent'] as String?,
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String)
          : null,
      status: ToolSessionStatus.values[json['status'] as int],
      errorMessage: json['errorMessage'] as String?,
    );
  }
  
  // ============= 辅助方法 =============
  
  /// 总工具调用次数
  int get totalToolCalls => 
      rounds.fold(0, (sum, round) => sum + round.toolCalls.length);
  
  /// 成功工具调用次数
  int get successfulToolCalls =>
      rounds.fold(0, (sum, round) => sum + round.results.where((r) => r.success).length);
  
  /// 失败工具调用次数
  int get failedToolCalls => totalToolCalls - successfulToolCalls;
  
  /// 总耗时
  Duration get totalDuration => endTime != null ? (endTime!.difference(startTime)) : Duration.zero;
  
  /// 会话是否完成（成功或失败）
  bool get isFinished => status != ToolSessionStatus.executing;
  
  /// 会话是否成功
  bool get isSuccessful => status == ToolSessionStatus.completed;
  
  /// 完成会话
  void complete(String? finalAnswer) {
    finalContent = finalAnswer;
    endTime = DateTime.now();
    status = ToolSessionStatus.completed;
  }
  
  /// 会话失败
  void fail(String error) {
    errorMessage = error;
    endTime = DateTime.now();
    status = ToolSessionStatus.failed;
  }
  
  /// 取消会话
  void cancel() {
    endTime = DateTime.now();
    status = ToolSessionStatus.cancelled;
  }
  
  /// 获取最后一条工具调用的结果
  ToolResultInfo? getLastToolResult() {
    if (rounds.isEmpty || rounds.last.results.isEmpty) return null;
    return rounds.last.results.last;
  }
  
  /// 获取指定工具调用的结果
  ToolResultInfo? getToolResult(String toolCallId) {
    for (final round in rounds) {
      for (final result in round.results) {
        if (result.toolCallId == toolCallId) {
          return result;
        }
      }
    }
    return null;
  }
  
  /// 生成会话摘要（用于UI显示）
  String get summary {
    if (status == ToolSessionStatus.completed) {
      return '已完成 · ${totalToolCalls}次工具调用 · ${totalDuration.inMilliseconds}ms';
    } else if (status == ToolSessionStatus.executing) {
      return '执行中 · ${rounds.length}轮 · ${totalToolCalls}次调用';
    } else if (status == ToolSessionStatus.failed) {
      return '失败: ${errorMessage ?? "未知错误"}';
    } else {
      return '已取消';
    }
  }
  
  /// 序列化为JSON字符串（用于存储）
  String toJsonString() {
    return jsonEncode(toJson());
  }
  
  /// 从JSON字符串反序列化
  static ToolSession fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ToolSession.fromJson(json);
  }
}

/// 工具会话数据（用于嵌入到ChatMessage中）
class ToolSessionData {
  final ToolSession session;
  final bool isExpanded;  // UI是否展开显示详情
  
  ToolSessionData({
    required this.session,
    this.isExpanded = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'session': session.toJson(),
      'isExpanded': isExpanded,
    };
  }
  
  factory ToolSessionData.fromJson(Map<String, dynamic> json) {
    return ToolSessionData(
      session: ToolSession.fromJson(json['session'] as Map<String, dynamic>),
      isExpanded: json['isExpanded'] as bool? ?? false,
    );
  }
  
  String toJsonString() => jsonEncode(toJson());
  
  static ToolSessionData fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ToolSessionData.fromJson(json);
  }
}