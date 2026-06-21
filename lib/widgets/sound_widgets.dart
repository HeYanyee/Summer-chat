// lib/widgets/sound_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../screens/home/sound_controller.dart';
import '../utils/constants.dart';

// ==================== 分类标签组件 ====================

class CategoryTabs extends StatelessWidget {
  final SoundMixerController controller = Get.find<SoundMixerController>();
  
  CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = controller.categories;
      
      if (categories.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: categories.map((category) {
            return _buildCategoryChip(category);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildCategoryChip(SoundCategory category) {
    return Obx(() {
      final isSelected = controller.selectedCategory.value == category;
      
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(
            category.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            controller.selectedCategory.value = category;
          },
          backgroundColor: Colors.grey[50],
          selectedColor: AppColors.primary.withOpacity(0.15),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey[700],
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    });
  }
}

// ==================== 声音卡片组件 ====================

class SoundCard extends StatelessWidget {
  final SoundItem sound;
  
  const SoundCard({
    super.key,
    required this.sound,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = sound.isPlaying.value;
      
      return GestureDetector(
        onTap: () => _handleTap(context),
        child: Container(
          decoration: _buildCardDecoration(isActive),
          child: Stack(
            children: [
              // 使用 Center 包裹主要内容，确保始终居中
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // 添加这个属性
                  children: [
                    // 图标部分
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: sound.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              sound.name.isNotEmpty ? sound.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: sound.color,
                              ),
                            ),
                          ),
                        ),
                        // 添加音量控制图标（仅在激活时显示）
                        if (isActive)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showVolumeControl(context),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: sound.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 名称
                    Text(
                      sound.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? sound.color : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (isActive) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.volume_down,
                              size: 14,
                              color: sound.color.withOpacity(0.5),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                  activeTrackColor: sound.color,
                                  inactiveTrackColor: sound.color.withOpacity(0.2),
                                  thumbColor: sound.color,
                                ),
                                child: Slider(
                                  value: sound.volume.value,
                                  onChanged: (value) {
                                    final controller = Get.find<SoundMixerController>();
                                    controller.adjustVolume(sound, value);
                                  },
                                  min: 0,
                                  max: 1,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.volume_up,
                              size: 14,
                              color: sound.color.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      // 音量百分比
                      Text(
                        '${(sound.volume.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: sound.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] 
                  ],
                ),
              ),
              
              // 播放状态指示器
              if (isActive)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: sound.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: sound.color.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
  
  BoxDecoration _buildCardDecoration(bool isActive) {
    return BoxDecoration(
      color: isActive 
          ? sound.color.withOpacity(0.1)
          : Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isActive 
            ? sound.color.withOpacity(0.3)
            : Colors.grey[200]!,
        width: isActive ? 2 : 1, 
      ),
      boxShadow: isActive
          ? [
              BoxShadow(
                color: sound.color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
          : null,
    );
  }

  void _handleTap(BuildContext context) {
    final controller = Get.find<SoundMixerController>();
    controller.toggleSound(sound);
    
    // 简单的触感反馈
    HapticFeedback.lightImpact();
  }

  void _showVolumeControl(BuildContext context) {
    // 显示一个迷你音量控制弹窗
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VolumeControlSheet(sound: sound),
    );
  }
}
// ==================== 音量控制滑块 ====================

class VolumeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final Color color;
  
  const VolumeSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        activeTrackColor: color,
        inactiveTrackColor: color.withOpacity(0.2),
        thumbColor: color,
        overlayColor: color.withOpacity(0.1),
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: 0,
        max: 1,
      ),
    );
  }
}

// ==================== 音量控制面板 ====================

class VolumeControlSheet extends StatelessWidget {
  final SoundItem sound;
  
  const VolumeControlSheet({
    super.key,
    required this.sound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部指示条
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // 声音信息
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: sound.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    sound.name.isNotEmpty ? sound.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: sound.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sound.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '详细音量控制',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 大尺寸音量滑块
          Obx(() => Column(
            children: [
              VolumeSlider(
                value: sound.volume.value,
                color: sound.color,
                onChanged: (value) {
                  final controller = Get.find<SoundMixerController>();
                  controller.adjustVolume(sound, value);
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.volume_mute, color: Colors.grey[400], size: 20),
                  Text(
                    '${(sound.volume.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: sound.color,
                    ),
                  ),
                  Icon(Icons.volume_up, color: Colors.grey[400], size: 20),
                ],
              ),
            ],
          )),
          
          const SizedBox(height: 24),
          
          // 关闭按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: sound.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('完成'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 当前播放条 ====================
// TODO：
class NowPlayingBar extends StatelessWidget {
  final SoundMixerController controller = Get.find<SoundMixerController>();
  
  NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.activeSounds.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '正在播放 (${controller.activeSounds.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  // 只保留主音量控制
                  Row(
                    children: [
                      Icon(Icons.volume_down, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 80,
                        child: Obx(() => Slider(
                          value: controller.masterVolume.value,
                          onChanged: controller.setMasterVolume,
                          min: 0,
                          max: 1,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.primary.withOpacity(0.2),
                        )),
                      ),
                      Icon(Icons.volume_up, size: 16, color: Colors.grey[500]),
                    ],
                  ),
                ],
              ),
            ),
            
            // 水平滚动的声音列表（简化版，只显示名称和停止按钮）
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: controller.activeSounds.length,
                itemBuilder: (context, index) {
                  final sound = controller.activeSounds[index];
                  return _buildActiveSoundItem(sound);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActiveSoundItem(SoundItem sound) {
    return Obx(() => Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: sound.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sound.color.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // 首字母图标
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: sound.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                sound.name.isNotEmpty ? sound.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: sound.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          
          // 名称
          Expanded(
            child: Text(
              sound.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 停止按钮
          GestureDetector(
            onTap: () {
              final controller = Get.find<SoundMixerController>();
              controller.toggleSound(sound);
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: sound.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: sound.color,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

// ==================== 头部组件 ====================

class MixerHeader extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onPresets;
  
  const MixerHeader({
    super.key,
    required this.onClose,
    required this.onPresets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '白噪音混合器',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '混合你的专属氛围',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Row(
            // children: [
              // 预设按钮
            //   Container(
            //     decoration: BoxDecoration(
            //       color: Colors.grey[100],
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: IconButton(
            //       icon: const Icon(Icons.bookmark_outline),
            //       onPressed: onPresets,
            //       color: Colors.grey[700],
            //     ),
            //   ),
            //   const SizedBox(width: 8),
            //   // 关闭按钮
            //   Container(
            //     decoration: BoxDecoration(
            //       color: Colors.grey[100],
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: IconButton(
            //       icon: const Icon(Icons.close),
            //       onPressed: onClose,
            //       color: Colors.grey[700],
            //     ),
            //   ),
            // ],
          ),
        ],
      ),
    );
  }
}

// ==================== 空状态组件 ====================

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String emoji;
  
  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
