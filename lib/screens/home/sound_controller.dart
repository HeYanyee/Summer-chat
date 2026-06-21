// lib/controllers/sound_controller.dart
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../utils/constants.dart';

// 声音分类枚举 - 改为动态生成
enum SoundCategory {
  nature, rain, defalt, urban, instrumental, userDefined;
  
  // 获取显示名称（首字母大写）
  String get displayName {
    switch (this) {
      case SoundCategory.nature:
        return '自然';
      case SoundCategory.rain:
        return '雨声';
      case SoundCategory.defalt:
        return '默认';
      case SoundCategory.urban:
        return '城市';
      case SoundCategory.instrumental:
        return '乐器';
      case SoundCategory.userDefined:
        return '自定义';
    }
  }
  
  // 从文件夹名创建枚举
  static SoundCategory fromFolderName(String folderName) {
    switch (folderName.toLowerCase()) {
      case 'nature':
        return SoundCategory.nature;
      case 'rain':
        return SoundCategory.rain;
      case 'userDefined':
        return SoundCategory.userDefined;
      case 'urban':
        return SoundCategory.urban;
      case 'instrumental':
        return SoundCategory.instrumental;
      case 'default':
      default:
        return SoundCategory.defalt; // 默认分类
    }
  }
}

// 声音项目模型 - 简化，移除emoji和iconPath
class SoundItem {
  final String id;              // 唯一标识
  final String name;            // 显示名称（文件名）
  final String assetPath;       // 完整的音频文件路径
  final Color color;            // 主题色（基于文件名生成）
  final SoundCategory category; // 分类
  final String fileName;        // 原始文件名
  
  RxDouble volume;              // 当前音量 (0.0-1.0)
  RxBool isPlaying;             // 播放状态
  
  SoundItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.color,
    required this.category,
    required this.fileName,
    double initialVolume = 0.5,
    bool initialPlaying = false,
  }) : 
    volume = RxDouble(initialVolume),
    isPlaying = RxBool(initialPlaying);
  
  // 复制方法
  SoundItem copyWith({
    double? volume,
    bool? isPlaying,
  }) {
    final newItem = SoundItem(
      id: id,
      name: name,
      assetPath: assetPath,
      color: color,
      category: category,
      fileName: fileName,
      initialVolume: volume ?? this.volume.value,
      initialPlaying: isPlaying ?? this.isPlaying.value,
    );
    return newItem;
  }
}

// 音频播放器服务
class AudioPlayerService extends GetxService {
  // 音频播放器实例缓存
  final Map<String, AudioPlayer> _players = {};
  final Map<String, String> _soundPaths = {};
  final Map<String, bool> _loopEnabled = {};
  
  bool _isDisposed = false;
  
  // 初始化音频
  Future<void> initSound(String id, String assetPath, {bool loop = true}) async {
    if (_players.containsKey(id)) return;
    
    _soundPaths[id] = assetPath;
    _loopEnabled[id] = loop;
    
    final player = AudioPlayer();
    
    // 配置播放器
    await _configurePlayer(player, id, loop);
    
    // 设置监听器
    _setupListeners(player, id);
    
    _players[id] = player;
  }
  
