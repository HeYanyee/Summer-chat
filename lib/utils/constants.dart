import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  // 主色系
  static const Color primary = Color(0xFFEDB664); 
  static const Color secondary = Color(0xFFBFBDBD);
  
  // 背景色
  static const Color background = Color(0xFFFDFAFA);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFB00020);
  
  // 文本颜色
  static const Color onPrimary = Color(0xFFFFFFFF);
  // static const Color onSecondary = Color(0xFF000000);
  // static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xDD000000);
  // static const Color onError = Color(0xFFFFFFFF);
  
  // 透明色
  static const Color transparent = Color(0x00000000);
  
  // 灰色调
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey900 = Color(0xFF212121);
  // 暖灰色
  static const Color warmGrey200 = Color(0xFFF0EEEE);
  static const Color warmGrey400 = Color(0xFFBFBDBD);
  static const Color warmGrey600 = Color(0xFF797575);
  
  // 语义颜色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
}

/// 尺寸和间距常量
class AppDimens {
  // 常用间距
  static const double spaceZero = 0;
  static const double spaceTiny = 4;
  static const double spaceSmall = 8;
  static const double spaceMedium = 16;
  static const double spaceLarge = 24;
  static const double spaceHuge = 32;
  static const double spaceMassive = 48;
  
  // 边框圆角
  static const double borderRadiusSmall = 4;
  static const double borderRadiusMedium = 8;
  static const double borderRadiusLarge = 12;
  static const double borderRadiusHuge = 16;
  
  // 边框宽度
  static const double borderWidthThin = 0.5;
  static const double borderWidthNormal = 1;
  static const double borderWidthThick = 2;
  
  // 图标尺寸
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  
  // 应用栏高度
  static const double appBarHeight = 56;
  
  // 底部导航栏高度
  static const double bottomNavBarHeight = 64;
}

/// 应用路由名称
class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';
  static const String conversations = '/conversations';
  static const String conversationDetail = '/conversations/detail';
  static const String tools = '/tools';
  static const String settings = '/settings';
}

/// 资产路径
class AppAssets {
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String fontsPath = 'assets/fonts/';

  static const String dataPath = 'user_data/'; // 用户数据存储路径
  
  // 图片文件
  static const String appLogo = '${imagesPath}logo.png';
  static const String homeBackground = '${imagesPath}background.jpg';
  
  // 图标文件
  static const String icConversation = '${iconsPath}ic_conversation.svg';
  static const String icTool = '${iconsPath}ic_tool.svg';
}

/// 文本常量（避免硬编码字符串）
class AppStrings {
  // 通用
  static const String appName = '夏至';
  static const String appNameEN = 'Summer';
  static const String ok = '确定';
  static const String cancel = '取消';
  static const String retry = '重试';
  static const String error = '错误';
  
  // 底部导航栏标签
  static const String characterTab = '角色';
  static const String homeTab = '陪伴';
  static const String conversationsTab = '对话';
  static const String toolsTab = '工具';
  
  // 页面标题
  static const String characterTitle = '角色列表';
  static const String homeTitle = '陪伴主页';
  static const String conversationsTitle = '对话列表';
  static const String toolsTitle = '实用工具';
  
  // 空状态文本
  static const String noConversations = '暂无对话';
  static const String noTools = '暂无工具';
}

class AppPadding {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
}

class ApiConstants {
  static const Map<String, String> defaultUrls = {
    'deepseek-v4-flash': 'https://api.deepseek.com/chat/completions',
    'deepseek-v4-pro': 'https://api.deepseek.com/chat/completions',
    'doubao-seed-1-8-251228':'https://ark.cn-beijing.volces.com/api/v3/chat/completions',
    'doubao-seed-2-0-pro-260215':'https://ark.cn-beijing.volces.com/api/v3/chat/completions',
    'doubao-seed-2-0-lite-260215':'https://ark.cn-beijing.volces.com/api/v3/chat/completions',
  };

  // 每个提供商的默认模型名称
  static const Map<String, String> defaultModels = {
    'DeepSeek v4': 'deepseek-v4-flash',
    'DeepSeek v4 Pro': 'deepseek-v4-pro',
    '豆包1.8': 'doubao-seed-1-8-251228',
    '豆包2.0 Pro': 'doubao-seed-2-0-pro-260215',
    '豆包2.0 Lite': 'doubao-seed-2-0-lite-260215',
  };

  // 文字转语音
  static const Map<String, String> ttsUrls = {
    'speech-02-turbo':'https://api.minimaxi.com/v1/t2a_v2',
    'speech-2.5-turbo-preview':'https://api.minimaxi.com/v1/t2a_v2'
  };

  static const Map<String, String> ttsModels = {
    'MiniMax speech_02':'speech-02-turbo',
    'MiniMax speech_2.5':'speech-2.5-turbo-preview'
  };

  static const double minTokens = 2000; // 最小token数
  static const double maxTokens = 16000; // 最大token数
  static const double minContex = 1;
  static const double maxContex = 50; // 最大上下文长度
}

class TosConstants {
  static const String region = 'cn-beijing'; // TOS区域
  static const String endpoint = 'https://tos-cn-beijing.volces.com'; // TOS端点
  static const String endpoint2 = 'tos-cn-beijing.volces.com';
}

class CharacterConstants{
  // static const int refreshNum = 50; // 每过10轮对话刷新短期记忆
}