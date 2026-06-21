import 'package:isar/isar.dart';
import 'chat_message.dart';
import 'character_card.dart';
import '../services/storage_service.dart';

part 'chat_session.g.dart';

@collection
class ChatSession {
  Id id = Isar.autoIncrement;
  late String title;
  final messages = IsarLinks<ChatMessage>();
  late String systemPrompt;
  late bool enabledTools;
  bool isCharacterSession;

  @Index()
  String? character; 

  String? lastMsgContent;
  DateTime? lastMsgTime;
  int? catchingId;

  @ignore
  CharacterCard? characterCard; // 无需持久化

  late String apiSource; // API来源
  late double temperature; // 温度参数 (0.0-1.0)
  late int maxContextLength; // 上下文长度（消息条数）
  late double topP; // Top-p 采样 (0.0-1.0)
  late double frequencyPenalty; // 频率惩罚 (-2.0 到 2.0)
  late double presencePenalty; // 存在惩罚 (-2.0 到 2.0)
  late bool streamResponse; // 是否流式响应
  late int maxTokens; // 最大生成token数
  late bool includeThinking; // 是否包含思考内容

  // 构造函数设置默认值
  ChatSession({
    this.title = "新对话",
    this.lastMsgContent,
    this.lastMsgTime,
    this.character,
    this.characterCard,
    this.systemPrompt = "You are a helpful assistant.",
    this.apiSource = "暂未设置",
    this.temperature = 0.7,
    this.maxContextLength = 20,
    this.topP = 0.9,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
    this.streamResponse = true,
    this.maxTokens = 2000,
    this.isCharacterSession = false,
    this.enabledTools = false,
    this.includeThinking = false,
  }) ;
  
  Future<void> updateLastMessage(ChatMessage lastMsg) async {
    final isar = await IsarStorageService.database;
    await isar.writeTxn(() async {
      // 每次都重新获取 session 实例，避免 link moved
      final fresh = await isar.chatSessions.get(id);
      if (fresh != null) {
        fresh.lastMsgContent = lastMsg.content;
        fresh.lastMsgTime = lastMsg.timestamp;
        await isar.chatSessions.put(fresh);
      }
    });
  }

  Future<void> deleteMessagesAfter(ChatMessage targetMessage) async {
    final isar = await IsarStorageService.database;
    
    await isar.writeTxn(() async {
      // 1. 查询需要删除的消息
      final messagesToDelete = await isar.chatMessages
          .filter()
          .sessionIdEqualTo(targetMessage.sessionId)
          .timestampGreaterThan(targetMessage.timestamp)
          .findAll();

      // 2. 从链接中移除这些消息
      messages.removeAll(messagesToDelete);
      
      // 3. 批量删除消息
      await isar.chatMessages.deleteAll(messagesToDelete.map((e) => e.isarId).toList());

      // 4. 更新会话的最后消息信息
      final session = await isar.chatSessions.get(id);
      if (session != null) {
        // 获取当前会话中最后一条消息
        final lastMsg = await isar.chatMessages
            .filter()
            .sessionIdEqualTo(id)
            .sortByTimestampDesc()
            .findFirst();
        
        // 更新会话信息 - 修复 save() 方法不存在的问题
        session.lastMsgContent = lastMsg?.content;
        session.lastMsgTime = lastMsg?.timestamp;
        
        // 使用 put() 方法保存会话更新
        await isar.chatSessions.put(session);
      }
    });
  }

  Future<void> updateSettings({
    String? character,
    String? systemPrompt,
    String? apiSource,
    double? temperature,
    int? maxContextLength,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    bool? streamResponse,
    int? maxTokens,
    bool? enableTools,
    bool? includeThinking,
  }) async {
    final isar = await IsarStorageService.database;
    await isar.writeTxn(() async {
    if (character != null) this.character = character;
    if (systemPrompt != null) this.systemPrompt = systemPrompt;
    if (apiSource != null) this.apiSource = apiSource;
    if (temperature != null) this.temperature = temperature;
    if (maxContextLength != null) this.maxContextLength = maxContextLength;
    if (topP != null) this.topP = topP;
    if (frequencyPenalty != null) this.frequencyPenalty = frequencyPenalty;
    if (presencePenalty != null) this.presencePenalty = presencePenalty;
    if (streamResponse != null) this.streamResponse = streamResponse;
    if (maxTokens != null) this.maxTokens = maxTokens;
    if (enableTools != null) this.enabledTools = enableTools;
    if (includeThinking != null) this.includeThinking = includeThinking;
    await isar.chatSessions.put(this);
    });
  }

