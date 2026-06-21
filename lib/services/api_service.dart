// services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/app_settings.dart';
import '../models/character_card.dart';
import '../models/tool.dart'; // 新增导入
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'package:flutter/foundation.dart';

class ApiResponse {
  /// 返回的文本内容（可能包含推理信息）
  final String? content;
  final bool isFinished;
  /// 新增：工具调用列表
  final List<ToolCall>? toolCalls;
  /// 新增：是否有工具调用正在进行
  final bool hasToolCallDelta;

  ApiResponse({
    this.content,
    this.isFinished = false,
    this.toolCalls,
    this.hasToolCallDelta = false,  // 新增
  });
}

// 创建一个用于跟踪当前流处理状态的类
class _StreamState {
  bool thinkingTagAdded = false;
  bool closingTagAdded = false;
  bool hasReasoningContent = false;
  
  // 修改为：支持多个工具调用的状态，用 index 作为键
  Map<int, ToolCallState> toolCallStates = {};
  
  // 为了向后兼容，保留这些字段但标记为弃用
  @Deprecated('使用 toolCallStates 替代')
  Map<String, dynamic>? currentToolCall;
  
  @Deprecated('使用 toolCallStates 替代')
  String currentToolCallId = '';
  
  @Deprecated('使用 toolCallStates 替代')
  String currentToolName = '';
  
  @Deprecated('使用 toolCallStates 替代')
  String currentToolArguments = '';
  
  void reset() {
    thinkingTagAdded = false;
    closingTagAdded = false;
    hasReasoningContent = false;
    
    // 重置新字段
    toolCallStates.clear();
    
    // 重置旧字段
    currentToolCall = null;
    currentToolCallId = '';
    currentToolName = '';
    currentToolArguments = '';
  }
  
  // 新增：获取指定 index 的工具调用状态
  ToolCallState? getToolCallState(int index) {
    return toolCallStates[index];
  }
  
  // 新增：更新或创建工具调用状态
  void updateToolCallState({
    required int index,
    String? id,
    String? name,
    String? arguments,
  }) {
    final existing = toolCallStates[index];
    if (existing != null) {
      // 更新现有状态
      toolCallStates[index] = existing.copyWith(
        id: id,
        name: name,
        arguments: arguments != null ? existing.arguments + arguments : existing.arguments,
      );
    } else {
      // 创建新状态
      toolCallStates[index] = ToolCallState(
        id: id ?? '',
        name: name ?? '',
        arguments: arguments ?? '',
        index: index,
      );
    }
  }
  
  // 新增：检查是否有任何工具调用
  bool get hasAnyToolCall => toolCallStates.isNotEmpty;
  
  // 新增：获取所有工具调用（按 index 排序）
  List<ToolCallState> getAllToolCalls() {
    final indexes = toolCallStates.keys.toList()..sort();
    return indexes.map((i) => toolCallStates[i]!).toList();
  }
  
  // 新增：构建最终的 ToolCall 列表
  List<ToolCall> buildFinalToolCalls() {
    if (toolCallStates.isEmpty) return [];
    
    return getAllToolCalls().map((state) {
      return ToolCall(
        id: state.id.isNotEmpty ? state.id : 'call_${DateTime.now().millisecondsSinceEpoch}_${state.index}',
        type: 'function',
        name: state.name,
        arguments: state.arguments,
        index: state.index,
      );
    }).toList();
  }
}

// 新增：工具调用状态类
class ToolCallState {
  final String id;
  final String name;
  final String arguments;
  final int index;
  
  ToolCallState({
    required this.id,
    required this.name,
    required this.arguments,
    required this.index,
  });
  
  ToolCallState copyWith({
    String? id,
    String? name,
    String? arguments,
    int? index,
  }) {
    return ToolCallState(
      id: id ?? this.id,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      index: index ?? this.index,
    );
  }
  
  @override
  String toString() {
    return 'ToolCallState(index: $index, id: $id, name: $name, arguments: $arguments)';
  }
}

abstract class ApiProvider {
  String getRequestUrl(String baseUrl);
  Map<String, dynamic> buildRequestBody(
    List<ChatMessage> messages,
    ChatSession session,
    ApiConfig config, {
    List<Tool>? tools, // 新增可选参数
  });
  ApiResponse parseStreamResponse(Map<String, dynamic> data, _StreamState state);
}

class DefaltProvider implements ApiProvider {
  @override
  String getRequestUrl(String baseUrl) => baseUrl;

