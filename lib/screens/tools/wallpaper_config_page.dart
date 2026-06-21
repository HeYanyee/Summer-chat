import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../utils/constants.dart';
import '../../services/storage_service.dart';

class WallpaperConfigPage extends StatefulWidget {
  const WallpaperConfigPage({super.key});

  @override
  State<WallpaperConfigPage> createState() => _WallpaperConfigPageState();
}

class _WallpaperConfigPageState extends State<WallpaperConfigPage> {
  final TextEditingController _pathController = TextEditingController();
  XFile? _selectedFile;
  VideoPlayerController? _videoController;
  bool _isVideo = false;
  bool _isVideoInitializing = false;
  bool _isVideoPlaying = false;

  @override
  void dispose() {
    _pathController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedWallpaperPath();
  }

  Future<void> _loadSavedWallpaperPath() async {
    try {
      final storage = ToolStorageService();
      await storage.initialize();
      final saved = await storage.loadWallpaperPath();
      if (saved == null) return;

      final file = File(saved);
      if (!await file.exists()) {
        // 文件不存在，删除保存的路径
        await storage.deleteWallpaperPath();
        return;
      }

      final isVideo = _isVideoFile(saved);
      setState(() {
        _selectedFile = XFile(saved);
        _isVideo = isVideo;
        _pathController.text = saved;
      });

      if (isVideo) {
        await _initVideoController(saved);
      }
    } catch (e) {
      debugPrint('加载已保存壁纸路径失败: $e');
    }
  }

  /// 判断文件是否为视频（基于扩展名）
  bool _isVideoFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    const videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'm4v'];
    return videoExtensions.contains(extension);
  }

  /// 释放视频控制器资源
  void _releaseVideoController() {
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
    }
    _isVideoPlaying = false;
    _isVideoInitializing = false;
  }
  /// 初始化视频控制器（异步加载，兼容 Windows 和 Android）
  Future<void> _initVideoController(String filePath) async {
    _releaseVideoController();
    setState(() {
      _isVideoInitializing = true;
    });

    // 平台无关的控制器创建方式，官方 video_player 插件会自动调用对应平台的实现
    // Android 上调用自身实现，Windows 上则调用 video_player_win 的实现
    final controller = VideoPlayerController.file(File(filePath));
    _videoController = controller;
    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('视频初始化失败: $e');
      if (mounted) {
        setState(() {
          _isVideoInitializing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('视频加载失败，请确保文件格式受支持。详细错误: $e'),
          ),
        );
      }
    }
  }
  /// 从相册选择图片或视频
  Future<void> _pickMedia() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? media = await picker.pickMedia(
        // 同时允许图片和视频
        requestFullMetadata: false,
      );

      if (media != null) {
        final isVideo = _isVideoFile(media.path);
        setState(() {
          _selectedFile = media;
          _isVideo = isVideo;
          _pathController.text = media.path;
        });

        // 保存所选路径
        try {
          final storage = ToolStorageService();
          await storage.initialize();
          await storage.saveWallpaperPath(media.path);
        } catch (e) {
          debugPrint('保存壁纸路径失败: $e');
        }

        // 如果是视频，初始化播放器
        if (isVideo) {
          await _initVideoController(media.path);
        } else {
          // 图片则释放视频控制器
          _releaseVideoController();
        }
      }
    } catch (e) {
      debugPrint('选择媒体失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('获取相册资源失败，请检查权限')),
      );
    }
  }

  /// 播放/暂停 视频
  void _toggleVideoPlay() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isVideoPlaying = false;
      } else {
        _videoController!.play();
        _isVideoPlaying = true;
      }
    });
  }

  /// 构建图片预览
  Widget _buildImagePreview() {
    if (_selectedFile == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('暂无预览', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(_selectedFile!.path),
        fit: BoxFit.contain,
        height: 300,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey.shade300,
            child: const Center(child: Text('图片加载失败')),
          );
        },
      ),
    );
  }

  /// 构建视频预览
  Widget _buildVideoPreview() {
    if (_selectedFile == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('未选择视频', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_isVideoInitializing) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('加载视频中...'),
            ],
          ),
        ),
      );
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_file, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('视频未就绪', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final aspectRatio = _videoController!.value.aspectRatio;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
        const SizedBox(height: 12),
        // 简易播放控制栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _toggleVideoPlay,
                icon: Icon(
                  _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.primary,
                ),
                tooltip: _isVideoPlaying ? '暂停' : '播放',
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_videoController!.value.duration),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: VideoProgressIndicator(
                  _videoController!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: Colors.grey.shade300,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_videoController!.value.position),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('壁纸配置'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              const Text(
                '壁纸素材',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Text(
              '此更改重启应用后生效',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400,color: AppColors.warmGrey400),
            ),
            const SizedBox(height: 12),
            // 文件路径输入 + 选择按钮 (参考风格)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pathController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: _selectedFile == null ? '未选择任何文件' : '已选择文件',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      suffixIcon: _selectedFile != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                  _pathController.clear();
                                  _isVideo = false;
                                  _releaseVideoController();
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _pickMedia,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.folder_open, size: 24),
                        SizedBox(width: 8),
                        Text('选择文件'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 预览区域标题
            const Text(
              '预览效果',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            // 根据文件类型展示不同预览
            if (_selectedFile == null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('点击上方按钮选择图片或视频', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else if (_isVideo)
              _buildVideoPreview()
            else
              _buildImagePreview(),

            
          ],
        ),
      ),
      ),
    );
  }
}