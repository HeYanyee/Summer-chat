import 'package:flutter/material.dart';
import '../../models/chat_session.dart';
import '../../models/chat_message.dart';
import '../../models/character_card.dart';
import '../../services/storage_service.dart'; 
import '../../utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CharacterDetailsPage extends StatefulWidget {
  final CharacterCard card;
  final Function(CharacterCard) onSettingsSaved; // 添加回调函数

  const CharacterDetailsPage({
    Key? key, 
    required this.card,
    required this.onSettingsSaved, // 接收回调
  }) : super(key: key);

  @override
  _CharacterDetailsPageState createState() => _CharacterDetailsPageState();
}
class _CharacterDetailsPageState extends State<CharacterDetailsPage> {
  late TextEditingController _descController;
  late TextEditingController _longHistoryController;
  late TextEditingController _shortHistoryController;
  late TextEditingController _avatarController;
  late TextEditingController _shortDescController;
  late TextEditingController _systemPromptController;
  late String _apiSource;
  late String _systemPrompt;
  late int _maxTokens;
  late int _maxContextLength;
  late int _refreshCount;
  late int _refreshThreshold; // 新增刷新阈值
  late bool _hideReasoningBubbles; 
  late bool _autoReadReply;
  late bool _enableTools;
  late bool _includeThinking;

  bool _refreshEnabled = false;

  bool _isUploading = false; // 上传中状态


  ChatSession? currentSession;

  @override
  void initState() {
    super.initState();
    currentSession = widget.card.session.value;
    
    // 初始化控制器并使用 widget.card 中的值
    _descController = TextEditingController(text: widget.card.description);
    _longHistoryController = TextEditingController(text: widget.card.longMemory);
    _shortHistoryController = TextEditingController(text: widget.card.shortMemory);
    _avatarController = TextEditingController(text: widget.card.avatar ?? '');
    _shortDescController = TextEditingController(text: widget.card.shortDescription ?? '');
    _systemPromptController = TextEditingController();
    _refreshCount = widget.card.refreshCount ?? -1;
    _refreshThreshold = widget.card.refreshThreshold ?? 50; // 默认50次
    _refreshEnabled = _refreshCount != -1;
    _hideReasoningBubbles = widget.card.hideReasoningBubbles ?? false; 
    _autoReadReply = widget.card.autoReadReply ?? false; 

    
    if (currentSession != null) {
      _systemPrompt = currentSession!.systemPrompt;
      _apiSource = currentSession!.apiSource;
      _maxTokens = currentSession!.maxTokens;
      _maxContextLength = currentSession!.maxContextLength;
      _systemPromptController.text = _systemPrompt;
      _enableTools = currentSession!.enabledTools;
      _includeThinking = currentSession!.includeThinking;
    }

    _validateAndFixApiSource();
  }

