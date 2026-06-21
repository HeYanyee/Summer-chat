import 'package:flutter/material.dart';
import '../../models/character_card.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CharacterConfigPage extends StatefulWidget {
  final CharacterCard? initialCharacter;

  const CharacterConfigPage({Key? key,this.initialCharacter}) : super(key: key); // 移除参数

  @override
  _CharacterConfigPageState createState() => _CharacterConfigPageState();
}

class _CharacterConfigPageState extends State<CharacterConfigPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _longHistoryController;
  late TextEditingController _shortHistoryController;
  late TextEditingController _avatarController;
  late TextEditingController _shortDescController;

  List<CharacterCard> _allCharacters = [];
  bool _isLoadingCharacters = true;
  CharacterCard? _currentCharacter; // 当前选中的角色

  bool get _isExistingCharacter {
    return _currentCharacter?.session.value != null;
  }

  @override
  void initState() {
    super.initState();
    // 初始化空控制器
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _longHistoryController = TextEditingController();
    _shortHistoryController = TextEditingController();
    _avatarController = TextEditingController();
    _shortDescController = TextEditingController();
    if (widget.initialCharacter != null) {
      _setCurrentCharacter(widget.initialCharacter!);
    }

    _loadAllCharacters();
  }

  Future<void> _loadAllCharacters() async {
    setState(() => _isLoadingCharacters = true);
    final characters = await IsarStorageService.getAllCharacterCards();
    setState(() {
      _allCharacters = characters;
      _isLoadingCharacters = false;
      
      // 如果有角色，默认选择第一个
      if (_allCharacters.isNotEmpty) {
        _setCurrentCharacter(_allCharacters.first);
      }
    });
  }

  // 设置当前角色并更新控制器
  void _setCurrentCharacter(CharacterCard character) {
    setState(() {
      _currentCharacter = character;
      _nameController.text = character.name;
      _descController.text = character.description;
      _longHistoryController.text = character.longMemory;
      _shortHistoryController.text = character.shortMemory;
      _avatarController.text = character.avatar ?? '';
      _shortDescController.text = character.shortDescription ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _longHistoryController.dispose();
    _shortHistoryController.dispose();
    _avatarController.dispose();
    _shortDescController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (_currentCharacter == null) return;
    
    // 验证角色名称
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('角色名称不能为空')),
        );
      }
      return;
    }
    
    // 检查名称是否已存在（排除当前角色）
    final nameExists = await IsarStorageService.isCharacterNameExists(
      name,
      excludeId: _currentCharacter!.id,
    );
    
    if (nameExists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('角色名称 "$name" 已存在')),
        );
      }
      return;
    }
    
    // 创建更新后的角色卡
    final updatedCard = CharacterCard()
      ..id = _currentCharacter!.id
      ..name = name
      ..description = _descController.text
      ..longMemory = _longHistoryController.text
      ..shortMemory = _shortHistoryController.text
      ..avatar = _avatarController.text.isNotEmpty ? _avatarController.text : null
      ..shortDescription = _shortDescController.text.isNotEmpty ? _shortDescController.text : null;
    
    // 保存到数据库
    try {
      final savedCard = await IsarStorageService.saveCharacterCard(updatedCard);
      
      // 更新当前角色引用
      setState(() {
        _currentCharacter = savedCard;
        
        // 更新列表中的角色
        final index = _allCharacters.indexWhere((c) => c.id == savedCard.id);
        if (index != -1) {
          _allCharacters[index] = savedCard;
        } else {
          _allCharacters.add(savedCard);
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${savedCard.name}" 已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  void _switchCharacter(CharacterCard? newCharacter) {
    if (newCharacter == null) return;
    _setCurrentCharacter(newCharacter);
  }

  void _createNewCharacter() async {
    // 创建临时角色
    final newCharacter = CharacterCard()
      ..name = ""
      ..description = ""
      ..longMemory = ""
      ..shortMemory = ""
      ..avatar = ""
      ..shortDescription = ""
      ..refreshCount = 0
      ..lastRefreshTime = DateTime.now();
    
    // 添加到角色列表
    setState(() {
      _allCharacters.add(newCharacter);
      _setCurrentCharacter(newCharacter);
    });
  }

  // 构建空状态提示
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '暂无角色卡配置',
            style: TextStyle(fontSize: 16, color: AppColors.warmGrey400),
          ),
          const SizedBox(height: 8),
          Text(
            '请点击右上角按钮新建角色',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.warmGrey400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(_currentCharacter != null 
            ? "${_currentCharacter!.name} - 角色设置" 
            : "角色设置"),
        actions: [
          PopupMenuButton<CharacterCard>(
            onSelected: _switchCharacter,
            itemBuilder: (context) {
              // 新建角色菜单项
              final newCharacterItem = PopupMenuItem<CharacterCard>(
                value: null,
                child: ListTile(
                  leading: const Icon(Icons.add, color: AppColors.info),
                  title: const Text('新建角色...', style: TextStyle(color: AppColors.info)),
                  onTap: () {
                    Navigator.pop(context); // 关闭菜单
                    _createNewCharacter();
                  },
                ),
              );

              // 导入角色菜单项
              final importCharacterItem = PopupMenuItem<CharacterCard>(
                value: null,
                child: ListTile(
                  leading: const Icon(Icons.download, color: AppColors.success),
                  title: const Text('导入角色...', style: TextStyle(color: AppColors.success)),
                  onTap: () {
                    Navigator.pop(context); // 关闭菜单
                    _importCharacter();
                  },
                ),
              );

              // 角色列表菜单项
              final characterItems = _allCharacters
                  .where((character) => character.name.trim().isNotEmpty)
                  .map((character) {
                return PopupMenuItem<CharacterCard>(
                  value: character,
                  child: ListTile(
                    leading: character.avatar != null 
                      ? CircleAvatar(backgroundImage: NetworkImage(character.avatar!))
                      : const CircleAvatar(child: Icon(Icons.person), backgroundColor: AppColors.primary),
                    title: Text(character.name),
                    subtitle: character.shortDescription != null
                      ? Text(character.shortDescription!, overflow: TextOverflow.ellipsis)
                      : null,
                  ),
                );
              }).toList();

              // 返回所有菜单项
              return [newCharacterItem, importCharacterItem, ...characterItems];
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.switch_account),
                  const SizedBox(width: 4),
                  Text(
                    '切换角色',
                    style: TextStyle(
                      fontSize: 16, 
                      color: Theme.of(context).appBarTheme.titleTextStyle?.color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingCharacters
          ? const Center(child: CircularProgressIndicator())
          : _currentCharacter == null
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "*直接退出将不会保存设置",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      _buildSectionHeader("基本信息"),
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildTextFieldWithLabel("简短描述", "输入简短描述", _shortDescController, maxLines: 2),
                      const SizedBox(height: 16),
                      _buildTextFieldWithLabel("详细描述", "输入角色详细描述", _descController, maxLines: 3),
                      const SizedBox(height: 16),
                      _buildAvatarPicker(),
                      const SizedBox(height: 24),
                      _buildSectionHeader("记忆管理"),
                      _buildTextFieldWithLabel("长期记忆", "输入角色长期背景故事（可为空）", _longHistoryController, maxLines: 5),
                      const SizedBox(height: 16),
                      _buildTextFieldWithLabel("近期记忆", "输入当前会话记忆（可为空）", _shortHistoryController, maxLines: 3),
                      const SizedBox(height: 32),
                      _buildDeleteButton(),
                      const SizedBox(height: 16),
                      _buildExportButton(),
                      const SizedBox(height: 16),
                      _buildSaveButton(),
                    ],
                  ),
                ),
    );
  }

  // 构建删除按钮
  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: () => _confirmDeleteCharacter(),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.warmGrey400,
      ),
      child: const Text("删除角色", style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  // 确认删除角色
  void _confirmDeleteCharacter() {
    if (_currentCharacter == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("确认删除角色"),
        content: Text("确定要永久删除角色 '${_currentCharacter!.name}' 吗？相关的对话记录也会被删除。此操作不可撤销。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCharacter();
            },
            child: const Text("删除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 执行删除操作
  Future<void> _deleteCharacter() async {
    if (_currentCharacter == null) return;
    
    final characterToDelete = _currentCharacter!;
    final characterId = characterToDelete.id;
    
    try {
      // 尝试从数据库删除
      if (characterId > 0) {
        await IsarStorageService.deleteCharacterCard(characterId);
      }
      
      // 从本地列表中移除
      setState(() {
        _allCharacters.removeWhere((c) => c.id == characterId);
        
        // 选择新角色（如果有）
        if (_allCharacters.isNotEmpty) {
          _setCurrentCharacter(_allCharacters.first);
        } else {
          _currentCharacter = null;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'${characterToDelete.name}' 已删除")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("删除失败: $e")),
        );
      }
    }
  }

  Future<void> _importCharacter() async {
    await IsarStorageService.importCharacterFromJson(
      context: context,
      onCardImported: (CharacterCard card) {
        setState(() {
          _allCharacters.add(card);
        });
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextFieldWithLabel(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label:", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  // 修改角色名称输入框构建逻辑
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("角色名称（必填）:", style: TextStyle(fontSize: 16)),
            if (_isExistingCharacter) ...[
              const SizedBox(width: 8),
              const Tooltip(
                message: "已有角色不可更改名称",
                child: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
              ),
            ]
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          enabled: !_isExistingCharacter, // 已有角色时禁用编辑
          decoration: InputDecoration(
            hintText: _isExistingCharacter 
                ? "名称不可更改" 
                : "输入角色名称",
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(12),
            filled: _isExistingCharacter,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }

  // 添加头像选择方法
  Future<void> _pickAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      setState(() {
        _avatarController.text = file.path ?? '';
      });
    }
  }

  // 构建头像选择区域
  Widget _buildAvatarPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("头像:", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        // 文本框和选择按钮在同一行
        Row(
            children: [
            Expanded(
              child: TextField(
              controller: _avatarController,
              decoration: InputDecoration(
                hintText: "输入本地图片地址",
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
              ),
              ),
            ),
            const SizedBox(width: 12),

              SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _pickAvatar,
                style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                iconColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(8),
                ),
                child: Icon(Icons.folder_open,size: 28,)
                // const Text("选择文件",style: TextStyle(color: Colors.white,fontSize: 16),),
              ),
              ),

          ],
        ),
        const SizedBox(height: 8),
        // 图片预览区域
        _buildImagePreview(),
      ],
    );
  }

  // 构建图片预览
  Widget _buildImagePreview() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: _avatarController.text.isNotEmpty
          ? Image.file(
              File(_avatarController.text),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => 
                const Center(child: Text("无法预览图片")),
            )
          : const Center(
              child: Text(
                "图片预览区域",
                style: TextStyle(color: Colors.grey),
              ),
            ),
    );
  }

  Widget _buildExportButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          await IsarStorageService.exportCharacterToJson(
            _currentCharacter!.name,
            context: context,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('导出失败: $e')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: const Text(
        "导出角色卡",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveSettings,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: const Text("保存设置", style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}