import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:summer/models/tool.dart';
import 'package:summer/tools/note_tool.dart';
import 'package:summer/tools/tool_list.dart';
import '../utils/constants.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';
import '../models/app_settings.dart';
import '../models/character_card.dart';
import '../services/tos_service.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async'; // 引入 Completer
import 'package:flutter/foundation.dart'; // 引入 kDebugMode

// 导入操作选项
enum ImportCharacterAction {
  cancel,
  rename,
  overwrite,
}

class ToolStorageService {
  static final ToolStorageService _instance = ToolStorageService._internal();
  factory ToolStorageService() => _instance;
  ToolStorageService._internal();

  static const String _toolsFileName = 'custom_tools.json';
  static const String _presetToolsFileName = 'preset_tools.json';
  static const String _wallpaperPathFileName = 'wallpaper_path.txt';
  
  late String _toolsFilePath;
  late String _presetToolsFilePath;
  late String _wallpaperPathFilePath;

  // 初始化文件路径
  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _toolsFilePath = '${dir.path}/$_toolsFileName';
    _presetToolsFilePath = '${dir.path}/$_presetToolsFileName';
    _wallpaperPathFilePath = '${dir.path}/$_wallpaperPathFileName';
    
    // 确保预设工具文件存在
    await _ensurePresetToolsFile();
  }

  /// 保存壁纸文件路径到本地（覆盖）
  Future<void> saveWallpaperPath(String filePath) async {
    try {
      final file = File(_wallpaperPathFilePath);
      await file.writeAsString(filePath);
    } catch (e) {
      debugPrint('保存壁纸路径失败: $e');
    }
  }

  /// 读取已保存的壁纸路径，如果不存在返回null
  Future<String?> loadWallpaperPath() async {
    try {
      final file = File(_wallpaperPathFilePath);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return content.isEmpty ? null : content;
    } catch (e) {
      debugPrint('读取壁纸路径失败: $e');
      return null;
    }
  }

  /// 删除已保存的壁纸路径
  Future<void> deleteWallpaperPath() async {
    try {
      final file = File(_wallpaperPathFilePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('删除壁纸路径失败: $e');
    }
  }

  // 确保预设工具文件存在
  Future<void> _ensurePresetToolsFile() async {
    final file = File(_presetToolsFilePath);
    if (!await file.exists()) {
      // 创建默认预设工具
      final presetTools = PredefinedTools.getAllPredefinedTools();
      await savePresetTools(presetTools);
    }
  }

  // ========== 预设工具（只读） ==========
  
  /// 加载预设工具列表
  Future<List<Tool>> loadPresetTools() async {
    try {
      final file = File(_presetToolsFilePath);
      if (!await file.exists()) {
        return [];
      }
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Tool.fromJson(json)).toList();
    } catch (e) {
      debugPrint('加载预设工具失败: $e');
      return [];
    }
  }

  /// 保存预设工具（通常用于初始化）
  Future<void> savePresetTools(List<Tool> tools) async {
    try {
      final jsonList = tools.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final file = File(_presetToolsFilePath);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('保存预设工具失败: $e');
    }
  }

  // ========== 自定义工具（可读写） ==========

  /// 加载所有工具（预设 + 自定义）
  Future<List<Tool>> loadAllTools() async {
    final presetTools = await loadPresetTools();
    final customTools = await loadCustomTools();
    return [...presetTools, ...customTools];
  }

  /// 加载自定义工具
  Future<List<Tool>> loadCustomTools() async {
    try {
      final file = File(_toolsFilePath);
      if (!await file.exists()) {
        return [];
      }
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Tool.fromJson(json)).toList();
    } catch (e) {
      debugPrint('加载自定义工具失败: $e');
      return [];
    }
  }

  /// 保存工具（覆盖保存）
  Future<void> saveTools(List<Tool> tools) async {
    try {
      final jsonList = tools.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final file = File(_toolsFilePath);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('保存工具失败: $e');
    }
  }

  /// 添加或更新工具
  Future<void> upsertTool(Tool tool) async {
    final tools = await loadCustomTools();
    final index = tools.indexWhere((t) => t.id == tool.id);
    
    if (index >= 0) {
      tools[index] = tool; // 更新
    } else {
      tools.add(tool); // 添加
    }
    
    await saveTools(tools);
  }

  /// 删除工具
  Future<void> deleteTool(String toolId) async {
    final tools = await loadCustomTools();
    tools.removeWhere((t) => t.id == toolId);
    await saveTools(tools);
  }

  /// 根据ID获取工具
  Future<Tool?> getToolById(String toolId) async {
    final allTools = await loadAllTools();
    try {
      return allTools.firstWhere((t) => t.id == toolId);
    } catch (e) {
      return null;
    }
  }

  /// 根据名称获取工具
  Future<Tool?> getToolByName(String toolName) async {
    final allTools = await loadAllTools();
    try {
      return allTools.firstWhere((t) => t.name == toolName);
    } catch (e) {
      return null;
    }
  }

  /// 根据ID列表获取工具
  Future<List<Tool>> getToolsByIds(List<String> toolIds) async {
    final allTools = await loadAllTools();
    return allTools.where((t) => toolIds.contains(t.id)).toList();
  }

  /// 获取所有启用的工具
  Future<List<Tool>> getEnabledTools() async {
    final allTools = await loadAllTools();
    return allTools.where((t) => t.enabled).toList();
  }

  /// 重置自定义工具（清空）
  Future<void> resetCustomTools() async {
    await saveTools([]);
  }

  /// 导出工具到JSON字符串
  Future<String> exportToolsToJson() async {
    final tools = await loadCustomTools();
    return jsonEncode(tools.map((t) => t.toJson()).toList());
  }

  /// 从JSON字符串导入工具
  Future<void> importToolsFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final tools = jsonList.map((json) => Tool.fromJson(json)).toList();
      await saveTools(tools);
    } catch (e) {
      throw Exception('导入工具失败: $e');
    }
  }
}