  void _validateAndFixApiSource() {
    final validKeys = ApiConstants.defaultModels.keys.toList();
    
    // 如果 _apiSource 无效（不在列表中），则设为列表第一个
    if (!validKeys.contains(_apiSource)) {
      setState(() {
        _apiSource = validKeys.first;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      await currentSession!.updateSettings(
        systemPrompt: _systemPromptController.text,
        apiSource: _apiSource,
        maxTokens: _maxTokens,
        maxContextLength: _maxContextLength,
        enableTools: _enableTools,
        includeThinking: _includeThinking,
      );
      // 创建更新后的会话对象
      final updatedCard = widget.card.copyWith(
        description:_descController.text,
        longHistory:_longHistoryController.text,
        shortHistory:_shortHistoryController.text,
        avatar:_avatarController.text.isNotEmpty ? _avatarController.text : null,
        shortDescription:_shortDescController.text.isNotEmpty ? _shortDescController.text : null,
        refreshCount: _refreshCount,
        refreshThreshold: _refreshThreshold,
        hideReasoningBubbles: _hideReasoningBubbles,
        autoReadReply: _autoReadReply, 
      )..id = widget.card.id;
      updatedCard.session.value=currentSession;
      await IsarStorageService.saveCharacterCard(updatedCard);
      // 触发回调
      widget.onSettingsSaved(updatedCard);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('设置已保存'),
          duration: Duration(seconds: 1), 
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _longHistoryController.dispose();
    _shortHistoryController.dispose();
    _avatarController.dispose();
    _shortDescController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  void _onRefreshToggle(bool value) {
    setState(() {
      _refreshEnabled = value;
      _refreshCount = value ? 0 : -1;
    });
  }

  void _onHideReasoningToggle(bool value) {
    setState(() {
      _hideReasoningBubbles = value;
    });
  }

  void _onEnableToolsToggle(bool value) {
    setState(() {
      _enableTools = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmGrey200, 
      appBar: AppBar(
        title: Text("${widget.card.name} - 详细信息"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 新增顶部小字提示
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "*直接退出将不会保存设置",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
            ),
            _buildSectionHeader("API设置"),
            _buildApiSourceDropdown(),
            const SizedBox(height: 16),           
            _buildSectionHeader("角色信息"),
            _buildAvatarPicker(),
            const SizedBox(height: 16),
            _buildTextFieldWithLabel("简短描述", "输入简短描述", _shortDescController, maxLines: 2),
            const SizedBox(height: 16),
            _buildTextFieldWithLabel("详细描述", "输入角色详细描述", _descController, maxLines: 5),
            const SizedBox(height: 16),
            _buildTextFieldWithRevert(
              label: "长期记忆",
              hint: "输入角色长期背景故事（可为空）",
              controller: _longHistoryController,
              maxLines: 5,
              canRevert: widget.card.longMemoryHistory.isNotEmpty,
              onRevert: () {
                if (widget.card.revertLongHistory()) {
                  setState(() {
                    _longHistoryController.text = widget.card.longMemory;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('长期记忆已回退')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTextFieldWithRevert(
              label: "近期记忆",
              hint: "输入当前会话记忆（可为空）",
              controller: _shortHistoryController,
              maxLines: 5,
              canRevert: widget.card.shortMemoryHistory.isNotEmpty,
              onRevert: () {
                if (widget.card.revertShortHistory()) {
                  setState(() {
                    _shortHistoryController.text = widget.card.shortMemory;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('近期记忆已回退')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),          
            _buildSectionHeader("其他设置"),
            _buildTextFieldWithLabel("系统提示词", "其他系统提示词", _systemPromptController, maxLines: 3),
            const SizedBox(height: 16),  
            _buildMaxTokensSlider(),
            const SizedBox(height: 16),  
            _buildContextLengthSlider(),
            const SizedBox(height: 16),
            _buildThinkingSwitch(),
            const SizedBox(height: 16),
            // _buildRefreshSwitch(), 
            // const SizedBox(height: 16),
            _buildEnableToolsSwitch(), // 添加工具调用开关
            const SizedBox(height: 16),
            // _buildRefreshThresholdSlider(), // 添加刷新阈值滑块
            // const SizedBox(height: 16),
            _buildHideReasoningSwitch(), 
            const SizedBox(height: 16),
            _buildAutoReadSwitch(),
            const SizedBox(height: 16),
            _buildSectionHeader("导入和导出"),
            _buildExportButton(), 
            const SizedBox(height: 8),
            _buildImportButton(), 
            const SizedBox(height: 8),
            _buildUploadButton(),
            const SizedBox(height: 8),
            _buildDownloadButton(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("开启深度思考", style: TextStyle(fontSize: 16)),
        Switch(
          value: _includeThinking,
          onChanged: (v) => setState(() => _includeThinking = v),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildAutoReadSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("自动朗读AI回复", style: TextStyle(fontSize: 16)),
        Switch(
          value: _autoReadReply,
          onChanged: (v) => setState(() => _autoReadReply = v),
          activeColor: AppColors.primary,
        ),
      ],
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

  Widget _buildRefreshSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "自动更新近期记忆",
              style: TextStyle(fontSize: 16),
            ),
            Switch(
              value: _refreshEnabled,
              onChanged: _onRefreshToggle,
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (_refreshEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "再过${_refreshThreshold - _refreshCount}轮对话自动更新近期记忆。该选项同步开启动态上下文。",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildHideReasoningSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "隐藏思考过程",
          style: TextStyle(fontSize: 16),
        ),
        Switch(
          value: _hideReasoningBubbles,
          onChanged: _onHideReasoningToggle,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildEnableToolsSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "开启工具调用功能",
          style: TextStyle(fontSize: 16),
        ),
        Switch(
          value: _enableTools,
          onChanged: _onEnableToolsToggle,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildApiSourceDropdown() {
    return Row(
      children: [
        const Text("API来源:", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _apiSource,
            isExpanded: true,
            items: //从constants中获取支持的API列表
                ApiConstants.defaultModels.keys.map((key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _apiSource = value);
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
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

  Widget _buildTextFieldWithRevert({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onRevert,
    int maxLines = 1,
    bool canRevert = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("$label:", style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            if (canRevert)
              TextButton.icon(
                onPressed: onRevert,
                icon: const Icon(Icons.undo, size: 18),
                label: const Text("回退"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 32),
                ),
              ),
          ],
        ),
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

  Widget _buildMaxTokensSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("最大Token数:", style: TextStyle(fontSize: 16)),
            Text("$_maxTokens"),
          ],
        ),
        Slider(
          value: _maxTokens.toDouble(),
          min: ApiConstants.minTokens,  // 2000
          max: ApiConstants.maxTokens,  // 16000
          divisions: 14,
          label: "$_maxTokens",
          onChanged: (value) => setState(() => _maxTokens = value.toInt()),
        ),
      ],
    );
  }

  Widget _buildContextLengthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("上下文长度:", style: TextStyle(fontSize: 16)),
            Text("$_maxContextLength 条消息"),
          ],
        ),
        Slider(
          value: _maxContextLength.toDouble(),
          min: ApiConstants.minContex,  //1
          max: ApiConstants.maxContex,  //50
          label: "$_maxContextLength",
          onChanged: (value) => setState(() => _maxContextLength = value.toInt()),
        ),
        const Text(
          "控制发送给AI的历史消息数量。",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRefreshThresholdSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("自动更新记忆界限", style: TextStyle(fontSize: 16)),
            Text("$_refreshThreshold 轮对话"),
          ],
        ),
        Slider(
          value: _refreshThreshold.toDouble(),
          min: 10,  
          max: 50, 
          divisions: 4,
          label: "$_refreshThreshold",
          onChanged: (value) => setState(() => _refreshThreshold = value.toInt()),
        ),
        const Text(
          "每经过给定轮数的对话自动刷新短期记忆。",
          style: TextStyle(fontSize: 12, color: Colors.grey),
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
    return InkWell(
      onTap: () async {
        try {
          await IsarStorageService.exportSessionMessagesToJson(
            currentSession!.id,
            context: context,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('导出失败: $e')),
          );
        }
      },
      onHighlightChanged: (isPressed) {
        setState(() {}); // 触发重绘以更新高亮状态
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "导出聊天记录",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.upload, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton() {
    return InkWell(
      onTap: () async {
        try {
          // 选择json文件
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['json'],
          );
          if (result == null || result.files.isEmpty) return;

          final file = File(result.files.single.path!);
          final jsonString = await file.readAsString();

          // 使用 ChatMessage 的静态方法解析消息
          final List<ChatMessage> newMessages = ChatMessage.listFromJson(jsonString);

          // 覆盖当前会话的消息
          if (currentSession != null) {
            await IsarStorageService.replaceSessionMessages(
              currentSession!.id,
              newMessages,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('聊天记录导入并覆盖成功！')),
            );
            setState(() {}); // 刷新页面
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('导入失败: $e')),
          );
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "导入并覆盖聊天记录",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.download, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return InkWell(
      onTap: _isUploading
          ? null
          : () async {
              setState(() {
                _isUploading = true;
              });
              try {
                await IsarStorageService.uploadFullCharacter(
                  widget.card.name,
                  context: context,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('上传失败: $e')),
                );
              } finally {
                setState(() {
                  _isUploading = false;
                });
              }
            },
      onHighlightChanged: (isPressed) {
        setState(() {}); // 触发重绘以更新高亮状态
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "上传角色卡至云端",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            _isUploading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.upload, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return InkWell(
      onTap: () async {
        try {
           await IsarStorageService.downloadFullCharacter(
            widget.card.name,
            context: context,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('导入失败: $e')),
          );
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "从云端导入并覆盖角色卡",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.download, color: Theme.of(context).primaryColor),
          ],
        ),
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
      child: const Text(
        "保存设置",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}