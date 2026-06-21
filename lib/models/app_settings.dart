import 'package:isar/isar.dart';
import '../utils/constants.dart';

part 'app_settings.g.dart'; // 需要运行 build_runner 生成
// flutter pub run build_runner build --delete-conflicting-outputs

/// API配置项
@collection
class ApiConfig {
  Id id = Isar.autoIncrement; // 添加自增ID
  late String modelName;
  late String apiKey;
  bool isDefault = false;
  String type;

  /// 用于把旧版本或者不同写法的模型名规范化
  static String normalizeModelName(String name) {
    // 若name不在defaultModels的值中，则尝试替换旧名称
    if (!ApiConstants.defaultModels.containsKey(name)) {
      return '豆包1.8（思考关闭）';
    }
    return name;
  }

  ApiConfig({
    String modelName='豆包1.8（思考关闭）',
    this.apiKey='',
    this.isDefault = false,
    this.type = 'chat', // 默认为聊天类型
  }) {
    // 兼容旧名称
    this.modelName = normalizeModelName(modelName);
  }

  /// 获取当前配置的 baseUrl（支持chat和tts类型）
  String get baseUrl {
    // provider getter 内部已经做了名称归一化
    if (type == 'tts') {
      return ApiConstants.ttsUrls[provider] ?? '';
    }
    return ApiConstants.defaultUrls[provider] ?? '';
  }

  /// 获取当前配置的默认模型名（支持chat和tts类型）
  String get provider {
    final name = normalizeModelName(modelName);
    if (type == 'tts') {
      return ApiConstants.ttsModels[name] ?? '';
    }
    return ApiConstants.defaultModels[name] ?? '';
  }

  /// JSON 序列化/反序列化辅助
  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      modelName: json['modelName'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
      type: json['type'] as String? ?? 'chat',
    )..id = json['id'] is int ? json['id'] as int : json['id'] is String ? int.tryParse(json['id']) ?? 0 : 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelName': modelName,
      'apiKey': apiKey,
      'isDefault': isDefault,
      'type': type,
    };
  }
}

@collection
class TosConfig{
  Id id = Isar.autoIncrement; // 添加自增ID
  String ak;
  String sk;
  String bucket = 'summer-test'; 

  TosConfig({
    required this.ak,
    required this.sk,
    required this.bucket,
  });
}

@collection
class LocationConfig{
  Id id = Isar.autoIncrement; // 添加自增ID
  String key;

  LocationConfig({
    required this.key,
  });
}

/// 应用设置模型，适配 Isar 数据库
@collection
class AppSettings {
  Id id = 1; // 固定为1，保证全局唯一

  // API配置列表
  final apiProviders = IsarLinks<ApiConfig>();
  final tosConfigs = IsarLinks<TosConfig>();

  AppSettings();
}