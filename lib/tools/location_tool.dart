import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:summer/models/app_settings.dart';
import 'dart:convert';

import 'package:summer/services/storage_service.dart';


class LocationResult {
  final bool success;
  final double? latitude;
  final double? longitude;
  final String? accuracy;      // 精度描述，如 "高精度(10米)"、"IP定位(城市级)"
  final String? source;        // 位置来源，如 "gps", "ip"
  final String? errorMessage;  // 错误信息（success=false时有效）
  final String? city;          // IP定位时可能有城市信息

  LocationConfig? _currentLocationConfig;

  LocationResult({
    required this.success,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.source,
    this.errorMessage,
    this.city,
  });

  @override
  String toString() {
    if (success) {
      return 'Location: ($latitude, $longitude), accuracy: $accuracy, source: $source${city != null ? ', city: $city' : ''}';
    } else {
      return 'Location failed: $errorMessage';
    }
  }

  /// 加载位置配置
  Future<void> _loadLocationConfig() async {
    try {
      // 获取所有位置配置
      await IsarStorageService.getApiConfigs();
      final locationConfig = await IsarStorageService.getLocationConfig();
      if (locationConfig == null) {
        debugPrint('没有找到位置配置，请先添加配置');
        return;
      }
      // 查找默认配置或使用第一个
      _currentLocationConfig = locationConfig;
    } catch (e) {
      debugPrint('Error loading location config: $e');
    }
  }

  Future<String> decodeLocation() async {
    await _loadLocationConfig();
    if(_currentLocationConfig != null){
      String key = _currentLocationConfig!.key;
      // 使用 key 调用地图API进行位置解码（示例使用高德地图API）
      try {
        final response = await http.get(Uri.parse(
          'https://restapi.amap.com/v3/geocode/regeo?location=$longitude,$latitude&key=$key',
        ));
        return response.body;
      } catch (e) {
        debugPrint('Error decoding location: $e');
      }
      return '位置解码失败';
    }else{
      return '未配置地图API，无法解码位置';
    }
  }
  Future<String> getWeatherByCity(String city) async {
    // 通过城市名称city获取adcode，然后调用天气API获取天气信息
    await _loadLocationConfig();
    if(_currentLocationConfig != null){
      String key = _currentLocationConfig!.key;
      try {
        // 1. 获取城市编码 (adcode)
        final cityResponse = await http.get(Uri.parse(
          'https://restapi.amap.com/v3/geocode/geo?address=$city&key=$key',
        ));
        if (cityResponse.statusCode == 200) {
          final cityJson = jsonDecode(cityResponse.body);
          if (cityJson['status'] == '1' && cityJson['geocodes'].isNotEmpty) {
            String adcode = cityJson['geocodes'][0]['adcode'];
            
            // 2. 使用城市编码调用天气API
            final weatherResponse = await http.get(Uri.parse(
              'https://restapi.amap.com/v3/weather/weatherInfo?city=$adcode&key=$key',
            ));
            
            if (weatherResponse.statusCode == 200) {
              final weatherJson = jsonDecode(weatherResponse.body);
              if (weatherJson['status'] == '1' && weatherJson['lives'].isNotEmpty) {
                final weather = weatherJson['lives'][0];
                return '城市：${weather['city']}\n'
                      '天气：${weather['weather']}\n'
                      '温度：${weather['temperature']}℃\n'
                      '风向：${weather['winddirection']}\n'
                      '风力：${weather['windpower']}级\n'
                      '湿度：${weather['humidity']}%\n'
                      '发布时间：${weather['reporttime']}';
              }
            }
            return '获取天气信息失败';
          } else {
            return '城市 "$city" 未找到';
          }
        } else {
          return '获取城市编码失败: HTTP ${cityResponse.statusCode}';
        }
      } catch (e) {
        debugPrint('Error getting weather by city: $e');
        return '获取天气信息时发生错误';
      }
    } else {
      return '未配置地图API，无法获取天气信息';
    }
  }

  Future<String> getWeatherByLocaton() async {
    await _loadLocationConfig();
    if(_currentLocationConfig != null){
      String key = _currentLocationConfig!.key;
      
      // 使用位置解码功能，从经纬度获取位置信息
      String locationInfo = await decodeLocation();
      
      try {
        // 解析位置信息获取城市编码
        final locationJson = jsonDecode(locationInfo);
        if (locationJson['status'] == '1') {
          // 获取城市编码 (adcode)
          String adcode = locationJson['regeocode']['addressComponent']['adcode'];
          
          // 使用城市编码调用天气API
          final weatherResponse = await http.get(Uri.parse(
            'https://restapi.amap.com/v3/weather/weatherInfo?city=$adcode&key=$key',
          ));
          
          if (weatherResponse.statusCode == 200) {
            final weatherJson = jsonDecode(weatherResponse.body);
            if (weatherJson['status'] == '1' && weatherJson['lives'].isNotEmpty) {
              // 返回格式化的天气信息
              final weather = weatherJson['lives'][0];
              return '城市：${weather['city']}\n'
                    '天气：${weather['weather']}\n'
                    '温度：${weather['temperature']}℃\n'
                    '风向：${weather['winddirection']}\n'
                    '风力：${weather['windpower']}级\n'
                    '湿度：${weather['humidity']}%\n'
                    '发布时间：${weather['reporttime']}';
            }
          }
          return '获取天气信息失败';
        } else {
          return '位置解码失败：${locationJson['info']}';
        }
      } catch (e) {
        debugPrint('Error getting weather: $e');
        return '获取天气信息时发生错误';
      }
    } else {
      return '未配置位置服务API，无法获取天气信息';
    }
  }
}

