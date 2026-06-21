import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ChatMenu extends StatelessWidget {
  final VoidCallback onEmoji;
  final VoidCallback onImage;
  final VoidCallback onFile;
  final VoidCallback onVoice;

  const ChatMenu({
    super.key,
    required this.onEmoji,
    required this.onImage,
    required this.onFile,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(24),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMenuItem(
                icon: Icons.emoji_emotions_outlined,
                label: "表情",
                onTap: onEmoji,
              ),
              _buildMenuItem(
                icon: Icons.image_outlined,
                label: "图片",
                onTap: onImage,
              ),
              _buildMenuItem(
                icon: Icons.insert_drive_file_outlined,
                label: "文件",
                onTap: onFile,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // _buildMenuItem(
              //   icon: Icons.mic_none_outlined,
              //   label: "语音输入",
              //   onTap: onVoice,
              // ),
              // _buildMenuItem(
              //   icon: Icons.video_call_outlined,
              //   label: "视频通话",
              //   onTap: () {},
              // ),
              // _buildMenuItem(
              //   icon: Icons.location_on_outlined,
              //   label: "位置",
              //   onTap: () {},
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.blue.withAlpha(50), // 添加点击反馈
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warmGrey200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 28, color: AppColors.warmGrey600),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}