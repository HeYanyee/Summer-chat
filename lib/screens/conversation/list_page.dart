import 'dart:async';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import '../../services/storage_service.dart';
import '../../models/chat_session.dart';
import '../../models/app_settings.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<ChatSession> sessions = [];
  StreamSubscription? _dbSubscription;
  ChatSession? _sessionToRename; // 用于跟踪正在重命名的会话

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _setupDatabaseListener();
  }

  void _setupDatabaseListener() async {
    final isar = await IsarStorageService.database;
    _dbSubscription = isar.chatSessions.watchLazy().listen((_) {
      if(mounted)  {_loadSessions();}
    });
  }

  @override
  void dispose() {
    _dbSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final loaded = await IsarStorageService.loadSessions();
    // 过滤掉角色卡片专属会话
    final filtered = loaded.where((session) => !session.isCharacterSession).toList();
    if (mounted) {
      setState(() => sessions = filtered);
    }
  }
  
  Future<void> _addSession() async {
    final config = await _getDefaultApiConfig();
    final newSession = ChatSession()
      ..title = "新会话"
      ..systemPrompt = ""
      ..messages.clear();
    await IsarStorageService.saveSessions([...sessions, newSession]);
  }

    /// 获取默认API配置
  static Future<ApiConfig> _getDefaultApiConfig() async {
    final settings = await IsarStorageService.getApiConfigs();
    try {
      final defaultConfig = settings[0];
      return defaultConfig;
    } catch (e) {
      // 如果获取配置失败，返回一个空的ApiConfig
      return ApiConfig();
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

  // 重命名会话
  Future<void> _renameSession(BuildContext context, ChatSession session) async {
    final TextEditingController controller = TextEditingController(text: session.title);
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重命名会话'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '输入新标题',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
              '取消',
              style: TextStyle(color: AppColors.warmGrey400),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  session.title = controller.text.trim();
                  await IsarStorageService.updateSession(session);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 删除会话
  Future<void> _deleteSession(BuildContext context, ChatSession session) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除会话'),
          content: const Text('确定要删除这个会话吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await IsarStorageService.deleteSession(session.id);
                if (mounted) Navigator.pop(context);
              },
              child: const Text(
                '删除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // 构建会话项
  Widget _buildSessionItem(BuildContext context, ChatSession session) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                session.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (session.lastMsgTime != null)
              Text(
                formatSessionTime(session.lastMsgTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
            ),
          ],
        ),
        subtitle: Text(
          (session.lastMsgContent ?? '还没有消息').replaceAll('\n', ' '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'rename') {
              _renameSession(context, session);
            } else if (value == 'delete') {
              _deleteSession(context, session);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('重命名'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatPage(sessionId: session.id)),
          );
        },
      ),
    );
  }

  Future<void> _importSession() async {
    await IsarStorageService.importSessionFromJson(
      context: context,
      onSessionImported: (ChatSession session) {
        setState(() {
          sessions.add(session);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          '对话列表',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add, color: Colors.white),
            onSelected: (value) {
              if (value == 'new') {
                _addSession();
              } else if (value == 'import') {
                _importSession();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'new',
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('新对话'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'import',
                  child: Row(
                    children: [
                      Icon(Icons.file_upload, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('导入对话'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: sessions.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, size: 64, color: AppColors.secondary),
                SizedBox(height: 16),
                Text(
                  '当前暂无对话',
                  style: TextStyle(fontSize: 16, color: AppColors.secondary),
                ),
                SizedBox(height: 8),
                Text(
                  '点击右上角按钮开始新对话',
                  style: TextStyle(fontSize: 14, color: AppColors.secondary),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              return _buildSessionItem(context, sessions[index]);
            },
          ),
    );
  }
}