  // 配置播放器
  Future<void> _configurePlayer(AudioPlayer player, String id, bool loop) async {
    try {
      // 设置音频会话（iOS/Android）
      await player.setAudioContext(AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: [
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          ],
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          // 使用可 duck 的短时焦点，避免抢占其它媒体（如背景视频）
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ));
      
      // 设置循环模式
      if (loop) {
        await player.setReleaseMode(ReleaseMode.loop);
      } else {
        await player.setReleaseMode(ReleaseMode.stop);
      }
      
      // 设置音量（默认）
      await player.setVolume(0.5);
      
    } catch (e) {
      print('配置播放器失败 $id: $e');
    }
  }
  
  // 设置监听器
  void _setupListeners(AudioPlayer player, String id) {
    // 播放完成监听（循环模式下不会触发）
    player.onPlayerComplete.listen((event) {
      print('音频 $id 播放完成');
    });
    
    // 状态变化监听
    player.onPlayerStateChanged.listen((state) {
      print('音频 $id 状态: $state');
    });
    
    // 错误监听（audioplayers 不再支持 onPlayerError，已移除）
    // 可以在 try-catch 中处理错误
    
    // 位置变化监听（可选）
    player.onPositionChanged.listen((position) {
      // 可以用于更新播放进度
      // print('音频 $id 位置: $position');
    });
    
    // 持续时间变化监听
    player.onDurationChanged.listen((duration) {
      print('音频 $id 时长: $duration');
    });
  }
  
  // 播放声音
  Future<void> play(String id) async {
    final player = _players[id];
    if (player == null) return;
    
    final path = _soundPaths[id];
    if (path == null) return;
    
    try {
      final state = await player.state;
      
      if (state == PlayerState.playing) {
        // 如果正在播放，可以选择从头开始或忽略
        await player.stop();
      }
      
      // 重新确保循环模式
      await player.setReleaseMode(
        _loopEnabled[id] == true ? ReleaseMode.loop : ReleaseMode.stop
      );
      
      // 开始播放
      await player.play(AssetSource(path.replaceFirst('assets/', '')));
      
      print('开始播放音频 $id');
    } catch (e) {
      print('播放声音失败 $id: $e');
    }
  }
  
  // 暂停声音
  Future<void> pause(String id) async {
    final player = _players[id];
    if (player == null) return;
    
    try {
      await player.pause();
    } catch (e) {
      print('暂停声音失败 $id: $e');
    }
  }
  
  // 恢复播放
  Future<void> resume(String id) async {
    final player = _players[id];
    if (player == null) return;
    
    try {
      await player.resume();
    } catch (e) {
      print('恢复声音失败 $id: $e');
    }
  }
  
  // 停止声音
  Future<void> stop(String id) async {
    final player = _players[id];
    if (player == null) return;
    
    try {
      await player.stop();
    } catch (e) {
      print('停止声音失败 $id: $e');
    }
  }
  
  // 设置音量
  Future<void> setVolume(String id, double volume) async {
    final player = _players[id];
    if (player == null) return;
    
    try {
      await player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('设置音量失败 $id: $e');
    }
  }
  
  // 设置循环模式
  Future<void> setLoopMode(String id, bool enabled) async {
    final player = _players[id];
    if (player == null) return;
    
    _loopEnabled[id] = enabled;
    
    try {
      await player.setReleaseMode(
        enabled ? ReleaseMode.loop : ReleaseMode.stop
      );
    } catch (e) {
      print('设置循环模式失败 $id: $e');
    }
  }
  
  // 跳转到指定位置
  Future<void> seek(String id, Duration position) async {
    final player = _players[id];
    if (player == null) return;
    
    try {
      await player.seek(position);
    } catch (e) {
      print('跳转位置失败 $id: $e');
    }
  }
  
  // 获取播放状态
  Future<PlayerState?> getState(String id) async {
    final player = _players[id];
    if (player == null) return null;
    
    try {
      return await player.state;
    } catch (e) {
      print('获取状态失败 $id: $e');
      return null;
    }
  }
  
  // 检查是否在播放
  Future<bool> isPlaying(String id) async {
    final state = await getState(id);
    return state == PlayerState.playing;
  }
  
  // 停止所有声音
  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
  }
  
  // 释放单个播放器
  Future<void> disposePlayer(String id) async {
    final player = _players.remove(id);
    if (player != null) {
      await player.dispose();
    }
    _soundPaths.remove(id);
    _loopEnabled.remove(id);
  }
  
  // 释放所有资源
  void disposeAll() {
    _isDisposed = true;
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _soundPaths.clear();
    _loopEnabled.clear();
  }
  
  @override
  void onClose() {
    disposeAll();
    super.onClose();
  }
}

// 主控制器
class SoundMixerController extends GetxController {
  final AudioPlayerService _audioService = Get.find<AudioPlayerService>();
  
  // 所有可用的声音列表
  final RxList<SoundItem> availableSounds = <SoundItem>[].obs;
  
  // 当前活跃的声音
  final RxList<SoundItem> activeSounds = <SoundItem>[].obs;
  
  // 主音量控制
  final RxDouble masterVolume = 1.0.obs;
  
  // 当前选中的分类
  final Rx<SoundCategory> selectedCategory = SoundCategory.nature.obs;
  
