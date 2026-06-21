import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:collection';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  ApiConfig? _currentTtsConfig;

  // 新增：LRU缓存，最多10条
  final LinkedHashMap<String, Uint8List> _audioCache = LinkedHashMap();

  /// 初始化并加载TTS配置
  Future<void> initialize() async {
    await _loadTtsConfig();
  }

  /// 加载TTS配置
  Future<void> _loadTtsConfig() async {
    try {
      // 获取所有TTS配置
      final configs = await IsarStorageService.getApiConfigs();
      final ttsConfigs = configs.where((c) => c.type == 'tts').toList();
      if (ttsConfigs.isEmpty) {
        debugPrint('没有找到文字转语音配置，请先添加配置');
        return;
      }
      // 查找默认配置或使用第一个
      _currentTtsConfig = ttsConfigs.firstWhere(
        (config) => config.isDefault,
        orElse: () => ttsConfigs.first,
      );
    } catch (e) {
      debugPrint('Error loading TTS config: $e');
    }
  }

  // 预处理文本
  String _preprocessText(String text) {
    return text.replaceAll(RegExp(r'[\(（].*?[\)）]'), '<#0.5#>');
  }

  /// 调用文字转语音API并播放语音
  Future<void> textToSpeech(String text, String messageId) async {
    try {
      if (_currentTtsConfig == null) {
        throw Exception('没有配置文字转语音服务，请前往API设置页面配置');
      }

      // 1. 先查缓存
      if (_audioCache.containsKey(messageId)) {
        await _playAudio(_audioCache[messageId]!);
        return;
      }

      await _executeOnMainThread(() async {
        // 1. 获取API URL和密钥
        final apiUrl = ApiConstants.ttsUrls[_currentTtsConfig!.provider] ?? '';
        final apiKey = _currentTtsConfig!.apiKey;
        
        if (apiUrl.isEmpty) {
          throw Exception('无效的TTS提供商: ${_currentTtsConfig!.provider}');
        }

        // 2. 构建请求体（根据提供商调整）
        text = _preprocessText(text);
        Map<String, dynamic> requestBody;
        switch (_currentTtsConfig!.provider) {
          case 'speech-02-turbo':
            requestBody = _buildMiniMaxRequestBody(text);
            break;
          case 'speech-2.5-turbo-preview':
            requestBody = _buildMiniMaxRequestBody(text);
            break;
          default:
            throw Exception('不支持的TTS提供商: ${_currentTtsConfig!.provider}');
        }

        // 3. 发送API请求
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(requestBody),
        );

        // 4. 处理响应
        if (response.statusCode == 200) {
          final audioBytes = _processResponse(response);

          // 新增：缓存音频，超出10条移除最早的
          _audioCache[messageId] = audioBytes;
          if (_audioCache.length > 10) {
            _audioCache.remove(_audioCache.keys.first);
          }

          await _playAudio(audioBytes);
        } else {
          throw Exception('TTS API错误: ${response.statusCode}\n${response.body}');
        }
      });
    } catch (e) {
      debugPrint('语音合成错误: $e');
      rethrow;
    }
  }

  /// 构建MiniMax请求体
  Map<String, dynamic> _buildMiniMaxRequestBody(String text) {
    return {
      "model": _currentTtsConfig!.provider.isNotEmpty
          ? _currentTtsConfig!.provider
          : "speech-02-turbo",
      "text": text,
      "stream": false,
      "voice_setting": {
        "voice_id": "Chinese (Mandarin)_Gentleman",
        "speed": 1,
        "vol": 1,
        "pitch": 0,
        "latex_read": true,
        "emotion": "sad",
      },
      "audio_setting": {
        "sample_rate": 32000,
        "bitrate": 128000,
        "format": "mp3",
      }
    };
  }

  /// 处理API响应
  Uint8List _processResponse(http.Response response) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    
    switch (_currentTtsConfig!.provider) {
      case 'speech-2.5-turbo-preview':
      case 'speech-02-turbo':
        if (responseData['data'] != null &&
            responseData['data']['audio'] != null) {
          final String audioHex = responseData['data']['audio'];
          return _hexToBytes(audioHex);
        }
        break;
      default:
        throw Exception('未知的TTS响应格式');
    }
    
    throw Exception('无效的响应: 缺少音频数据');
  }

  /// 将Hex字符串转换为字节数据
  Uint8List _hexToBytes(String hex) {
    final List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  /// 播放音频
  Future<void> _playAudio(Uint8List audioBytes) async {
    await _executeOnMainThread(() async {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(BytesSource(audioBytes));
      } catch (e) {
        debugPrint('播放音频错误: $e');
        rethrow;
      }
    });
  }

  Future<void> _executeOnMainThread(Future Function() task) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kIsWeb) {
      return task();
    } else {
      final completer = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await task();
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      });
      return completer.future;
    }
  }

  /// 获取当前TTS配置
  ApiConfig? get currentTtsConfig => _currentTtsConfig;

  /// 停止播放
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// 释放资源
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}