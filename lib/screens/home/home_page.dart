// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:summer/utils/constants.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import '../../services/storage_service.dart';
// lib/screens/sound_mixer_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'sound_controller.dart';
import '../../widgets/sound_widgets.dart';

class WhiteNoiseMixer extends StatelessWidget {
  const WhiteNoiseMixer({super.key});

  @override
  Widget build(BuildContext context) {
    // 控制器已在 HomePage 中初始化
    
    return Container(
      color: Colors.white.withOpacity(0.95),
      child: SafeArea(
        child: Obx(() {
          final controller = Get.find<SoundMixerController>();
          
          // 显示加载状态
          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载声音文件...'),
                ],
              ),
            );
          }
          
          // 正常显示内容
          return Column(
            children: [
              CategoryTabs(),
              const Expanded(
                child: SoundGrid(),
              ),
              // NowPlayingBar(),
            ],
          );
        }),
      ),
    );
  }

}

// ==================== 声音网格组件 ====================

class SoundGrid extends StatelessWidget {
  const SoundGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SoundMixerController>();
    
    return Obx(() {
      final sounds = controller.getSoundsByCategory(controller.selectedCategory.value);
      
      if (sounds.isEmpty) {
        return EmptyStateWidget(
          message: '该分类暂无声音',
          emoji: '🎵',
        );
      }
      
      // 计算卡片宽度和期望的高度
      final screenWidth = MediaQuery.of(context).size.width;
      final padding = 16.0 * 2; // 左右内边距
      final spacing = 12.0 * 4; // 5列有4个间距
      final cardWidth = (screenWidth - padding - spacing) / 5;
      final desiredHeight = 80.0; // 你想要的高度
      
      // 计算宽高比
      final aspectRatio = cardWidth / desiredHeight;
      
      // 音乐卡片网格
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: aspectRatio, // 使用计算出的比例
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          return SoundCard(sound: sounds[index]);
        },
      );
    });
  }
}


// ==================== HomePage ====================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isMusicPanelOpen = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // 添加一个标志来跟踪控制器是否已初始化
  bool _isControllerInitialized = false;

  // 壁纸相关
  String? _wallpaperPath;
  bool _isVideoWallpaper = false;
  VideoPlayerController? _wallpaperVideoController;
  bool _isWallpaperVideoInitializing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 预先初始化控制器，但不显示面板
    _initControllers();
    _loadWallpaper();
  }

  Future<void> _loadWallpaper() async {
    try {
      final storage = ToolStorageService();
      await storage.initialize();
      final saved = await storage.loadWallpaperPath();
      if (saved == null || saved.isEmpty) return;

      final file = File(saved);
      if (!await file.exists()) {
        // 如果文件已不存在，则删除保存记录
        await storage.deleteWallpaperPath();
        return;
      }

      final extension = saved.split('.').last.toLowerCase();
      const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'm4v'];
      final isVideo = videoExtensions.contains(extension);

      setState(() {
        _wallpaperPath = saved;
        _isVideoWallpaper = isVideo;
      });

      if (isVideo) {
        // 初始化视频控制器并静音循环播放
        _isWallpaperVideoInitializing = true;
        _wallpaperVideoController = VideoPlayerController.file(File(saved));
        try {
          await _wallpaperVideoController!.initialize();
          await _wallpaperVideoController!.setLooping(true);
          await _wallpaperVideoController!.setVolume(0.0);
          await _wallpaperVideoController!.play();
        } catch (e) {
          debugPrint('初始化壁纸视频失败: $e');
          // 失败则回退到默认背景
          setState(() {
            _wallpaperPath = null;
            _isVideoWallpaper = false;
          });
        } finally {
          if (mounted) {
            setState(() {
              _isWallpaperVideoInitializing = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('加载壁纸失败: $e');
    }
  }

  void _initControllers() {
    if (!_isControllerInitialized) {
      // 使用permanent: true让控制器常驻内存
      Get.put(AudioPlayerService(), permanent: true);
      Get.put(SoundMixerController(), permanent: true);
      _isControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    _wallpaperVideoController?.dispose();
    _animationController.dispose();
    // 只在页面完全销毁时清理控制器
    if (_isControllerInitialized) {
      Get.delete<SoundMixerController>();
      Get.delete<AudioPlayerService>();
    }
    super.dispose();
  }

  void _toggleMusicPanel() {
    setState(() {
      _isMusicPanelOpen = !_isMusicPanelOpen;
      if (_isMusicPanelOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景：优先使用已选择的壁纸（图片或视频），否则使用默认背景
          Positioned.fill(
            child: Builder(builder: (context) {
              if (_wallpaperPath == null) {
                return Image.asset(
                  'assets/images/bg_day.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                );
              }

              if (_isVideoWallpaper) {
                final controller = _wallpaperVideoController;
                if (controller == null || !controller.value.isInitialized) {
                  // 视频未初始化时显示占位或黑色背景
                  return Container(color: Colors.black);
                }

                // 使用 FittedBox + SizedBox 来实现 VideoPlayer 的 cover 效果
                final videoSize = controller.value.size;
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: videoSize.width,
                      height: videoSize.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                );
              }

              // 图片壁纸：按界面大小铺满，保持比例（cover）
              return Image.file(
                File(_wallpaperPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/bg_day.jpg',
                    fit: BoxFit.cover,
                  );
                },
              );
            }),
          ),
          
          // 音乐控制面板（半透明）- 只有在打开时才显示内容
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white.withAlpha(48),
                    // 只有在面板打开且控制器初始化后才显示内容
                    child: _isMusicPanelOpen && _isControllerInitialized 
                        ? const WhiteNoiseMixer() 
                        : null,
                  ),
                ),
              );
            },
          ),
          
          // 右下角的音乐按钮 - 根据播放状态改变图标
          Positioned(
            right: MediaQuery.of(context).size.width * 0.04,
            // right: 20,
            // bottom: 72,
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: Obx(() {
              try {
                // 尝试获取控制器
                final controller = Get.find<SoundMixerController>();
                
                return FloatingActionButton(
                  onPressed: _toggleMusicPanel,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Icon(
                    controller.isAnySoundPlaying 
                        ? Icons.music_note
                        : Icons.music_off,
                    color: controller.isAnySoundPlaying 
                        ? AppColors.primary 
                        : Colors.grey,
                    size: 30,
                  ),
                );
              } catch (e) {
                // 如果控制器还未初始化，显示默认图标
                return FloatingActionButton(
                  onPressed: _toggleMusicPanel,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(
                    Icons.music_off,
                    color: Colors.grey,
                    size: 30,
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