  @override
  Map<String, dynamic> buildRequestBody(
    List<ChatMessage> messages,
    ChatSession session,
    ApiConfig config, {
    List<Tool>? tools,
  }) {
    final formattedMessages = _formatMessages(messages, session, config.provider);
    final Map<String, Object> requestBody;
    if(session.includeThinking) {
      requestBody = {
        "model": config.provider,
        "messages": formattedMessages,
        "max_tokens": session.maxTokens,
        "stream": true,
        "thinking": {"type": "enabled"},
      };
    }else{
      requestBody = {
        "model": config.provider,
        "messages": formattedMessages,
        "max_tokens": session.maxTokens,
        "stream": true,
        "thinking": {"type": "disabled"},
      };
    }

    // 新增：如果有工具配置，添加到请求中
    if (tools != null && tools.isNotEmpty) {
      requestBody["tools"] = tools.map((t) => t.toFunctionJson()).toList();
      requestBody["tool_choice"] = "auto"; // 或根据配置设置
    }

    return requestBody;
  }

@override
ApiResponse parseStreamResponse(Map<String, dynamic> data, _StreamState state) {
  final choices = data["choices"] as List?;
  if (choices == null || choices.isEmpty) {
    return ApiResponse();
  }

  final choice = choices[0];
  final delta = choice["delta"] as Map<String, dynamic>? ?? {};
  final finishReason = choice["finish_reason"] as String?;
  
  // String? content;
  bool hasToolCallDelta = false;
  StringBuffer mergedContent = StringBuffer();
  
  if (delta.containsKey("tool_calls")) {
    hasToolCallDelta = true;
    final toolCallsDelta = delta["tool_calls"] as List;
    
    for (final toolDelta in toolCallsDelta) {
      final index = toolDelta["index"] as int? ?? 0;
      final function = toolDelta["function"] as Map<String, dynamic>? ?? {};
      
      final id = toolDelta["id"] as String?;
      final name = function["name"] as String?;
      final arguments = function["arguments"] as String?;
      
      // 使用新的状态更新方法
      state.updateToolCallState(
        index: index,
        id: id,
        name: name,
        arguments: arguments,
      );
      
      debugPrint('工具调用累积 [index $index]: ${name ?? '续传'} arguments片段=${arguments ?? ''}');
    }
  }
  
  // 2. 处理推理内容
  final reasoning = delta["reasoning_content"] as String?;
  final regularContent = delta["content"] as String?;
  
  // 构建内容
  if (reasoning != null && reasoning.isNotEmpty) {
    if (!state.thinkingTagAdded) {
      mergedContent.write('<thinking>');
      state.thinkingTagAdded = true;
    }
    mergedContent.write(reasoning);
    state.hasReasoningContent = true;
  }
  
  if (regularContent != null && regularContent.isNotEmpty) {
    if (state.hasReasoningContent && state.thinkingTagAdded && !state.closingTagAdded) {
      mergedContent.write('</thinking>\n');
      state.closingTagAdded = true;
    }
    mergedContent.write(regularContent);
    // content = regularContent;
  }
  
  // 3. 处理流结束
  List<ToolCall>? finalToolCalls;
  bool isFinished = finishReason != null;
  
  if (isFinished) {
    // 检查是否需要关闭 thinking 标签
    if (state.hasReasoningContent && state.thinkingTagAdded && !state.closingTagAdded) {
      mergedContent.write('</thinking>\n');
      state.closingTagAdded = true;
    }
    
    // 构建工具调用（如果是工具调用结束）
    if (finishReason == 'tool_calls' || state.hasAnyToolCall) {
      finalToolCalls = state.buildFinalToolCalls();
      if (finalToolCalls?.isNotEmpty ?? false) {
        debugPrint('流结束，构建了 ${finalToolCalls!.length} 个工具调用');
        for (var tc in finalToolCalls!) {
          debugPrint('  - [${tc.index}] ${tc.name}: ${tc.arguments}');
        }
      }
    }
  }
  
  final finalContent = mergedContent.isNotEmpty ? mergedContent.toString() : null;
  
  return ApiResponse(
    content: finalContent,
    isFinished: isFinished,
    toolCalls: finalToolCalls,
    hasToolCallDelta: hasToolCallDelta || state.hasAnyToolCall,
  );
}



