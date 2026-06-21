import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class InputArea extends StatefulWidget {
  final TextEditingController controller; // 新增
  final void Function(String) onSend;
  final bool isGenerating;
  final bool showMenu;
  final VoidCallback showMenuPicker;
  final VoidCallback toggleEmojiPicker; // 新增：切换表情选择器
  final FocusNode focusNode;

  const InputArea({
    super.key,
    required this.controller, // 新增
    required this.onSend,
    required this.isGenerating,
    required this.showMenu,
    required this.showMenuPicker,
    required this.toggleEmojiPicker, // 新增
    required this.focusNode,
  });


  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {

  void insertText(String text) {
    final cursorPosition = widget.controller.selection.base.offset;
    if (cursorPosition == -1) {
      // 在末尾插入
      widget.controller.text += text;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
    } else {
      // 在光标处插入
      final newText = widget.controller.text.replaceRange(
        cursorPosition, 
        cursorPosition, 
        text
      );
      final newCursorPosition = cursorPosition + text.length;
      widget.controller.text = newText;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: newCursorPosition),
      );
    }
  }

void _handleKeyEvent(KeyEvent event) {
  if (event is KeyDownEvent) {
    final isEnterPressed = event.logicalKey == LogicalKeyboardKey.enter;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    if (isEnterPressed && !isShiftPressed) {
      // 阻止默认的换行行为
      if (!widget.isGenerating) {
        _send();
      }
      return; // 关键：阻止事件继续传播
    }
  }
}

  @override
  Widget build(BuildContext context) {
    
    return 
    KeyboardListener(
            focusNode: FocusNode(skipTraversal: true),
            onKeyEvent: _handleKeyEvent,
            child:Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: widget.showMenu 
                              ? Theme.of(context).primaryColor 
                              : AppColors.warmGrey600,
                        ),
                        onPressed: widget.showMenuPicker,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          enabled: !widget.isGenerating,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: '请输入消息…',
                            filled: true,
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, 
                              vertical: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.warmGrey400, 
                                width: 1.5,
                              ),
                            ),
                            // 新增：聚焦状态下的边框
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor, // 聚焦时更醒目的颜色
                                width: 2.0,                  // 聚焦时边框稍粗
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: Theme.of(context).primaryColor,
                        onPressed: widget.isGenerating ? null : _send,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // void _send() {
  //   final text = widget.controller.text.trim();
  //   if (text.isNotEmpty) {
  //     widget.onSend(text); 
  //     widget.controller.clear();
  //   }
  //   // 发送后清空输入框
  //   widget.controller.clear();
  //   widget.focusNode.requestFocus(); // 保持焦点在输入框    
  // }
  void _send() {
    final text = widget.controller.text.trim();
    widget.controller.value = TextEditingValue.empty; // 强制清空
    widget.controller.clear();
    
    if (text.isNotEmpty) {
      widget.onSend(text);
    }
    
    // 双重保险：延迟微秒级再清空一次
    Future.microtask(() {
      if (widget.controller.text.isNotEmpty) {
        widget.controller.clear();
      }
    });
    
    widget.focusNode.requestFocus();
  }
}