class LocationService {
  /// 统一获取位置接口（Android / Windows）
  static Future<LocationResult> getLocation() async {
    // Android 平台：必须走权限请求，获取精确位置
    if (Platform.isAndroid) {
      return await _getAndroidLocation();
    }
    // Windows 平台：先尝试低精度定位（不弹窗），失败则用 IP 定位
    else if (Platform.isWindows) {
      return await _getWindowsLocation();
    }
    // 其他平台（如 iOS、macOS）可按需扩展，这里返回不支持
    else {
      return LocationResult(
        success: false,
        errorMessage: 'Platform ${Platform.operatingSystem} not supported',
      );
    }
  }

  /// Android 位置获取（高精度失败后降级到中精度）
  static Future<LocationResult> _getAndroidLocation() async {
  // 1. 先检查定位服务
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationResult(success: false);
    }
    
    // 2. 高精度 GPS（15秒超时）
    LocationResult highResult = await _getAndroidHighAccuracyLocation();
    if (highResult.success) {
      return highResult;
    }
    
    debugPrint('高精度定位失败，尝试中精度...');
    
    // 3. 中精度 Wi-Fi/基站（15秒超时）
    LocationResult mediumResult = await _getAndroidMediumAccuracyLocation();
    if (mediumResult.success) {
      return mediumResult;
    }
    debugPrint('中精度定位失败，尝试低精度...');
    return await _getLocationFromIP();
  }

  /// Android 高精度定位（GPS）
  static Future<LocationResult> _getAndroidHighAccuracyLocation() async {
    try {
      // 1. 检查定位服务是否开启
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          errorMessage: '定位服务未开启',
        );
      }

      // 2. 检查并请求权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            errorMessage: '用户拒绝了定位权限',
          );
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          errorMessage: '定位权限被永久拒绝，请前往应用设置开启',
        );
      }

      // 3. 获取单次位置（高精度 GPS）
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: '高精度 GPS (${position.accuracy.toStringAsFixed(0)}米)',
        source: 'gps',
      );
    } catch (e) {
      return LocationResult(
        success: false,
        errorMessage: '高精度定位异常: $e',
      );
    }
  }

  /// Android 中精度定位（Wi-Fi/基站）
  static Future<LocationResult> _getAndroidMediumAccuracyLocation() async {
    try {
      // 检查定位服务是否开启
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          errorMessage: '定位服务未开启',
        );
      }

      // 检查权限（高精度失败后，权限应该已请求过）
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          errorMessage: '定位权限不足，无法使用中精度定位',
        );
      }

      // 获取中精度位置（Wi-Fi/基站定位）
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: '中精度 Wi-Fi/基站 (${position.accuracy.toStringAsFixed(0)}米)',
        source: 'network',
      );
    } catch (e) {
      return LocationResult(
        success: false,
        errorMessage: '中精度定位异常: $e',
      );
    }
  }

  /// Windows 位置获取（高精度 → 中精度 → IP 三级降级）
  static Future<LocationResult> _getWindowsLocation() async {
    // 1. 先尝试高精度定位
    debugPrint('尝试 Windows 高精度定位...');
    LocationResult highResult = await _getWindowsHighAccuracyLocation();
    if (highResult.success) {
      return highResult;
    }

    // 2. 高精度失败，降级到中精度
    debugPrint('高精度定位失败，尝试中精度定位...');
    LocationResult mediumResult = await _getWindowsMediumAccuracyLocation();
    if (mediumResult.success) {
      return mediumResult;
    }

    // 3. 中精度也失败，降级到 IP 定位
    debugPrint('中精度定位失败，降级到 IP 定位...');
    return await _getLocationFromIP();
  }

  /// Windows 高精度定位
  static Future<LocationResult> _getWindowsHighAccuracyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      ).timeout(const Duration(seconds: 6));

      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: '高精度 (${position.accuracy.toStringAsFixed(0)}米)',
        source: 'gps',
      );
    } catch (e) {
      debugPrint('Windows 高精度定位失败: $e');
      return LocationResult(success: false, errorMessage: '高精度定位失败');
    }
  }

  /// Windows 中精度定位（Wi-Fi/基站）
  static Future<LocationResult> _getWindowsMediumAccuracyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      ).timeout(const Duration(seconds: 6));

      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: '中精度 Wi-Fi/基站 (${position.accuracy.toStringAsFixed(0)}米)',
        source: 'network',
      );
    } catch (e) {
      debugPrint('Windows 中精度定位失败: $e');
      return LocationResult(success: false, errorMessage: '中精度定位失败');
    }
  }

  /// IP 定位（备选方案，城市级精度）
  static Future<LocationResult> _getLocationFromIP() async {
    try {
      // 使用 ip-api.com 免费接口（限制 45 次/分钟）
      final response = await http.get(
        Uri.parse('http://ip-api.com/json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return LocationResult(
            success: true,
            latitude: data['lat'],
            longitude: data['lon'],
            accuracy: 'IP定位 (城市级，误差约几公里)',
            source: 'ip',
            city: data['city'],
          );
        } else {
          return LocationResult(
            success: false,
            errorMessage: 'IP 定位服务返回失败: ${data['message']}',
          );
        }
      } else {
        return LocationResult(
          success: false,
          errorMessage: 'IP 定位 HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return LocationResult(
        success: false,
        errorMessage: 'IP 定位异常: $e',
      );
    }
  }
}