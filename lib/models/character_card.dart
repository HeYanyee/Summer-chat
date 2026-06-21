import 'package:isar/isar.dart';
import 'chat_session.dart';
part 'character_card.g.dart'; 

@collection
class CharacterCard{
  Id id = Isar.autoIncrement; 

  @Index()
  late String name; // 角色名称

  late String description; // 角色描述
  late String longMemory; // 长期记忆
  late String shortMemory; // 短期记忆

  List<String> longMemoryHistory = [];    // 长期记忆历史
  List<String> shortMemoryHistory = [];   // 短期记忆历史

  String? avatar; // 角色头像地址（本地地址）
  String? shortDescription; // 简短描述

  // 刷新记忆相关
  int? refreshCount;
  DateTime? lastRefreshTime;
  int? refreshThreshold; 

  bool? hideReasoningBubbles;
  bool? autoReadReply;

  final session = IsarLink<ChatSession>();

  CharacterCard();

  // 修改长期记忆并保存历史（最多保留5个历史版本）
  void updateLongHistory(String newValue) {
    try{
      longMemoryHistory.add(longMemory);
    }catch(e){
      longMemoryHistory = List<String>.from(longMemoryHistory, growable: true);
      longMemoryHistory.add(longMemory);
    }
    if (longMemoryHistory.length > 5) {
      longMemoryHistory.removeAt(0);
    }
    longMemory = newValue;
  }

  // 修改短期记忆并保存历史（最多保留5个历史版本）
  void updateShortHistory(String newValue) {
    try{
      shortMemoryHistory.add(shortMemory);
    }catch(e){
      shortMemoryHistory = List<String>.from(shortMemoryHistory, growable: true);
      shortMemoryHistory.add(shortMemory);
    }    
    if (shortMemoryHistory.length > 5) {
      shortMemoryHistory.removeAt(0);
    }
    shortMemory = newValue;
  }

  // 回退长期记忆
  bool revertLongHistory() {
    longMemoryHistory = List<String>.from(longMemoryHistory, growable: true);
    if (longMemoryHistory.isNotEmpty) {
      longMemory = longMemoryHistory.removeLast();
      return true;
    }
    return false;
  }

  // 回退短期记忆
  bool revertShortHistory() {
    shortMemoryHistory = List<String>.from(shortMemoryHistory, growable: true);
    if (shortMemoryHistory.isNotEmpty) {
      shortMemory = shortMemoryHistory.removeLast();
      refreshCount = 0;
      lastRefreshTime = DateTime.now();
      return true;
    }
    return false;
  }

  String toPrompt() {
    return {
        'name': name,
        'description': description,
        'longMemory': longMemory,
        'shortMemory': shortMemory,
    }.toString();
  }

  // 便于 JSON 互转
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'longMemory': longMemory,
      'shortMemory': shortMemory,
      'avatar': avatar ?? '',
      'shortDescription': shortDescription ?? '',
      'longMemoryHistory': longMemoryHistory,
      'shortMemoryHistory': shortMemoryHistory,
      'refreshCount':refreshCount,
      'lastRefreshTime':lastRefreshTime?.toIso8601String(),
      'refreshThreshold': refreshThreshold ?? 50, // 默认50次
      'hideReasoningBubbles':hideReasoningBubbles,
      'autoReadReply':autoReadReply,
    };
  }

  factory CharacterCard.fromJson(Map<String, dynamic> json) {
    return CharacterCard()
      ..name = json['name'] as String? ?? '未命名角色'
      ..description = json['description'] as String? ?? ''
      ..longMemory = json['longMemory'] as String? ?? ''
      ..shortMemory = json['shortMemory'] as String? ?? ''
      ..avatar = json['avatar'] as String? ?? ''
      ..shortDescription = json['shortDescription'] as String? ?? ''
      ..longMemoryHistory = (json['longMemoryHistory'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(growable: true) ?? []
      ..shortMemoryHistory = (json['shortMemoryHistory'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(growable: true) ?? []
      ..refreshCount = json['refreshCount'] as int? ??0
      ..lastRefreshTime = json['lastRefreshTime'] != null
          ? DateTime.tryParse(json['lastRefreshTime'])
          : DateTime.now()
      ..refreshThreshold = json['refreshThreshold'] as int? ?? 50
      ..hideReasoningBubbles=json['hideReasoningBubbles']??false
      ..autoReadReply=json['autoReadReply']??false;
  }

  CharacterCard copyWith({
    String? name,
    String? description,
    String? longHistory,
    String? shortHistory,
    String? avatar,
    String? shortDescription,
    List<String>? longMemoryHistory,  
    List<String>? shortMemoryHistory,   
    int? refreshCount,
    DateTime? lastRefreshTime,
    int? refreshThreshold,
    bool? hideReasoningBubbles,
    bool? autoReadReply,
  }) {
    return CharacterCard()
      ..name = name ?? this.name
      ..description = description ?? this.description
      ..longMemory = longHistory ?? this.longMemory
      ..shortMemory = shortHistory ?? this.shortMemory
      ..avatar = avatar ?? this.avatar
      ..shortDescription = shortDescription ?? this.shortDescription
      ..longMemoryHistory = longMemoryHistory ?? this.longMemoryHistory
      ..shortMemoryHistory = shortMemoryHistory ?? this.shortMemoryHistory
      ..refreshCount = refreshCount ?? this.refreshCount
      ..lastRefreshTime = lastRefreshTime ?? this.lastRefreshTime
      ..refreshThreshold = refreshThreshold ?? this.refreshThreshold
      ..hideReasoningBubbles = hideReasoningBubbles??this.hideReasoningBubbles
      ..autoReadReply = autoReadReply ?? this.autoReadReply;
  }
}