  // 加载状态
  final RxBool isLoading = true.obs;
  
  // 添加一个标志来防止重复初始化
  final Set<String> _initializedSounds = {};

  // 在 SoundMixerController 类中添加
  bool get isAnySoundPlaying {
    return availableSounds.any((sound) => sound.isPlaying.value);
  }
  
  @override
  void onInit() {
    super.onInit();
    loadSoundsFromAssets();
    
    // 使用debounce来避免频繁触发
    ever(activeSounds, _handleActiveSoundsChange);
  }
  
  // 从assets动态加载声音文件
  Future<void> loadSoundsFromAssets() async {
    isLoading.value = true;
    
    try {
      // 使用官方 API 加载资源清单
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

      // 获取所有资源路径列表
      final List<String> assets = manifest.listAssets();

      // 筛选所有音频文件
      final List<String> soundFiles = assets.where((String key) {
        return key.startsWith('assets/sounds/') && 
              (key.endsWith('.mp3') || key.endsWith('.wav') || 
                key.endsWith('.m4a') || key.endsWith('.aac'));
      }).toList();

      print('找到 ${soundFiles.length} 个音频文件');

      if (soundFiles.isEmpty) {
        print('警告: 没有找到音频文件');
        _loadDefaultSounds();
        return;
      }
      
      // 解析文件路径
      final List<SoundItem> sounds = [];
      
      for (final filePath in soundFiles) {
        // 文件路径示例: assets/sounds/ambient/rain.mp3
        print('处理文件: $filePath');

        // 提取路径各部分，尝试找到'sounds'目录后面的子文件夹作为分类
        final parts = filePath.split('/');
        final lowerParts = parts.map((p) => p.toLowerCase()).toList();

        // 默认分类名
        String categoryName = 'default';
        final soundsIndex = lowerParts.indexOf('sounds');
        if (soundsIndex != -1 && lowerParts.length > soundsIndex + 1) {
          // 下一个 segment 视为分类名（可能直接是文件名，需判断）
          final candidate = parts[soundsIndex + 1];
          // 如果 candidate 看起来像文件（包含扩展名），则没有分类
          if (!candidate.contains('.')) {
            categoryName = candidate;
          }
        }

        final fileName = parts.isNotEmpty ? parts.last : filePath;
        final nameWithoutExt = fileName.contains('.')
            ? fileName.substring(0, fileName.lastIndexOf('.'))
            : fileName;

        // 生成唯一ID（包含分类）
        final id = '${categoryName}_${nameWithoutExt}'
            .replaceAll(' ', '_')
            .replaceAll(RegExp(r'[^\w\u4e00-\u9fff]'), '')
            .toLowerCase();

        // 生成颜色 & 显示名
        final color = _generateColorFromName(nameWithoutExt);
        final displayName = _formatSoundName(nameWithoutExt);

        // 将文件夹名映射到 SoundCategory（从Folder名创建枚举）
        final category = SoundCategory.fromFolderName(categoryName);

        print('添加声音: $displayName  分类: $categoryName -> $category');
        print('Asset路径: $filePath');

        sounds.add(SoundItem(
          id: id,
          name: displayName,
          assetPath: filePath,
          color: color,
          category: category,
          fileName: nameWithoutExt,
        ));
      }
      
      availableSounds.assignAll(sounds);
      print('成功加载 ${sounds.length} 个声音');
      
    } catch (e, stackTrace) {
      try {
        final data = await rootBundle.load('assets/sounds/nature/water-stream.mp3');
        print('✅ 声音文件加载成功: ${data.lengthInBytes} bytes');
      } catch (e) {
        print('❌ 声音文件加载失败: $e');
      }
      print('加载声音文件失败: $e');
      print('堆栈: $stackTrace');
      _loadDefaultSounds();
    } finally {
      isLoading.value = false;
    }
  }
  