  Future<void> updateFromJson(Map<String, dynamic> json) async {
    final isar = await IsarStorageService.database;
    await isar.writeTxn(() async {
      // 更新基本字段
      if (json.containsKey('title')) title = json['title'] as String;
      if (json.containsKey('systemPrompt')) systemPrompt = json['systemPrompt'] as String;
      if (json.containsKey('isCharacterSession')) isCharacterSession = json['isCharacterSession'] as bool;
      if (json.containsKey('character')) character = json['character'] as String?;
      if (json.containsKey('lastMsgContent')) lastMsgContent = json['lastMsgContent'] as String?;
      if (json.containsKey('lastMsgTime')) {
        lastMsgTime = json['lastMsgTime'] != null 
            ? DateTime.tryParse(json['lastMsgTime'] as String)
            : null;
      }
      if (json.containsKey('catchingId')) catchingId = json['catchingId'] as int?;
      
      // 更新设置字段
      if (json.containsKey('apiSource')) apiSource = json['apiSource'] as String;
      if (json.containsKey('temperature')) temperature = (json['temperature'] as num).toDouble();
      if (json.containsKey('maxContextLength')) maxContextLength = json['maxContextLength'] as int;
      if (json.containsKey('topP')) topP = (json['topP'] as num).toDouble();
      if (json.containsKey('frequencyPenalty')) {
        frequencyPenalty = (json['frequencyPenalty'] as num).toDouble();
      }
      if (json.containsKey('presencePenalty')) {
        presencePenalty = (json['presencePenalty'] as num).toDouble();
      }
      if (json.containsKey('streamResponse')) streamResponse = json['streamResponse'] as bool;
      if (json.containsKey('maxTokens')) maxTokens = json['maxTokens'] as int;
      if (json.containsKey('enabledToolIds')) enabledTools = json['enabledToolIds'] as bool;
      if (json.containsKey('includeThinking')) includeThinking = json['includeThinking'] as bool;
      
      // 保存更新到数据库
      await isar.chatSessions.put(this);
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'systemPrompt': systemPrompt,
      'isCharacterSession': isCharacterSession,
      'character': character,
      'lastMsgContent': lastMsgContent,
      'lastMsgTime': lastMsgTime?.toIso8601String(),
      'catchingId': catchingId,
      'apiSource': apiSource,
      'temperature': temperature,
      'maxContextLength': maxContextLength,
      'topP': topP,
      'frequencyPenalty': frequencyPenalty,
      'presencePenalty': presencePenalty,
      'streamResponse': streamResponse,
      'maxTokens': maxTokens,
      'enabledToolIds': enabledTools,
      'includeThinking': includeThinking,
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      title: json['title'] as String? ?? "新对话",
      lastMsgContent: json['lastMsgContent'] as String?,
      lastMsgTime: json['lastMsgTime'] != null
          ? DateTime.tryParse(json['lastMsgTime'])
          : null,
      character: json['character'] as String?,
      systemPrompt: json['systemPrompt'] as String? ?? "",
      apiSource: json['apiSource'] as String? ?? "暂无设置",
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxContextLength: json['maxContextLength'] as int? ?? 20,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
      frequencyPenalty: (json['frequencyPenalty'] as num?)?.toDouble() ?? 0.0,
      presencePenalty: (json['presencePenalty'] as num?)?.toDouble() ?? 0.0,
      streamResponse: json['streamResponse'] as bool? ?? true,
      maxTokens: json['maxTokens'] as int? ?? 2000,
      isCharacterSession: json['isCharacterSession'] as bool? ?? false,
      enabledTools: json['enabledToolIds'] as bool? ?? false,
      includeThinking: json['includeThinking'] as bool? ?? false,
    )
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..catchingId = json['catchingId'] as int?;
  }

  ChatSession copyWith({
  String? title,
  String? character,
  CharacterCard? characterCard,
  String? systemPrompt,
  String? lastMsgContent,
  DateTime? lastMsgTime,
  String? apiSource,
  double? temperature,
  int? maxContextLength,
  double? topP,
  double? frequencyPenalty,
  double? presencePenalty,
  bool? streamResponse,
  int? maxTokens,
  bool? enabledToolIds,
  bool? includeThinking,
}) {
  final newSession = ChatSession(
    title: title ?? this.title,
    lastMsgContent: lastMsgContent ?? this.lastMsgContent,
    lastMsgTime: lastMsgTime ?? this.lastMsgTime,
    character: character ?? this.character,
    characterCard: characterCard ?? this.characterCard,
    systemPrompt: systemPrompt ?? this.systemPrompt,
    apiSource: apiSource ?? this.apiSource,
    temperature: temperature ?? this.temperature,
    maxContextLength: maxContextLength ?? this.maxContextLength,
    topP: topP ?? this.topP,
    frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
    presencePenalty: presencePenalty ?? this.presencePenalty,
    streamResponse: streamResponse ?? this.streamResponse,
    maxTokens: maxTokens ?? this.maxTokens,
    isCharacterSession: this.isCharacterSession,
    enabledTools: enabledToolIds ?? this.enabledTools,
    includeThinking: includeThinking ?? this.includeThinking,
  )..id = id; // 保留原始 ID
  return newSession;
}
}