  List<Map<String, dynamic>> _formatMessages(
    List<ChatMessage> messages,
    ChatSession session,
    String model
  ) {
    // 获取当前UTC时间，用于统一判断所有URL的过期状态
    final nowUtc = DateTime.now().toUtc();

    final List<Map<String, dynamic>> formatted = [];

    for (var msg in messages) {
      dynamic content;

      // 新增：处理工具调用消息
      if (msg.isToolCall) {
        final toolCall = {
          "id": msg.toolCallId,
          "type": "function",
          "function": {
            "name": msg.toolName,
            "arguments": msg.toolArguments ?? '{}',
          }
        };
        formatted.add({
          "role": "assistant",
          "tool_calls": [toolCall]
        });
        continue;
      }
      
      // 新增：处理工具响应消息
      if (msg.isToolResponse) {
        formatted.add({
          "role": "tool",
          "tool_call_id": msg.toolCallId,
          "content": msg.content,
        });
        continue;
      }

      // 原有的消息处理逻辑
      // 尝试解析 content 是否为 JSON 数组
      try {
        final parsed = jsonDecode(msg.content);
        if (parsed is List) {
          // 检查是否符合多媒体消息格式
          bool isValidMultimedia = parsed.every((item) =>
              item is Map &&
              (item['type'] == 'text' || item['type'] == 'image_url') &&
              (item['type'] != 'text' || item['text'] != null) &&
              (item['type'] != 'image_url' || item['image_url']?['url'] != null));
          if (isValidMultimedia) {
            // 处理多媒体消息，检测图片URL过期状态
            final processedList = parsed.map((item) {
              if (item['type'] == 'image_url') {
                final imageUrl = item['image_url']['url'] as String? ?? '';
                if (model=='deepseek-v4-flash' || model=='deepseek-v4-pro'){
                  // 获取关联的文本内容（如果有）
                  String textContent = '';
                  final textItem = parsed.firstWhere(
                    (el) => el['type'] == 'text',
                    orElse: () => null
                  );
                  if (textItem != null) {
                    textContent = '\n${textItem['text']}';
                  }

                  // 替换为图片提示 + 关联文本
                  return {
                    'type': 'text',
                    'text': '[图片]\n$textContent'
                  };
                }
                // 检测URL是否过期
                if (_isUrlExpired(imageUrl, nowUtc)) {
                  // 获取关联的文本内容（如果有）
                  String textContent = '';
                  final textItem = parsed.firstWhere(
                    (el) => el['type'] == 'text',
                    orElse: () => null
                  );
                  if (textItem != null) {
                    textContent = '\n${textItem['text']}';
                  }

                  // 替换为过期提示 + 关联文本
                  return {
                    'type': 'text',
                    'text': '[图片已过期]\n$textContent'
                  };
                }
              }
              return item;
            }).toList();

            content = processedList;
          } else {
            content = msg.content;
          }
        } else {
          content = msg.content;
        }
      } catch (e) {
        // 解析失败，当作普通字符串处理
        content = msg.content;
      }
      // 过滤<thinking></thinking>内的思考内容
      if (content is String) {
        content = content.replaceAll(RegExp(r'<thinking>[\s\S]*?<\/thinking>'), '');
      }
      final role = msg.role == "assistant_reasoning" ? "assistant" : msg.role;
      final entry = {"role": role, "content": content};

      // merge reasoning entries into previous assistant
      if (msg.role == 'assistant_reasoning' && formatted.isNotEmpty && formatted.last['role'] == 'assistant') {
        final prev = formatted.last;
        prev['content'] = (prev['content'] ?? '') + (content is String ? content : content.toString());
      } else {
        formatted.add(entry);
      }
    }

    // prompt注入
    if (session.characterCard!=null){
      formatted.insert(0, {
        "role": "system",
        "content": '角色设定：${session.characterCard!.toPrompt()}',
      });
    }
    if (session.systemPrompt.isNotEmpty) {
      formatted.insert(0, {
        "role": "system",
        "content": session.systemPrompt,
      });
    }
    // 若最后一条AI消息为空，删去
    if (formatted.isNotEmpty) {
      final last = formatted.last;
      if (last['role'] == 'assistant' && (last['content'] == null || (last['content'] is String && (last['content'] as String).trim().isEmpty)) && !last.containsKey('tool_calls')) {
        formatted.removeLast();
      }
    }
    return formatted;
  }