  // 格式化文件名（移除扩展名、下划线等）
  String _formatSoundName(String fileName) {
    // 移除扩展名
    String name = fileName.replaceAll(RegExp(r'\.[^.]*$'), '');
    
    // 替换下划线和连字符为空格
    name = name.replaceAll('_', ' ').replaceAll('-', ' ');
    
    // 每个单词首字母大写
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  // 基于文件名生成颜色
  Color _generateColorFromName(String name) {
    // 使用文件名的hashCode来生成一个固定的颜色
    final hash = name.hashCode.abs();
    
    // 预定义一些好看的颜色
    const colors = [
      Color(0xFF4A90E2), // 蓝色
      Color(0xFF50E3C2), // 青色
      Color(0xFFF5A623), // 橙色
      Color(0xFF7ED321), // 绿色
      Color(0xFF9013FE), // 紫色
      Color(0xFFFF6B6B), // 红色
      Color(0xFFFF8B57), // 橘色
      Color(0xFFA59E8C), // 棕色
      Color(0xFFB8E986), // 浅绿
      Color(0xFF4A90E2), // 深蓝
    ];
    
    return colors[hash % colors.length];
  }
  
  // 后备方案：如果加载失败，使用一些默认声音
  void _loadDefaultSounds() {
    availableSounds.assignAll([
      SoundItem(
        id: 'default_1',
        name: '默认声音 1',
        assetPath: 'assets/sounds/default.mp3',
        color: AppColors.primary,
        category: SoundCategory.defalt,
        fileName: 'default.mp3',
      ),
    ]);
  }
  
  // 获取所有分类
  List<SoundCategory> get categories {
    // 从已加载的声音中提取所有存在的分类
    final Set<SoundCategory> categorySet = {};
    for (final sound in availableSounds) {
      categorySet.add(sound.category);
    }
    return categorySet.toList()..sort((a, b) => a.index.compareTo(b.index));
  }
  
  // 处理活跃声音变化（修复版）
  void _handleActiveSoundsChange(List<SoundItem> sounds) {
    // 使用Future.microtask避免在build过程中更新
    Future.microtask(() {
      for (final sound in sounds) {
        // 只在未初始化时初始化
        if (!_initializedSounds.contains(sound.id)) {
          _audioService.initSound(sound.id, sound.assetPath);
          _initializedSounds.add(sound.id);
        }
        
        // 如果应该播放但没有播放，开始播放
        if (sound.isPlaying.value) {
          _audioService.play(sound.id);
          _audioService.setVolume(sound.id, sound.volume.value * masterVolume.value);
        }
      }
    });
  }
  
  // 切换声音播放状态
  Future<void> toggleSound(SoundItem sound) async {
    try {
      if (sound.isPlaying.value) {
        await _audioService.pause(sound.id);
        sound.isPlaying.value = false;
      } else {
        if (!_initializedSounds.contains(sound.id)) {
          await _audioService.initSound(sound.id, sound.assetPath, loop: true);
          _initializedSounds.add(sound.id);
        }
        
        // 设置音量
        await _audioService.setVolume(sound.id, sound.volume.value * masterVolume.value);
        
        // 播放（会自动循环）
        await _audioService.play(sound.id);
        
        sound.isPlaying.value = true;
      }
      
      update();
    } catch (e) {
      print('切换声音状态失败: $e');
    }
  }
  
  // 调整声音音量
  Future<void> adjustVolume(SoundItem sound, double volume) async {
    sound.volume.value = volume.clamp(0.0, 1.0);
    
    if (sound.isPlaying.value) {
      await _audioService.setVolume(sound.id, volume * masterVolume.value);
    }
  }
  
  // 调整主音量
  Future<void> setMasterVolume(double volume) async {
    masterVolume.value = volume.clamp(0.0, 1.0);
    
    // 更新所有正在播放的声音的音量
    for (final sound in activeSounds) {
      if (sound.isPlaying.value) {
        await _audioService.setVolume(sound.id, sound.volume.value * volume);
      }
    }
  }
  
  // 停止所有声音
  Future<void> stopAllSounds() async {
    for (final sound in activeSounds) {
      sound.isPlaying.value = false;
      await _audioService.stop(sound.id);
    }
    activeSounds.clear();
  }
  
  // 按分类获取声音
  List<SoundItem> getSoundsByCategory(SoundCategory category) {
    return availableSounds.where((sound) => sound.category == category).toList();
  }

  @override
  void onClose() {
    _initializedSounds.clear();
    _audioService.disposeAll();
    super.onClose();
  }
}
