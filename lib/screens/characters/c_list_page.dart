import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/chat_session.dart';
import 'c_chat_page.dart';
import '../../screens/tools/character_config_page.dart';
import '../../services/storage_service.dart';
import '../../models/character_card.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:rxdart/rxdart.dart';

class CharacterListPage extends StatefulWidget {
  const CharacterListPage({super.key});

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage> {
  List<CharacterCard> characterCards = [];
  StreamSubscription? _dbSubscription;

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _setupDatabaseListener();
  }

  void _setupDatabaseListener() async {
    final isar = await IsarStorageService.database;
    
    // 合并多个表的监听
    _dbSubscription = Rx.merge([
      isar.characterCards.watchLazy(),
      isar.chatSessions.watchLazy(),
    ]).debounceTime(const Duration(milliseconds: 300)).listen((_) {
      if (mounted) {
        _loadSessions();
      }
    });
  }

  @override
  void dispose() {
    _dbSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final loaded = await IsarStorageService.getAllCharacterCards();
    // 只在页面仍然挂载时更新状态
    if (mounted) {
      setState(() {
        characterCards = loaded;
      });
    }
  }
  
  String formatSessionTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(time.year, time.month, time.day);
    final diff = today.difference(msgDay).inDays;

    if (diff == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (diff == 1) {
      return '昨天';
    } else if (diff < 7) {
      const weekDays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      return weekDays[msgDay.weekday - 1];
    } else {
      return DateFormat('yyyy年M月d日').format(time);
    }
  }

  String? formatUserContent(String? user_content) {
    if (user_content == null || user_content.isEmpty) return null;
    String content = user_content;
    content = content.replaceAll(RegExp(r'<thinking>.*?</thinking>', dotAll: true), '');
    // 尝试解析形如 {time:...,text:...} 的内容，只显示 text 字段
    final reg = RegExp(r'^\{.*?text:(.*)\}$', dotAll: true);
    final match = reg.firstMatch(content);    
    if (match != null) {
      // 去除结尾可能的 '}'
      content = match.group(1)!.trim();
    }
    content = content.replaceAll(RegExp(r'[\n\r]+'), ' ');
    return content;
  }

  // 构建会话项
  Widget _buildSessionItem(BuildContext context, CharacterCard card) {
    final chatSession = card.session.value;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: FutureBuilder<String?>(
          future: (IsarStorageService.getCharacterAvatarById(card.id)),//TODO:需要修改
          builder: (context, snapshot) {
            // 头像获取成功
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
              return CircleAvatar(
                backgroundImage: FileImage(File(snapshot.data!)),
                radius: 24,
              );
            }
            // 无头像时显示默认图标
            return const CircleAvatar(
              child: Icon(Icons.person),
              radius: 24,
              backgroundColor: AppColors.primary,
            );
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                card.name, // 使用角色名作为标题
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chatSession?.lastMsgTime != null)
              Text(
                formatSessionTime(chatSession!.lastMsgTime!),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        subtitle: Text(
          (formatUserContent(chatSession?.lastMsgContent) ?? '还没有消息'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CharacterChatPage(characterCardId: card.id)),
          );
          if (mounted) {  // 加载修改了的会话
            final updatedCard = await IsarStorageService.getCharacterCardById(card.id);
            if (updatedCard != null) {
              setState(() {
                final index = characterCards.indexWhere((c) => c.id == card.id);
                if (index != -1) {
                  characterCards[index] = updatedCard;
                }
              });
            }
          }
        },
      ),
    );
  }

  // 新建角色并导航到配置页
  void _createNewCharacterAndNavigate() {
    final newCharacter = CharacterCard()
      ..name = ""
      ..description = ""
      ..longMemory = ""
      ..shortMemory = ""
      ..avatar = ""
      ..shortDescription = "";
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterConfigPage(initialCharacter: newCharacter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          '角色列表',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(onPressed: _createNewCharacterAndNavigate, icon: const Icon(Icons.add)),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: characterCards.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, size: 64, color: AppColors.secondary),
                SizedBox(height: 16),
                Text(
                  '当前暂无角色',
                  style: TextStyle(fontSize: 16, color: AppColors.secondary),
                ),
                SizedBox(height: 8),
                Text(
                  '点击右上角按钮配置角色',
                  style: TextStyle(fontSize: 14, color: AppColors.secondary),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: characterCards.length,
            itemBuilder: (context, index) {
              return _buildSessionItem(context, characterCards[index]);
            },
          ),
    );
  }
}