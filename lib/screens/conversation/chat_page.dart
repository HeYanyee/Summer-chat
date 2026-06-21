import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/voice_service.dart';
import '../../services/tos_service.dart';
import '../../utils/constants.dart';
import 'chat_controller.dart';
import '../../widgets/chat_menu.dart';
import '../../widgets/input_area.dart';
import 'chat_settings_page.dart';
import '../../widgets/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatPage extends StatefulWidget {
  final int sessionId;
  
  const ChatPage({super.key, required this.sessionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _chatController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showMenu = false;
  bool _isFocused = false;
  bool _showEmojiPicker = false;
  String? _selectedImagePath;
  String? _imageDesc;


  @override
  void initState() {
    super.initState();
    // 移到这里初始化
    _chatController = ChatController(
      sessionId: widget.sessionId,
    );

    _chatController.addListener(() => setState(() {}));
    _chatController.initialize();
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
    _chatController.dispose();
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
                _chatController.setGenerating(true);
                String url = '';
                try {
                  url = await TosService.uploadFileAndGetUrl(_selectedImagePath!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('图片上传失败: $e')),
                  );
                  return;
                }
                _chatController.setGenerating(false);
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
                _chatController.sendImageMessage(contentList);

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
    if (_chatController.session == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatSettingsPage(
          session: _chatController.session!,
          onSettingsSaved: (updatedSession) {
            IsarStorageService.updateSession(updatedSession);
            setState(() {
            _chatController.session = updatedSession; // 刷新控制器里的 session
          });
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    if (!_chatController.dateFormatInitialized) return '';
    
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
    if (_chatController.isLoading || !_chatController.dateFormatInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_chatController.session?.title ?? ''),
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
                      // 只展示当前选中的版本或非版本消息
                      final visible = _chatController.messages
                          .where((m) => m.versionGroup == null || m.isChosen)
                          .toList();
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final msg = visible[visible.length - 1 - index];
                          final isLastMessage = index == 0;
                          
                          // 版本信息
                          int? verIdx;
                          int? verTotal;
                          VoidCallback? prevCb;
                          VoidCallback? nextCb;
                          if (msg.versionGroup != null) {
                            final siblings = _chatController.messages
                                .where((m) => m.versionGroup == msg.versionGroup)
                                .toList()
                              ..sort((a, b) => a.versionOrder.compareTo(b.versionOrder));
                            verTotal = siblings.length;
                            final idx = siblings.indexWhere((m) => m.id == msg.id);
                            verIdx = idx == -1 ? null : idx + 1;
                            if (verIdx != null) {
                              if (verIdx! > 1) {
                                prevCb = () async {
                                  await _chatController.chooseVersion(siblings[verIdx! - 2]);
                                };
                              }
                              if (verIdx! < verTotal!) {
                                nextCb = () async {
                                  await _chatController.chooseVersion(siblings[verIdx!]);
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
                            onRollbackComplete: () => _chatController.loadMessages(),
                            onRollbackRequested: _chatController.handleRollback,
                            onRegenerateRequested: _chatController.regenerateLastMessage,
                            onStartLoading: () => _chatController.setGenerating(true),
                            onStopLoading: () => _chatController.setGenerating(false),
                            hideReasoning: false,
                            versionIndex: verIdx,
                            versionTotal: verTotal,
                            onPrevVersion: prevCb,
                            onNextVersion: nextCb,
                          );
                        }
                      );
                    },
                  ),
                ),
                if (_chatController.isGenerating)
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
                          _chatController.sendMessage(text);
                          setState(() => _showEmojiPicker = false); // 发送后关闭表情选择器
                        },
                        isGenerating: _chatController.isGenerating,
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
