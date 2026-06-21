import 'package:summer/models/chat_message.dart';
import 'package:summer/services/storage_service.dart';

class VersionGroupManager {
  final int sessionId;
  final List<ChatMessage> messages;
  
  VersionGroupManager({
    required this.sessionId,
    required this.messages,
  });
  
  Future<void> markVersionUnchosen(String groupId) async {
    final groupMessages = messages.where((m) => m.versionGroup == groupId).toList();
    for (final msg in groupMessages) {
      msg.isChosen = false;
      await IsarStorageService.updateMessage(msg);
    }
    // 更新内存中的 messages 列表
  }
  /// 创建新的版本组ID
  String createGroupId() {
    return '${sessionId}_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  /// 选择版本
  Future<void> chooseVersion(ChatMessage targetMessage) async {
    final groupId = targetMessage.versionGroup;
    if (groupId == null) return;
    
    for (var msg in messages.where((m) => m.versionGroup == groupId)) {
      msg.isChosen = (msg.id == targetMessage.id);
      await IsarStorageService.updateMessage(msg);
    }
  }
  
  /// 清理未使用的版本
  Future<List<ChatMessage>> cleanupUnusedVersions() async {
    if (messages.isEmpty) return [];
    
    ChatMessage? lastAi;
    try {
      lastAi = messages.lastWhere(
        (m) => m.role == 'assistant' && m.versionGroup != null
      );
    } catch (_) {
      return [];
    }
    
    if (lastAi.versionGroup == null) return [];
    
    final toRemove = messages
        .where((m) => m.versionGroup == lastAi!.versionGroup && !m.isChosen)
        .toList();
    
    if (toRemove.isNotEmpty) {
      await IsarStorageService.deleteMessagesList(toRemove);
    }
    
    return toRemove;
  }
  
  /// 为消息创建新版本
  ChatMessage createNewVersion({
    required ChatMessage originalMessage,
    required String content,
    int versionOrder = 0,
  }) {
    return ChatMessage()
      ..id = DateTime.now().millisecondsSinceEpoch.toString()
      ..sessionId = sessionId
      ..role = originalMessage.role
      ..content = content
      ..timestamp = DateTime.now()
      ..versionGroup = originalMessage.versionGroup ?? createGroupId()
      ..versionOrder = versionOrder
      ..isChosen = true;
  }
}