class IsarStorageService {
  static int _settingsId=1;
  static Isar? _isar;
  static bool _isInitializing = false;
  static Completer<Isar>? _dbCompleter;

  static Future<Isar> get database async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    
    // 防止重复初始化
    if (_isInitializing && _dbCompleter != null) {
      return await _dbCompleter!.future;
    }

    _isInitializing = true;
    _dbCompleter = Completer<Isar>();
    
    try {
      _isar = await _initDb();
      _dbCompleter!.complete(_isar);
      return _isar!;
    } catch (e) {
      _dbCompleter!.completeError(e);
      throw Exception('Failed to initialize database: $e');
    } finally {
      _isInitializing = false;
    }
  }

  static Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    // 在这里添加isar的实体类
    return await Isar.open(
      [
        ChatSessionSchema, 
        ChatMessageSchema, 
        AppSettingsSchema, 
        ApiConfigSchema, 
        TosConfigSchema, 
        LocationConfigSchema,
        CharacterCardSchema,
        NoteSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
    );
  }
  
  static Future<void> closeDatabase() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
    }
    _isar = null;
    _dbCompleter = null;
  }
  
  // 清除所有与数据库相关的状态
  static void reset() {
    _isar = null;
    _dbCompleter = null;
  }

  /// 工具相关（代理到 ToolStorageService）
  static Future<List<Tool>> loadAllTools() async {
    final toolStorage = ToolStorageService();
    await toolStorage.initialize();
    return await toolStorage.loadAllTools();
  }

  static Future<Tool?> getTool(String toolId) async {
    final toolStorage = ToolStorageService();
    await toolStorage.initialize();
    return await toolStorage.getToolById(toolId);
  }

  static Future<Tool?> getToolByName(String toolName) async {
    final toolStorage = ToolStorageService();
    await toolStorage.initialize();
    return await toolStorage.getToolByName(toolName);
  }

  static Future<List<Tool>> getToolsByIds(List<String> toolIds) async {
    final toolStorage = ToolStorageService();
    await toolStorage.initialize();
    return await toolStorage.getToolsByIds(toolIds);
  }

  static Future<List<Tool>> getEnabledTools() async {
    final toolStorage = ToolStorageService();
    await toolStorage.initialize();
    return await toolStorage.getEnabledTools();
  }

  static Future<void> saveTool(Tool tool) async {
    final toolStorage = ToolStorageService();
    await toolStorage.initialize();
    await toolStorage.upsertTool(tool);
  }

  static Future<void> deleteTool(String toolId) async {
    final toolStorage = ToolStorageService();
    await toolStorage.initialize();
    await toolStorage.deleteTool(toolId);
  }

  static Future<List<Tool>> loadPresetTools() async {
    final toolStorage = ToolStorageService();
    await toolStorage.initialize();
    return await toolStorage.loadPresetTools();
  }


  /// 对话相关
  // 添加加载会话的方法
  static Future<List<ChatSession>> loadSessions() async {
    final isar = await database;
    return await isar.chatSessions.where().findAll();
  }

  // 添加保存会话的方法
  static Future<void> saveSessions(List<ChatSession> sessions) async {
    final isar = await database;
    await isar.writeTxn(() async {
      await isar.chatSessions.putAll(sessions);
    });
  }

  static Future<ChatSession?> getSession(int sessionId) async {
    final isar = await database;
    return await isar.chatSessions.get(sessionId);
  }

  // 保存单条消息，并自动更新对应会话的lastMsgContent和lastMsgTime
  static Future<void> saveMessage(ChatMessage msg) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 保存消息
      await isar.chatMessages.put(msg);

      // 查找并更新对应会话的最近消息内容和时间
      final session = await isar.chatSessions.get(msg.sessionId!);
      if (session != null) {
        session.lastMsgContent = msg.content;
        session.lastMsgTime = msg.timestamp;
        await isar.chatSessions.put(session);
      }
    });
  }

  static Future<void> updateSession(ChatSession session) async {
    final isar = await database;
    await isar.writeTxn(() async {
      await isar.chatSessions.put(session);
    });
  }

  static Future<void> deleteSession(int sessionId) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 先检查会话是否存在
      final exists = await isar.chatSessions.get(sessionId) != null;
      if (!exists) return;
      
      // 删除关联消息
      await isar.chatMessages
          .filter()
          .sessionIdEqualTo(sessionId)
          .deleteAll();
          
      // 删除会话
      await isar.chatSessions.delete(sessionId);
    });
  }

  /// 更新单条消息实体
  static Future<void> updateMessage(ChatMessage msg) async {
    final isar = await database;
    await isar.writeTxn(() async {
      await isar.chatMessages.put(msg);
    });
  }

  /// 删除一个消息列表
  static Future<void> deleteMessagesList(List<ChatMessage> msgs) async {
    final isar = await database;
    final ids = msgs.map((m) => m.isarId).whereType<int>().toList();
    if (ids.isEmpty) return;
    await isar.writeTxn(() async {
      await isar.chatMessages.deleteAll(ids);
    });
  }

  static Future<void> deleteMessagesAfter(int sessionId, DateTime timestamp) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 删除指定会话中，时间戳晚于给定时间的所有消息
      final messagesToDelete = await isar.chatMessages
          .filter()
          .sessionIdEqualTo(sessionId)
          .timestampGreaterThan(timestamp)
          .findAll();
      
      // 批量删除消息
      await isar.chatMessages.deleteAll(messagesToDelete.map((e) => e.isarId).toList());
      
      // 更新会话的最后消息信息
      final session = await isar.chatSessions.get(sessionId);
      if (session != null) {
        final lastMsg = await isar.chatMessages
            .filter()
            .sessionIdEqualTo(sessionId)
            .sortByTimestampDesc()
            .findFirst();
        
        session.lastMsgContent = lastMsg?.content;
        session.lastMsgTime = lastMsg?.timestamp;
        
        await isar.chatSessions.put(session);
      }
    });
  }

  static Future<List<ChatMessage>> getMessages(int sessionId) async {
    final isar = await database;
    final messages = await isar.chatMessages
        .filter()
        .sessionIdEqualTo(sessionId)
        .findAll();
    return messages;
  }

  // API管理
  // 读取所有API配置
  static Future<List<ApiConfig>> getApiConfigs() async {
    final isar = await database;
    final configs = await isar.apiConfigs.where().findAll();
    // 兼容老版本 data
    for (final cfg in configs) {
      final normalized = ApiConfig.normalizeModelName(cfg.modelName);
      if (normalized != cfg.modelName) {
        // 如果数据库中存了旧名称，顺便更新
        cfg.modelName = normalized;
        await isar.writeTxn(() async {
          await isar.apiConfigs.put(cfg);
        });
      }
    }
    return configs;
  }

  // 添加API配置
  static Future<int> addApiConfig(ApiConfig config) async {
    final isar = await database;
    int? newId;
    await isar.writeTxn(() async {
      // 保存新配置并获取ID
      newId = await isar.apiConfigs.put(config);
      config.id = newId!;
      
      // 关联到AppSettings
      var settings = await isar.appSettings.get(_settingsId);
      settings ??= AppSettings()..id = _settingsId;
      await settings.apiProviders.add(config);
      await isar.appSettings.put(settings);
      await settings.apiProviders.save();
    });
    return newId!;
  }

  // 删除API配置
  static Future<void> deleteApiConfig(int id) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 从主设置中移除关联
      final settings = await isar.appSettings.get(_settingsId);
      if (settings != null) {
        await settings.apiProviders.remove(id);
        await settings.apiProviders.save();
      }
      
      // 删除配置实体
      await isar.apiConfigs.delete(id);
    });
  }

  static Future<void> updateApiConfig(ApiConfig config) async {
    final isar = await database;
    await isar.writeTxn(() async {
      await isar.apiConfigs.put(config);
    });
  }

  // 将API配置设为默认
  static Future<void> setDefaultApiConfig(int id) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 重置所有默认状态
      final defaultConfigs = await isar.apiConfigs
          .filter()
          .isDefaultEqualTo(true)
          .findAll();
      
      for (final config in defaultConfigs) {
        config.isDefault = false;
      }
      
      await isar.apiConfigs.putAll(defaultConfigs);
      
      // 设置当前为默认
      final config = await isar.apiConfigs.get(id);
      if (config != null) {
        config.isDefault = true;
        await isar.apiConfigs.put(config);
      }
    });
  }

  // 根据ID获取API配置
  static Future<ApiConfig?> getApiConfigById(int id) async {
    final isar = await database;
    final cfg = await isar.apiConfigs.get(id);
    if (cfg != null) {
      final normalized = ApiConfig.normalizeModelName(cfg.modelName);
      if (normalized != cfg.modelName) {
        cfg.modelName = normalized;
        await isar.writeTxn(() async {
          await isar.apiConfigs.put(cfg);
        });
      }
    }
    return cfg;
  }

  // 根据提供商名称获取API配置
  static Future<ApiConfig?> getApiConfig(String modelName) async {
    final isar = await database;
    // query with normalized value in case input is old name
    final normalizedInput = ApiConfig.normalizeModelName(modelName);
    final cfg = await isar.apiConfigs
        .filter()
        .modelNameEqualTo(normalizedInput)
        .findFirst();
    if (cfg != null) {
      final normalized = ApiConfig.normalizeModelName(cfg.modelName);
      if (normalized != cfg.modelName) {
        cfg.modelName = normalized;
        await isar.writeTxn(() async {
          await isar.apiConfigs.put(cfg);
        });
      }
    }
    return cfg;
  }

  /// 导入和导出
  static Future<String> exportSessionMessagesToJsonText(
    int sessionId, {
    BuildContext? context, // 新增context参数用于可视化提示
  }) async {
    final isar = await database;
    // 查询该会话的所有消息，按时间排序
    final messages = await isar.chatMessages
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortByTimestamp()
        .findAll();

    // 转为json字符串
    final jsonList = messages.map((msg) => msg.toShortJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
    return jsonString;
  }
  // 导出指定会话的全部消息为JSON文件，保存到指定目录（默认为软件所在目录）
  static Future<File> exportSessionMessagesToJson(
    int sessionId, {
    String? directoryPath,
    BuildContext? context, // 新增context参数用于可视化提示
  }) async {
    final isar = await database;
    // 查询该会话的所有消息，按时间排序
    final messages = await isar.chatMessages
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortByTimestamp()
        .findAll();

    // 转为json字符串
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    // 目标目录
    String dirPath;
    if (directoryPath != null && directoryPath.isNotEmpty) {
      dirPath = directoryPath;
    } else {
      // 软件所在目录
      dirPath = Directory.current.path;
    }

    // 文件名
    final fileName = 'chat_message_$sessionId.json';
    final file = File('$dirPath${Platform.pathSeparator}$fileName');

    // 写入文件
    await file.writeAsString(jsonString);

    // 可视化提示
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('聊天文件已保存至: ${file.path}')),
      );
    }

    return file;
  }

  // 从JSON导入聊天记录并创建新会话
  static Future<ChatSession?> _importSessionFromJson({
    required String jsonString,
    required String title,
    required BuildContext context,
  }) async {
    try {
      final List<dynamic> messagesJson = jsonDecode(jsonString);
      final isar = await IsarStorageService.database;
      
      // 创建新会话
      final newSession = ChatSession(title: title);
      await isar.writeTxn(() async {
        await isar.chatSessions.put(newSession);
      });

      // 导入消息
      for (final msgJson in messagesJson) {
        final message = ChatMessage.fromJson(msgJson);
        message.sessionId = newSession.id; // 关联到新会话
        
        await isar.writeTxn(() async {
          await isar.chatMessages.put(message);
          newSession.messages.add(message);
        });
      }

      // 更新会话的最后消息信息
      if (messagesJson.isNotEmpty) {
        final lastMsg = messagesJson.last;
        newSession.lastMsgContent = lastMsg['content'];
        newSession.lastMsgTime = DateTime.parse(lastMsg['timestamp']);
        
        await isar.writeTxn(() async {
          await isar.chatSessions.put(newSession);
        });
      }

      return newSession;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
      return null;
    }
  }

  static Future<void> importSessionFromJson({
    required BuildContext context,
    required Function(ChatSession) onSessionImported,
  }) async {
    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) return;
      
      // 读取文件内容
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      
      // 让用户输入会话标题
      final controller = TextEditingController();

      final title = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('输入会话标题'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: '例如: 导入的对话'),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
      
      if (title == null || title.isEmpty) return;
      
      // 导入会话
      final newSession = await _importSessionFromJson(
        jsonString: jsonString,
        title: title,
        context: context,
      );
      
      if (newSession != null) {
        onSessionImported(newSession);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导入成功!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
    }
  }

  // 导出指定角色卡为JSON文件，保存到指定目录（默认为软件所在目录）
  static Future<File> exportCharacterToJson(
    String character, {
    String? directoryPath,
    BuildContext? context, // 新增context参数用于可视化提示
  }) async {
    final card = await IsarStorageService.searchCharacterCard(character);
    if (card == null) {
      throw Exception('角色卡不存在');
    }
    final jsonList = card.toJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    // 目标目录
    String dirPath;
    if (directoryPath != null && directoryPath.isNotEmpty) {
      dirPath = directoryPath;
    } else {
      // 软件所在目录
      dirPath = Directory.current.path;
    }

    // 文件名
    final fileName = 'character_$character.json';
    final file = File('$dirPath${Platform.pathSeparator}$fileName');

    // 写入文件
    await file.writeAsString(jsonString);

    // 可视化提示
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('角色卡已保存至: ${file.path}')),
      );
    }

    return file;
  }

  // 从JSON导入角色卡
  static Future<CharacterCard?> _importCharacterFromJson({
    required String jsonString,
    required BuildContext context,
  }) async {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final characterCard = CharacterCard.fromJson(jsonData);
      
      // 检查角色名称是否已存在
      final bool nameExists = await IsarStorageService.isCharacterNameExists(
        characterCard.name,
      );
      
      if (nameExists) {
        // 询问用户如何处理重名问题
        final result = await showDialog<ImportCharacterAction>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('角色名称冲突: ${characterCard.name}'),
            content: const Text('已存在同名的角色卡，您想要如何操作？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImportCharacterAction.cancel),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImportCharacterAction.rename),
                child: const Text('重命名'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImportCharacterAction.overwrite),
                child: const Text('覆盖'),
              ),
            ],
          ),
        );
        
        switch (result) {
          case ImportCharacterAction.overwrite:
            // 查找并删除同名角色卡
            final existingCard = await IsarStorageService.searchCharacterCard(characterCard.name);
            await IsarStorageService.deleteCharacterCard(existingCard!.id);
            break;
            
          case ImportCharacterAction.rename:
            final newName = await _showRenameDialog(context, characterCard.name);
            if (newName == null || newName.isEmpty) return null;
            characterCard.name = newName;
            break;
            
          case ImportCharacterAction.cancel:
          default:
            return null;
        }
      }
      
      // 保存角色卡
      final savedCard = await IsarStorageService.saveCharacterCard(characterCard);
      return savedCard;
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
      return null;
    }
  }

  static Future<void> importCharacterFromJson({
    required BuildContext context,
    required Function(CharacterCard) onCardImported,
  }) async {
    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result == null || result.files.isEmpty) return;
      
      // 读取文件内容
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      
      // 导入角色卡
      final newCard = await _importCharacterFromJson(
        jsonString: jsonString,
        context: context,
      );
      
      if (newCard != null) {
        onCardImported(newCard);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${newCard.name}"导入成功!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
    }
  }

  // 覆盖指定会话的所有消息
  static Future<void> replaceSessionMessages(int sessionId, List<ChatMessage> newMessages) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 删除原有消息
      await isar.chatMessages
          .filter()
          .sessionIdEqualTo(sessionId)
          .deleteAll();

      // 插入新消息
      for (final msg in newMessages) {
        msg.sessionId = sessionId;
        await isar.chatMessages.put(msg);
      }

      // 更新会话最后一条消息内容和时间
      if (newMessages.isNotEmpty) {
        final session = await isar.chatSessions.get(sessionId);
        if (session != null) {
          session.lastMsgContent = newMessages.last.content;
          session.lastMsgTime = newMessages.last.timestamp;
          await isar.chatSessions.put(session);
        }
      }
    });
  }

  // 辅助函数：显示重命名对话框
  static Future<String?> _showRenameDialog(BuildContext context, String originalName) async {
    final controller = TextEditingController(text: originalName);
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名角色'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入新名称'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 导出角色卡所有信息并上传至云端
  static Future<void> uploadFullCharacter(String character, {
    BuildContext? context, // 新增context参数用于可视化提示
  }) async {
    final card = await IsarStorageService.searchCharacterCard(character);
    if (card == null) {
      throw Exception('角色卡不存在');
    }

    // 获取临时目录
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    // 1. 保存card为json
    final cardJson = const JsonEncoder.withIndent('  ').convert(card.toJson());
    final cardFile = File('$tempPath/character_$character.json');
    await cardFile.writeAsString(cardJson);

    // 2. 保存session为json
    await card.session.load();
    final session = card.session.value;
    if (session == null) {
      throw Exception('角色卡未关联会话');
    }
    final sessionJson = const JsonEncoder.withIndent('  ').convert(session.toJson());
    final sessionFile = File('$tempPath/session_$character.json');
    await sessionFile.writeAsString(sessionJson);

    // 3. 保存该session下所有消息为json
    final isar = await database;
    final messages = await isar.chatMessages
        .filter()
        .sessionIdEqualTo(session.id)
        .sortByTimestamp()
        .findAll();
    final messagesJson = const JsonEncoder.withIndent('  ')
        .convert(messages.map((m) => m.toJson()).toList());
    final messagesFile = File('$tempPath/messages_$character.json');
    await messagesFile.writeAsString(messagesJson);

    // 4. 上传全部json文件到tos
    await TosService.uploadFile(cardFile.path, 'character/character_$character.json');
    await TosService.uploadFile(sessionFile.path, 'character/session_$character.json');
    await TosService.uploadFile(messagesFile.path, 'character/messages_$character.json');

    // 可视化提示
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('角色卡已上传')),
      );
    }
  }

  // 从云端加载角色
  static Future<void> downloadFullCharacter(String character, {
    BuildContext? context, // context参数用于可视化提示
  }) async {
    try {
      // 生成云端文件URL
      final cardUrl = await TosService.generateUrl('character/character_$character.json');
      final sessionUrl = await TosService.generateUrl('character/session_$character.json');
      final messagesUrl = await TosService.generateUrl('character/messages_$character.json');

      // 下载文件
      final cardResponse = await http.get(Uri.parse(cardUrl));
      final sessionResponse = await http.get(Uri.parse(sessionUrl));
      final messagesResponse = await http.get(Uri.parse(messagesUrl));

      // 检查文件是否存在
      if (cardResponse.statusCode != 200) throw Exception('角色卡文件不存在');
      if (sessionResponse.statusCode != 200) throw Exception('会话文件不存在');
      if (messagesResponse.statusCode != 200) throw Exception('消息文件不存在');

      // 解析JSON数据
      final cardJson = jsonDecode(cardResponse.body);
      final sessionJson = jsonDecode(sessionResponse.body);
      final messagesJson = jsonDecode(messagesResponse.body) as List<dynamic>;

      // 转换数据模型
      final newCard = CharacterCard.fromJson(cardJson);
      final newSession = ChatSession.fromJson(sessionJson);
      final newMessages = messagesJson
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      // 更新角色信息
      final isar = await database;
      await isar.writeTxn(() async {
        final currentCard = await IsarStorageService.searchCharacterCard(character);
        if(currentCard != null) {
          newCard.id = currentCard.id;
        }
        await isar.characterCards.put(newCard);
        // 更新 session 信息
        await newCard.session.load();
        if (newCard.session.value != null) {
          newSession.id=newCard.session.value!.id;
        } 
        newCard.session.value = newSession;
        final sessionId = newCard.session.value!.id;

        // 更新 message 信息
        await isar.chatMessages.filter().sessionIdEqualTo(sessionId).deleteAll();
        for (final msg in newMessages) {
          msg.sessionId = sessionId;
          await isar.chatMessages.put(msg);
        }

        // 更新会话最后消息
        if (newMessages.isNotEmpty) {
          newCard.session.value!.lastMsgContent = newMessages.last.content;
          newCard.session.value!.lastMsgTime = newMessages.last.timestamp;
        }

        await isar.characterCards.put(newCard); 
        await isar.chatSessions.put(newCard.session.value!);
        await newCard.session.save(); 
      });
      // 可视化提示
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$character 角色卡已加载')),
        );
      }
    } catch (e) {
      // 错误处理
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: ${e.toString()}')),
        );
      }
    }
  }

  // TOS管理
  // 读取TosConfig（返回第一个配置，或null）
  static Future<TosConfig?> getTosConfig() async {
    final isar = await database;
    return await isar.tosConfigs.where().findFirst();
  }

  // 保存或更新TosConfig（如已存在则更新，否则新建）
  static Future<void> saveTosConfig(TosConfig config) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 检查是否已有TosConfig
      final existing = await isar.tosConfigs.where().findFirst();
      if (existing != null) {
        existing.ak = config.ak;
        existing.sk = config.sk;
        existing.bucket = config.bucket;
        await isar.tosConfigs.put(existing);
      } else {
        await isar.tosConfigs.put(config);
      }
    });
  }

  // 删除TosConfig
  static Future<void> deleteTosConfig() async {
    final isar = await database;
    await isar.writeTxn(() async {
      final existing = await isar.tosConfigs.where().findFirst();
      if (existing != null) {
        await isar.tosConfigs.delete(existing.id);
      }
    });
  }

  /// 地图api管理
  static Future<LocationConfig?> getLocationConfig() async {
    final isar = await database;
    return await isar.locationConfigs.where().findFirst();
  }

  static Future<void> saveLocationConfig(LocationConfig config) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 检查是否已有TosConfig
      final existing = await isar.locationConfigs.where().findFirst();
      if (existing != null) {
        existing.key = config.key;
        await isar.locationConfigs.put(existing);
      } else {
        await isar.locationConfigs.put(config);
      }
    });
  }

  static Future<void> deletelocationConfig() async {
    final isar = await database;
    await isar.writeTxn(() async {
      final existing = await isar.locationConfigs.where().findFirst();
      if (existing != null) {
        await isar.locationConfigs.delete(existing.id);
      }
    });
  }

  /// 角色管理
  // 获取所有角色卡
  static Future<List<CharacterCard>> getAllCharacterCards() async {
    final isar = await database;
    final cards = await isar.characterCards.where().findAll();
    // 预加载每个角色卡的 session 属性
    for (final card in cards) {
      await card.session.load();
    }
    return cards;
  }

  // 按ID获取角色卡
  static Future<CharacterCard?> getCharacterCardById(Id id) async {
    final isar = await database;
    final card = await isar.characterCards.get(id);
    if(card!=null)  {await card.session.load();}
    return card;
  }

  // 获取角色头像
  static Future<String?> getCharacterAvatarById(Id characterCardId) async {
    final isar = await database;
    final card = await isar.characterCards.get(characterCardId);
    return card?.avatar;
  }

  // 删除角色卡
  static Future<void> deleteCharacterCard(Id id) async {
    final isar = await database;
    await isar.writeTxn(() async {
      // 先检查会话是否存在
      final card = await isar.characterCards.get(id);
      if (card==null) return;
      await card.session.load();  // 显示加载，避免隐性事务嵌套
      final session = card.session.value;
      // 删除关联消息
      if (session != null) {
        await isar.chatMessages
            .filter()
            .sessionIdEqualTo(session.id)
            .deleteAll();
        await isar.chatSessions.delete(session.id);
      }
      await isar.characterCards.delete(id);
    });
  }

  // 搜索角色卡（按名称）
  static Future<CharacterCard?> searchCharacterCard(String keyword) async {
    final isar = await database;
    final card = await isar.characterCards
        .filter()
        .nameContains(keyword, caseSensitive: false)
        .findFirst();
    if(card!=null)  {await card.session.load();}
    return card;
  }

  // 检查角色名称是否已存在
  static Future<bool> isCharacterNameExists(String name, {Id? excludeId}) async {
    final isar = await database;
    final query = isar.characterCards
        .where()
        .nameEqualTo(name);
    
    final existing = await query.findAll();
    
    if (excludeId != null) {
      return existing.any((card) => card.id != excludeId);
    }
    return existing.isNotEmpty;
  }

  static Future<CharacterCard> saveCharacterCard(CharacterCard card) async {
    final isar = await database;
    return await isar.writeTxn(() async {
      // 1. 检查角色名唯一性
      if (await isCharacterNameExists(card.name, excludeId: card.id)) {
        throw Exception('角色名称已存在');
      }

      // 2. 保存/更新角色卡
      final id = await isar.characterCards.put(card);
      card.id = id;

      await card.session.load();  // 显示加载，避免隐性事务嵌套
      // 3. 检查是否新建卡片
      final isNewCard = card.session.value==null;
      if (isNewCard) {
        // 创建新会话
        ChatSession session = ChatSession(
          title: card.name,
          character: card.name,
          systemPrompt: '',
          isCharacterSession: true,
        );
        await isar.chatSessions.put(session);
        card.session.value=session;
        card.session.save();
      } 

      return card;
    });
  }

  /// AI笔记管理
  static Future<List<Note>> getAllNotes() async {
    final isar = await database;
    final allNote = await isar.notes.where().findAll();
    return allNote;
  }

  static Future<Note?> getNote(Id id) async {
    final isar = await database;
    final note = await isar.notes.get(id);
    return note;
  }


  static Future<void> deleteNote(Id id) async {
    final isar = await database;
    await isar.writeTxn(() async {
      final note = await isar.notes.get(id);
      if (note==null) return;
      await isar.notes.delete(id);
    });
  }

  static Future<Note?> getNoteByName(String name) async {
    final isar = await database;
    final note = await isar.notes
        .filter()
        .nameEqualTo(name, caseSensitive: false)
        .findFirst();
    return note;
  }

  static Future<bool> isNoteNameExists(String name, {Id? excludeId}) async {
    final isar = await database;
    final query = isar.notes
        .where()
        .nameEqualTo(name);
    
    final existing = await query.findAll();
    
    if (excludeId != null) {
      return existing.any((note) => note.id != excludeId);
    }
    return existing.isNotEmpty;
  }

  static Future<Note> saveNote(Note note) async {
    final isar = await database;
    return await isar.writeTxn(() async {
      // 1. 检查笔记名唯一性
      if (await isNoteNameExists(note.name, excludeId: note.id)) {
        throw Exception('笔记名称已存在');
      }

      // 2. 保存/更新笔记
      final id = await isar.notes.put(note);
      note.id = id;

      return note;
    });
  }
}
 

