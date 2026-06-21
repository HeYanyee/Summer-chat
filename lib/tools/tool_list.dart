// tool_list.dart
import 'dart:async';
import 'package:summer/models/tool.dart';
import 'package:summer/tools/location_tool.dart';
import 'package:summer/tools/note_tool.dart';

/// 预定义工具集合（定义 + 实现）
class PredefinedTools {
  // ==================== 工具定义 ====================

  static Tool getWeatherTool() {
    return Tool.create(
      name: 'get_weather',
      description: '获取天气信息，默认获取用户所在地的天气信息',
      parameters: ToolParameters(
        properties: {
          'city': ToolParameterProperty(
            type: 'string',
            description: '要查询天气的城市名称，默认为用户当前位置所在城市',
          ),
        },
        required: [],
      ),
    );
  }

  static Tool getCalculatorTool() {
    return Tool.create(
      name: 'calculator',
      description: '执行数学计算',
      parameters: ToolParameters(
        properties: {
          'expression': ToolParameterProperty(
            type: 'string',
            description: '数学表达式，例如：1 + 2 * 3',
          ),
        },
        required: ['expression'],
      ),
    );
  }

static Tool getNoteTool() {
  return Tool.create(
    name: 'note',
    description: '管理笔记，支持创建、更新、删除和列出笔记',
    parameters: ToolParameters(
      properties: {
        'action': ToolParameterProperty(
          type: 'string',
          description: '''操作类型，支持：
- read: 读取名字为name的笔记内容
- create: 创建名字为name的新笔记
- write: 在名字为name的笔记末尾写入
- rewrite: 重写名字为name的笔记
- delete: 删除名字为name的笔记
- list: 列出所有笔记''',
          enumValues: ['read', 'create', 'write', 'rewrite', 'delete', 'list'],
        ),
        'name': ToolParameterProperty(
          type: 'string',
          description: '笔记名称。对于create操作，如果不提供将使用"Untitled Note"；对于update和delete操作用于定位要操作的笔记。建议使用自己的名字标记属于自己的笔记。',
        ),
        'content': ToolParameterProperty(
          type: 'string',
          description: '笔记内容。用于create和update操作，如果不提供将为空字符串',
        ),
      },
      required: ['action'],
    ),
  );
}


  static Tool getLocationTool() {
    return Tool.create(
      name: 'get_location',
      description: '获取用户的当前位置信息，返回城市、经纬度等。当需要知道用户位置时调用此工具。',
      parameters: ToolParameters(
        properties: {},
        required: [],
      ),
    );
  }

  static List<Tool> getAllPredefinedTools() {
    return [
      getWeatherTool(),
      getCalculatorTool(),
      getNoteTool(),
      getLocationTool(),
    ];
  }

  // ==================== 工具实现 ====================

  static Future<String> _handleGetWeather(Map<String, dynamic> args) async {
    // 若传入了city参数，则获取指定城市的天气；否则获取用户当前位置的天气
    String? city = args['city'] as String?;
    if (city != null && city.isNotEmpty) {
      // 获取指定城市的天气
      LocationResult location=LocationResult(success: false);
      String result = '【${city}天气信息】\n';
      result += await location.getWeatherByCity(city);
      return result;
    }
    LocationResult location = await LocationService.getLocation();

    String result = '【位置信息】\n';
    result += await location.getWeatherByLocaton();
    return result;
  }

  static Future<String> _handleCalculate(Map<String, dynamic> args) async {
    final expression = args['expression'] as String? ?? '';

    try {
      final result = _evaluateExpression(expression);
      return '【计算结果】\n表达式：$expression\n结果：$result';
    } catch (e) {
      return '计算错误：表达式 "$expression" 无效';
    }
  }

  static Future<String> _handleNote(Map<String, dynamic> args) async {
    final noteService = NoteService();
    final result = await noteService.handleNoteRequest(args);
    return result;
  }

  static Future<String> _handleGetCurrentTime(Map<String, dynamic> args) async {
    final timezone = args['timezone'] as String? ?? 'Asia/Shanghai';
    final format = args['format'] as String? ?? 'YYYY-MM-DD HH:MM:SS';

    final now = DateTime.now();
    String formattedTime = now.toString().substring(0, 19).replaceAll('T', ' ');

    return '【当前时间】\n时区：$timezone\n时间：$formattedTime\n格式：$format';
  }

  static Future<String> _handleGetLocation(Map<String, dynamic> args) async {
    LocationResult location = await LocationService.getLocation();

    String result = '【位置信息】\n';
    result += '纬度：${location.latitude}\n经度：${location.longitude}';
    result += '\n精度：${location.accuracy}米\n来源：${location.source}\n';
    result += await location.decodeLocation();
    return result;
  }

  // 辅助函数：简单表达式计算（仅供演示）
  static double _evaluateExpression(String expression) {
    expression = expression.replaceAll(' ', '');

    if (expression.contains('+')) {
      final parts = expression.split('+');
      return double.parse(parts[0]) + double.parse(parts[1]);
    } else if (expression.contains('-')) {
      final parts = expression.split('-');
      return double.parse(parts[0]) - double.parse(parts[1]);
    } else if (expression.contains('*')) {
      final parts = expression.split('*');
      return double.parse(parts[0]) * double.parse(parts[1]);
    } else if (expression.contains('/')) {
      final parts = expression.split('/');
      return double.parse(parts[0]) / double.parse(parts[1]);
    }

    return double.parse(expression);
  }

  /// 获取所有工具处理器（名称 -> 处理函数）
  static Map<String, Function(Map<String, dynamic>)> getHandlers() {
    return {
      'get_weather': _handleGetWeather,
      'calculator': _handleCalculate,
      'note': _handleNote,
      'get_current_time': _handleGetCurrentTime,
      'get_location': _handleGetLocation,
    };
  }
}