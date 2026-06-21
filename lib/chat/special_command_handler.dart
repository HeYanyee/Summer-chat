import 'package:summer/models/chat_message.dart';
import 'package:summer/models/chat_session.dart';
import 'package:summer/models/character_card.dart';
import 'package:summer/services/storage_service.dart';
import 'package:summer/services/api_service.dart';

enum SpecialCommands {
  help('%帮助%', ['%help%', '%H%']),
  refreshShortMemory('%刷新短期记忆%', ['%refreshShortMemory%', '%RS%']),
  refreshLongMemory('%刷新长期记忆%', ['%refreshLongMemory%', '%RL%']);
  
  final String primaryCommand;
  final List<String> aliases;
  
  const SpecialCommands(this.primaryCommand, [this.aliases = const []]);
  
  bool matches(String text) {
    return text == primaryCommand || aliases.contains(text);
  }
  
  static SpecialCommands? fromString(String text) {
    for (var cmd in SpecialCommands.values) {
      if (cmd.matches(text)) return cmd;
    }
    return null;
  }
}

class SpecialCommandHandler {
  final ChatSession session;
  final CharacterCard characterCard;
  final Future<void> Function(ChatMessage) onMessageAdded;
  final Future<String> Function(String) onGenerateResponse;
  final void Function(CharacterCard)? onCharacterCardUpdated;
  
  SpecialCommandHandler({
    required this.session,
    required this.characterCard,
    required this.onMessageAdded,
    required this.onGenerateResponse,
    this.onCharacterCardUpdated, // 新增刷新回调
  });
  
  /// 处理特殊命令
  Future<bool> handleCommand(String text) async {
    final command = SpecialCommands.fromString(text);
    if (command == null) return false;
    
    switch (command) {
      case SpecialCommands.refreshShortMemory:
        await _handleRefreshShortMemory();
        break;
      case SpecialCommands.refreshLongMemory:
        await _handleRefreshLongMemory();
        break;
      case SpecialCommands.help:
        await _handleHelp();
        break;
    }
    
    return true;
  }
  
  Future<void> _handleRefreshShortMemory() async {
    const commandString = "根据此前的全部上下文、你的人物设定和你当前的短期记忆补充和改写短期记忆。补充的短期记忆应简短地概括近期上下文内容，并衔接之前的短期记忆。你可以对之前的记忆进行简化，略去细节。短期记忆应不多于600字。输出且仅输出更新后的记忆文本。";
    
    final newMemory = await onGenerateResponse(commandString);
    // 过滤去newMemory中<thinking>...\<thinking>标记
    newMemory.replaceAll(RegExp(r'<thinking>.*?<\/thinking>', dotAll: true), '');
    characterCard.updateShortHistory(newMemory);
    // await IsarStorageService.saveCharacterCard(characterCard);
    onCharacterCardUpdated?.call(characterCard); // 新增
  }
  
  Future<void> _handleRefreshLongMemory() async {
    const commandString = "根据你的人物设定、你当前的长期记忆和短期记忆补充和改写长记忆。长期记忆应具有概括性，总结和提炼需要记忆的要点而非事件本身。避免重复角色描述。你可以对之前的记忆进行适当的简化、整理和总结。输出且仅输出更新后的记忆文本。";
    
    final newMemory = await onGenerateResponse(commandString);
    newMemory.replaceAll(RegExp(r'<thinking>.*?<\/thinking>', dotAll: true), '');
    characterCard.updateLongHistory(newMemory);
    // await IsarStorageService.saveCharacterCard(characterCard);
    onCharacterCardUpdated?.call(characterCard); // 新增
  }
  
  Future<void> _handleHelp() async {
    final helpMessage = ChatMessage()
      ..id = DateTime.now().millisecondsSinceEpoch.toString()
      ..sessionId = session.id
      ..content = _buildHelpContent()
      ..role = 'notice'
      ..timestamp = DateTime.now();
    
    await onMessageAdded(helpMessage);
  }
  
  String _buildHelpContent() {
    final buffer = StringBuffer();
    buffer.writeln('🛠️ **可用命令**\n');
    
    for (final command in SpecialCommands.values) {
      buffer.writeln('【${command.primaryCommand}】 - ${_getCommandDescription(command)}');
      if (command.aliases.isNotEmpty) {
        buffer.writeln('- 简便命令：${command.aliases.join(', ')}');
      }
    }
    
    buffer.writeln('\n输入上述任意命令即可执行对应操作');
    return buffer.toString();
  }
  
  String _getCommandDescription(SpecialCommands command) {
    switch (command) {
      case SpecialCommands.refreshShortMemory:
        return '更新角色短期记忆';
      case SpecialCommands.refreshLongMemory:
        return '更新角色长期记忆';
      case SpecialCommands.help:
        return '显示此帮助信息';
    }
  }
}