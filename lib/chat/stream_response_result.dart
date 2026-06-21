import 'package:summer/models/chat_message.dart';
import 'package:summer/models/tool.dart';

class StreamResponseResult {
  final String aiContent;
  final ChatMessage? aiMessage;
  final bool hasToolCalls;
  final List<ToolCall> toolCalls;
  final String? intermediateThinking;  // 新增：AI的中间思考内容

  StreamResponseResult({
    required this.aiContent,
    this.aiMessage,
    required this.hasToolCalls,
    required this.toolCalls,
    this.intermediateThinking,
  });

  factory StreamResponseResult.initial() {
    return StreamResponseResult(
      aiContent: '',
      hasToolCalls: false,
      toolCalls: [],
    );
  }

  StreamResponseResult copyWith({
    String? aiContent,
    ChatMessage? aiMessage,
    bool? hasToolCalls,
    List<ToolCall>? toolCalls,
    String? intermediateThinking,
  }) {
    return StreamResponseResult(
      aiContent: aiContent ?? this.aiContent,
      aiMessage: aiMessage ?? this.aiMessage,
      hasToolCalls: hasToolCalls ?? this.hasToolCalls,
      toolCalls: toolCalls ?? this.toolCalls,
      intermediateThinking: intermediateThinking ?? this.intermediateThinking,
    );
  }
}