  /// 检测TOS URL是否过期
  bool _isUrlExpired(String url, DateTime nowUtc) {
    try {
      final uri = Uri.parse(url);
      final queryParams = uri.queryParameters;

      // 获取日期和过期时间参数
      final tosDate = queryParams['X-Tos-Date'];
      final tosExpires = queryParams['X-Tos-Expires'];

      if (tosDate == null || tosExpires == null) return false;

      // 解析日期格式：20250702T064602Z
      final dateTime = DateTime.parse(
        tosDate.substring(0, 4) + '-' +  // 年
        tosDate.substring(4, 6) + '-' +  // 月
        tosDate.substring(6, 8) + 'T' + // 日
        tosDate.substring(9, 11) + ':' +// 时
        tosDate.substring(11, 13) + ':' +// 分
        tosDate.substring(13, 15) + 'Z'  // 秒
      );

      // 计算过期时间点
      final expiresIn = int.tryParse(tosExpires) ?? 0;
      final expirationTime = dateTime.add(Duration(seconds: expiresIn));

      // 检查是否过期
      return nowUtc.isAfter(expirationTime);
    } catch (e) {
      // 解析失败时视为过期
      return true;
    }
  }
}

class ApiProviderFactory {
  static ApiProvider getProvider(String providerName) {
    switch (providerName) {
      default:
        return DefaltProvider(); // 默认实现
    }
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static Stream<ApiResponse> sendMessageStream({
    required List<ChatMessage> messages,
    required ChatSession session,
    List<Tool>? tools, // 新增可选参数
    bool includeThinking = false, // 是否包含思考内容
  }) async* {
    final config = await IsarStorageService.getApiConfig(session.apiSource);
    if (config == null) throw Exception('未配置API服务');
    
    final provider = ApiProviderFactory.getProvider(config.modelName);
    yield* _sendStreamRequest(
      messages: messages,
      session: session,
      config: config,
      provider: provider,
      tools: tools, // 传递工具列表
    );
  }

  static Stream<ApiResponse> _sendStreamRequest({
    required List<ChatMessage> messages,
    required ChatSession session,
    required ApiConfig config,
    required ApiProvider provider,
    List<Tool>? tools, // 新增参数
  }) async* {
    _validateConfig(config);
    
    final requestBody = provider.buildRequestBody(messages, session,config, tools: tools);
    final uri = Uri.parse(provider.getRequestUrl(config.baseUrl));
    
    final response = await _sendHttpRequest(
      uri: uri,
      apiKey: config.apiKey,
      requestBody: requestBody,
    );

    yield* _handleStreamResponse(response, provider);
  }

  static void _validateConfig(ApiConfig config) {
    if (config.baseUrl.isEmpty) throw Exception('无效的API地址');
    if (config.apiKey.isEmpty) throw Exception('未配置API密钥');
  }

  static Future<http.StreamedResponse> _sendHttpRequest({
    required Uri uri,
    required String apiKey,
    required Map<String, dynamic> requestBody,
  }) async {
    final request = http.Request("POST", uri)
      ..headers.addAll({
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
        "Accept": "text/event-stream",
        "Cache-Control": "no-cache",
        "Connection": "keep-alive",
      })
      ..body = jsonEncode(requestBody);

    final client = http.Client();
    final response = await client.send(request);

    if (response.statusCode != 200) {
      final errorBody = await response.stream.bytesToString();
      throw Exception("API请求失败: ${response.statusCode}\n$errorBody");
    }

    return response;
  }

static Stream<ApiResponse> _handleStreamResponse(
    http.StreamedResponse response,
    ApiProvider provider,
  ) {
    final streamState = _StreamState();
    
    return response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .where((line) {
          // 打印所有接收到的行（调试用）
          if (line.isNotEmpty) {
            // debugPrint('原始流数据: $line');
          }
          return line.isNotEmpty && line != "data: [DONE]";
        })
        .map((line) {
          // 额外打印解析前的行
          // debugPrint('解析行: $line');
          return _parseJsonLine(line);
        })
        .map((data) {
          // 打印解析后的JSON
          // debugPrint('解析后的JSON: $data');
          return provider.parseStreamResponse(data, streamState);
        });
        // .where((response) => response.content != null || response.toolCalls != null);
  }

  static Map<String, dynamic> _parseJsonLine(String line) {
    final jsonStr = line.startsWith("data: ") ? line.substring(6) : line;
    try {
      return jsonDecode(jsonStr);
    } catch (e) {
      return {"error": "无效的JSON: $e"};
    }
  }
}