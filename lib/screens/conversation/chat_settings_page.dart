import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart'; // 顶部导入
import '../../models/chat_session.dart';
import '../../models/character_card.dart';
import '../../services/storage_service.dart'; 
import '../../utils/constants.dart';

class ChatSettingsPage extends StatefulWidget {
  final ChatSession session;
  final Function(ChatSession) onSettingsSaved; // 添加回调函数
  
  const ChatSettingsPage({
    Key? key, 
    required this.session,
    required this.onSettingsSaved, // 接收回调
  }) : super(key: key);

  @override
  _ChatSettingsPageState createState() => _ChatSettingsPageState();
}
class _ChatSettingsPageState extends State<ChatSettingsPage> {
  String? _character;
  late TextEditingController _systemPromptController;
  late String _apiSource;
  late double _temperature;
  late int _maxContextLength;
  late double _topP;
  late double _frequencyPenalty;
  late double _presencePenalty;
  late bool _streamResponse;
  late int _maxTokens;
  late bool _includeThinking;

  @override
  void initState() {
    super.initState();
    _systemPromptController = TextEditingController(text: widget.session.systemPrompt);
    _apiSource = widget.session.apiSource;
    _temperature = widget.session.temperature;
    _maxContextLength = widget.session.maxContextLength;
    _topP = widget.session.topP;
    _character = widget.session.character; 
    _frequencyPenalty = widget.session.frequencyPenalty;
    _presencePenalty = widget.session.presencePenalty;
    _streamResponse = widget.session.streamResponse;
    _maxTokens = widget.session.maxTokens;
    _includeThinking = widget.session.includeThinking;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmGrey200, 
      appBar: AppBar(
        title: Text("${widget.session.title} - 设置"),
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
            _buildSectionHeader("模型行为"),
            _buildCharacterCardField(),
            const SizedBox(height: 16),
            _buildSystemPromptField(),
            const SizedBox(height: 16),
            // _buildTemperatureSlider(),
            // const SizedBox(height: 16),
            // _buildTopPSlider(),
            // const SizedBox(height: 16),
            // _buildFrequencyPenaltySlider(),
            // const SizedBox(height: 16),
            // _buildPresencePenaltySlider(),
            // const SizedBox(height: 16),            
            _buildSectionHeader("响应设置"),
            _buildMaxTokensSlider(),
            const SizedBox(height: 16),
            _buildThinkingSwitch(),
            const SizedBox(height: 16),  
            _buildSectionHeader("上下文管理"),
            _buildContextLengthSlider(),
            const SizedBox(height: 16),
            _buildSectionHeader("聊天记录"),
            _buildExportButton(), // 新增导出按钮
            const SizedBox(height: 8),
            _buildExportToClickboardButton(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
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

  Widget _buildCharacterCardField() {
    return Row(
      children: [
        const Text("角色卡:", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 16),
        Expanded(
          child: FutureBuilder<List<CharacterCard>>(
            future: IsarStorageService.getAllCharacterCards(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              
              if (snapshot.hasError) {
                return const Text("加载角色卡失败");
              }
              
              final characterCards = snapshot.data ?? [];
              
              final characterNames = characterCards.map((c) => c.name).toList();
              
              if (characterNames.isEmpty) {
                return const Text("没有可用的角色卡",
                  style: TextStyle(fontSize: 16),
                );
              }
              // 若当前角色名已被删除，则重置为null
              if (_character != null && !characterNames.contains(_character)) {
                setState(() {
                  _character = null;
                });
              }

              final items = [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text("无"),
                ),
                ...characterCards.map((card) {
                  return DropdownMenuItem<String>(
                    value: card.name,
                    child: Text(card.name),
                  );
                }).toList(),
              ];

              return DropdownButtonFormField<String>(
                initialValue: _character,
                items: items,
                onChanged: (value) {
                  setState(() {
                    _character = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) {
                  return null;
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSystemPromptField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("系统提示:", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: _systemPromptController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "输入系统提示以引导AI行为...",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("温度 (随机性):", style: TextStyle(fontSize: 16)),
            Text(_temperature.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: _temperature,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: _temperature.toStringAsFixed(1),
          onChanged: (value) => setState(() => _temperature = value),
        ),
        const Text(
          "较低值 = 更专注/确定性\n较高值 = 更多样化/创造性",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTopPSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Top-p 采样:", style: TextStyle(fontSize: 16)),
            Text(_topP.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: _topP,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: _topP.toStringAsFixed(1),
          onChanged: (value) => setState(() => _topP = value),
        ),
      ],
    );
  }

  Widget _buildFrequencyPenaltySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("频率惩罚:", style: TextStyle(fontSize: 16)),
            Text(_frequencyPenalty.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: _frequencyPenalty,
          min: -2.0,
          max: 2.0,
          divisions: 40,
          label: _frequencyPenalty.toStringAsFixed(1),
          onChanged: (value) => setState(() => _frequencyPenalty = value),
        ),
        const Text(
          "正值减少重复内容\n负值增加重复内容",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPresencePenaltySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("存在惩罚:", style: TextStyle(fontSize: 16)),
            Text(_presencePenalty.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: _presencePenalty,
          min: -2.0,
          max: 2.0,
          divisions: 40,
          label: _presencePenalty.toStringAsFixed(1),
          onChanged: (value) => setState(() => _presencePenalty = value),
        ),
        const Text(
          "正值鼓励新话题\n负值停留在当前话题",
          style: TextStyle(fontSize: 12, color: Colors.grey),
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
          "控制发送给AI的历史消息数量",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _exportMessagesToClipboard() async {
    try {
      // 获取所有消息文本
      final messages = await IsarStorageService.exportSessionMessagesToJsonText(widget.session.id, context: context);

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('聊天记录'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: SelectableText(messages),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: messages));
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('聊天记录已复制到剪贴板')),
                  );
                },
                child: const Text('复制全部'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载聊天记录失败: $e')),
      );
    }
  }
  Widget _buildExportButton() {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
              dialogTitle: '选择导出聊天记录的文件夹',
            );

            if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
              try {
                await IsarStorageService.exportSessionMessagesToJson(
                  widget.session.id,
                  context: context,
                  directoryPath: selectedDirectory,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('导出失败: $e')),
                );
              }
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
                Icon(Icons.download, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildExportToClickboardButton() {
    return Column(
      children: [
        InkWell(
          onTap: _exportMessagesToClipboard,
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
                  "导出聊天记录到剪贴板",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.download, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ],
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

  Future<void> _saveSettings() async {
    try {
      await widget.session.updateSettings(
        character:_character,
        systemPrompt: _systemPromptController.text,
        apiSource: _apiSource,
        temperature: _temperature,
        maxContextLength: _maxContextLength,
        topP: _topP,
        frequencyPenalty: _frequencyPenalty,
        presencePenalty: _presencePenalty,
        streamResponse: _streamResponse,
        maxTokens: _maxTokens,
        includeThinking: _includeThinking,
      );

      // 创建更新后的会话对象
      final updatedSession = widget.session.copyWith(
        character:_character,
        systemPrompt: _systemPromptController.text,
        apiSource: _apiSource,
        temperature: _temperature,
        maxContextLength: _maxContextLength,
        topP: _topP,
        frequencyPenalty: _frequencyPenalty,
        presencePenalty: _presencePenalty,
        streamResponse: _streamResponse,
        maxTokens: _maxTokens,
        includeThinking: _includeThinking,
      );
      
      // 触发回调
      widget.onSettingsSaved(updatedSession);
      
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
      _systemPromptController.dispose();
      super.dispose();
    }
}