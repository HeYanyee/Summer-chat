import 'dart:convert';

import 'package:summer/models/chat_message.dart';
import 'package:summer/models/character_card.dart';
import 'package:summer/models/chat_session.dart';

class MessageProcessor {
  final ChatSession session;
  final CharacterCard characterCard;
  final List<ChatMessage> messages;
  
  MessageProcessor({
    required this.session,
    required this.characterCard,
    required this.messages,
  });
  
  /// 获取上下文消息列表
  List<ChatMessage> getContextMessages(int maxContextLength) {
      // 过滤掉 notice 消息
      final raw = messages.where((msg) => msg.role != 'notice').toList();
      
      // 首先，确保 tool 消息与其对应的 tool_calls 消息一起保留
      final filtered = _filterMessagesWithToolPairs(raw);
      
      // 然后处理版本组和推理消息
      final withVersions = _filterUnchosenVersions(filtered);
      final merged = _mergeReasoningMessages(withVersions);
      
      // 截取最近的消息
      if (merged.length <= maxContextLength) {
        return merged;
      }
      
      // 截取时确保不破坏 tool 消息的配对
      return _safeSublist(merged, merged.length - maxContextLength, merged.length);
    }

    List<ChatMessage> _filterMessagesWithToolPairs(List<ChatMessage> messages) {
    final result = <ChatMessage>[];
    final Set<String> toolCallIds = {};
    
    // 第一遍：找出所有 tool_calls 消息的 ID
    for (var msg in messages) {
      if (msg.isToolCall) {
        // 假设 tool_calls 消息的内容中包含 tool_call_id
        try {
          final data = jsonDecode(msg.content);
          if (data['tool_call_id'] != null) {
            toolCallIds.add(data['tool_call_id']);
          }
        } catch (_) {
          // 如果不是 JSON 格式，跳过
        }
      }
    }
    
    // 第二遍：构建消息列表，确保配对
    for (var msg in messages) {
      if (msg.role == 'tool') {
        // 检查这个 tool 消息是否有对应的 tool_calls 消息
        try {
          final data = jsonDecode(msg.content);
          if (data['tool_call_id'] != null && toolCallIds.contains(data['tool_call_id'])) {
            result.add(msg);
          }
        } catch (_) {
          // 如果不是 JSON 格式，可能是旧格式，保留
          result.add(msg);
        }
      } else {
        result.add(msg);
      }
    }
    
    return result;
  }
  
  /// 安全地截取子列表，确保不破坏 tool 消息的配对
  List<ChatMessage> _safeSublist(List<ChatMessage> messages, int start, int end) {
    if (start <= 0) return messages.sublist(start, end);
    
    final result = <ChatMessage>[];
    final Map<String, List<ChatMessage>> toolGroups = {};
    
    // 将消息按 tool 调用分组
    for (var i = start; i < end; i++) {
      final msg = messages[i];
      
      if (msg.isToolCall) {
        // 如果是 tool_calls 消息，尝试获取其 ID
        try {
          final data = jsonDecode(msg.content);
          final toolCallId = data['tool_call_id'] ?? msg.id;
          toolGroups.putIfAbsent(toolCallId, () => []).add(msg);
        } catch (_) {
          result.add(msg);
        }
      } else if (msg.role == 'tool') {
        // 如果是 tool 响应消息，找到对应的 tool_calls 并一起添加
        try {
          final data = jsonDecode(msg.content);
          final toolCallId = data['tool_call_id'];
          if (toolCallId != null && toolGroups.containsKey(toolCallId)) {
            // 如果这个 tool 调用的 tool_calls 已经在结果中，添加 tool 响应
            result.add(msg);
          } else if (i > 0) {
            // 检查前一条消息是否是对应的 tool_calls
            final prevMsg = messages[i - 1];
            if (prevMsg.isToolCall) {
              result.add(prevMsg);
              result.add(msg);
              i++; // 跳过下一条已处理的消息
            }
          }
        } catch (_) {
          result.add(msg);
        }
      } else {
        result.add(msg);
      }
    }
    
    return result;
  }

  /// 过滤掉未选中的版本组消息
  List<ChatMessage> _filterUnchosenVersions(List<ChatMessage> raw) {
    final List<ChatMessage> filtered = [];
    
    for (var i = 0; i < raw.length; i++) {
      final msg = raw[i];
      
      if (msg.role == 'assistant_reasoning') {
        final prevAssistant = _findPreviousAssistant(raw, i);
        if (prevAssistant != null && _shouldIncludeMessage(prevAssistant)) {
          filtered.add(msg);
        }
      } else if (_shouldIncludeMessage(msg)) {
        filtered.add(msg);
      }
    }
    
    return filtered;
  }
  
  /// 判断消息是否应该包含在上下文中
  bool _shouldIncludeMessage(ChatMessage msg) {
    return msg.versionGroup == null || msg.isChosen;
  }
  
  /// 查找之前的助手消息
  ChatMessage? _findPreviousAssistant(List<ChatMessage> messages, int currentIndex) {
    for (var j = currentIndex - 1; j >= 0; j--) {
      if (messages[j].role == 'assistant') return messages[j];
    }
    return null;
  }
  
  /// 合并推理消息到前一条助手消息
  List<ChatMessage> _mergeReasoningMessages(List<ChatMessage> filtered) {
    final List<ChatMessage> merged = [];
    
    for (var msg in filtered) {
      if (msg.role == 'assistant_reasoning' && 
          merged.isNotEmpty && 
          merged.last.role == 'assistant') {
        merged.last.content = '${merged.last.content}${msg.content}';
      } else {
        merged.add(msg);
      }
    }
    
    return merged;
  }
  
  /// 获取消息在版本组中的信息
  Map<String, int> getVersionInfo(ChatMessage msg) {
    if (msg.versionGroup == null) {
      return {'index': 0, 'total': 0};
    }
    
    final siblings = messages
        .where((m) => m.versionGroup == msg.versionGroup)
        .toList()
      ..sort((a, b) => a.versionOrder.compareTo(b.versionOrder));
    
    final index = siblings.indexWhere((m) => m.id == msg.id);
    
    return {
      'index': index == -1 ? 0 : index + 1,
      'total': siblings.length,
    };
  }
  
  /// 获取最后一条助手消息
  ChatMessage? getLastAssistantMessage() {
    try {
      return messages.lastWhere(
        (m) => m.role == 'assistant' && !m.isToolCall
      );
    } catch (_) {
      return null;
    }
  }

  ChatMessage? getLastUserMessage() {
    try {
      return messages.lastWhere(
        (m) => m.role == 'user'
      );
    } catch (_) {
      return null;
    }
  }
  
  /// 获取未选中的版本组消息
  List<ChatMessage> getUnusedVersions() {
    if (messages.isEmpty) return [];
    
    final lastAi = getLastAssistantMessage();
    if (lastAi?.versionGroup == null) return [];
    
    return messages
        .where((m) => m.versionGroup == lastAi!.versionGroup && !m.isChosen)
        .toList();
  }
}