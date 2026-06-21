import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/voice_service.dart';
import '../../services/tos_service.dart';
import '../../utils/constants.dart';
import 'c_chat_controller.dart';
import '../../widgets/chat_menu.dart';
import '../../widgets/input_area.dart';
import 'character_details_page.dart';
import '../../widgets/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class CharacterChatPage extends StatefulWidget {
  final int characterCardId;
  
  const CharacterChatPage({super.key, required this.characterCardId});

  @override
  State<CharacterChatPage> createState() => _CharacterChatPageState();
}

class _CharacterChatPageState extends State<CharacterChatPage> {
  late final CharacterChatController _characterChatController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showMenu = false;
  bool _isFocused = false;
  bool _showEmojiPicker = false;
  String? _selectedImagePath;
  String? _imageDesc; // 删了报错


  @override
  void initState() {
    super.initState();
    // 移到这里初始化
    _characterChatController = CharacterChatController(
      characterCardId: widget.characterCardId,
    );

    _characterChatController.addListener(() => setState(() {}));
    _characterChatController.initialize();
    VoiceService().initialize();
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          // 获得焦点时关闭菜单和表情选择器
          _showMenu = false;
          _showEmojiPicker = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _characterChatController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  // emoji相关
  // 新增：切换表情选择器
  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
      if (_showEmojiPicker) {
        // 显示表情时关闭键盘和菜单
        _focusNode.unfocus();
        _showMenu = false;
      }
    });
  }

  void showMenuPicker(){
    setState(() {
      _showMenu = !_showMenu;
      if (_showMenu) {
        // 打开菜单时移除输入框焦点
        _focusNode.unfocus();
        _showEmojiPicker = false; // 关闭表情选择器
      }
    });
  }

  // 新增：插入表情到输入框
  void _insertEmoji(String emoji) {
    final text = _textController.text;
    final selection = _textController.selection;
    if(selection.start == -1) {
      // 如果没有选中任何文本，则在光标位置插入表情
      _textController.text += emoji;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length + emoji.length),
      );
      return;
    }
    final newText = text.replaceRange(selection.start, selection.end, emoji);
    
    _textController.text = newText;
    _textController.selection = selection.copyWith(
      baseOffset: selection.start + emoji.length,
      extentOffset: selection.start + emoji.length,
    );
  }

  // 图片上传窗口
  void _showImageUploadDialog() async {
    // 1. 选择图片
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _selectedImagePath = result.files.single.path;
      _imageDesc = '';
    });

    // 2. 弹窗输入说明
    showDialog(
      context: context,
      builder: (context) {
        final descController = TextEditingController();
        return AlertDialog(
          title: const Text('发送图片'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedImagePath ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '图片说明（可选）',
                  border: OutlineInputBorder(),
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedImagePath = null;
                  _imageDesc = null;
                });
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final desc = descController.text.trim();
                Navigator.pop(context);

                if (_selectedImagePath == null) return;

                // 3. 上传图片到TOS，获取URL
                _characterChatController.setGenerating(true);
                String url = '';
                try {
                  url = await TosService.uploadFileAndGetUrl(_selectedImagePath!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('图片上传失败: $e')),
                  );
                  return;
                }
                _characterChatController.setGenerating(false);
                // 4. 构造消息内容
                final List<Map<String, dynamic>> contentList = [
                  {
                    "type": "image_url",
                    "image_url": {"url": url},
                  },
                ];
                if (desc.isNotEmpty) {
                  contentList.add({
                    "type": "text",
                    "text": desc,
                  });
                }
                // 5. 发送消息
                _characterChatController.sendImageMessage(contentList);

                setState(() {
                  _selectedImagePath = null;
                  _imageDesc = null;
                });
              },
              child: const Text('发送'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSettings(BuildContext context) {
    if (_characterChatController.characterCard == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterDetailsPage(
          card: _characterChatController.characterCard!,
          onSettingsSaved: (card) {
            IsarStorageService.saveCharacterCard(card);
            setState(() {
            // _characterChatController.characterCard=card;
            _characterChatController.updateCharacterCard(card);
          });
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    if (!_characterChatController.dateFormatInitialized) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (timestamp.isAfter(today)) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (timestamp.isAfter(yesterday)) {
      return '昨天 ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return '${DateFormat('MM/dd').format(timestamp)} ${DateFormat('HH:mm').format(timestamp)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_characterChatController.isLoading || !_characterChatController.dateFormatInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_characterChatController.characterCard?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: Stack(
        children: [
                    if (_showMenu)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _showMenu = false),
            ),
          Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final visible = _characterChatController.messages;
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final msg = visible[visible.length - 1 - index];
                          final isLastMessage = index == 0;
                          
                          int? verIdx;
                          int? verTotal;
                          VoidCallback? prevCb;
                          VoidCallback? nextCb;
                          if (msg.versionGroup != null) {
                            final siblings = _characterChatController.getVersionsForGroup(msg.versionGroup!);
                            verTotal = siblings.length;
                            final idx = siblings.indexWhere((m) => m.id == msg.id);
                            verIdx = idx == -1 ? null : idx + 1;
                            if (verIdx != null) {
                              if (verIdx > 1) {
                                prevCb = () async {
                                  await _characterChatController.chooseVersion(siblings[verIdx! - 2]);
                                };
                              }
                              if (verIdx < verTotal) {
                                nextCb = () async {
                                  await _characterChatController.chooseVersion(siblings[verIdx!]);
                                };
                              }
                            }
                          }

                          return ChatBubble(
                            key: ValueKey('${msg.id}_${msg.timestamp}_${msg.isChosen}'),
                            message: msg,
                            role: msg.role,
                            timestampText: _formatTime(msg.timestamp),
                            horizontalMargin: 8,
                            isLastMessage: isLastMessage,
                            hideReasoning: _characterChatController.characterCard?.hideReasoningBubbles ?? false, // 传递设置
                            onRollbackComplete: () => _characterChatController.loadMessages(),
                            onRollbackRequested: _characterChatController.handleRollback,
                            onRegenerateRequested: _characterChatController.regenerateLastMessage,
                            onStartLoading: () => _characterChatController.setGenerating(true),
                            onStopLoading: () => _characterChatController.setGenerating(false),
                            versionIndex: verIdx,
                            versionTotal: verTotal,
                            onPrevVersion: prevCb,
                            onNextVersion: nextCb,
                          );
                        },
                      );
                    },
                  )
                ),
                if (_characterChatController.isGenerating)
                  const LinearProgressIndicator(),
                SafeArea(
                  child: Column(
                    children: [
                      if (_showMenu)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ChatMenu(
                            onEmoji: _toggleEmojiPicker,
                            onImage: _showImageUploadDialog, // 直接传递方法
                            onFile: () => print("文件上传"),
                            onVoice: () => print("语音输入"),
                          ),
                        ),
                      if (_showEmojiPicker) // 新增：表情选择器
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // 动态计算列数和高度
                            final width = constraints.maxWidth;
                            final emojiSizeMax = 24.0;
                            final columnCount = (width/emojiSizeMax/2).toInt();//(width / 50).clamp(5, 10).floor(); // 5-10列动态调整
                            final height = 200.0;//constraints.maxHeight * 0.4; // 占可用高度的40%

                            return SizedBox(
                              height: height,
                              child: EmojiPicker(
                                onEmojiSelected: (category, emoji) {
                                  _insertEmoji(emoji.emoji);
                                },
                                config: Config(
                                  emojiViewConfig: EmojiViewConfig(
                                    columns: columnCount, // 动态列数
                                    emojiSizeMax: emojiSizeMax,//32.0 * (columnCount / 7), // 根据列数缩放表情大小
                                    recentsLimit: 28,                  
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      InputArea(
                        controller: _textController, // 传入controller
                        onSend: (text) {
                          _characterChatController.sendMessage(text);
                          setState(() => _showEmojiPicker = false); // 发送后关闭表情选择器
                        },
                        isGenerating: _characterChatController.isGenerating,
                        showMenu: _showMenu,
                        showMenuPicker: showMenuPicker, // 新增回调
                        toggleEmojiPicker: _toggleEmojiPicker, // 新增回调
                        focusNode: _focusNode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
