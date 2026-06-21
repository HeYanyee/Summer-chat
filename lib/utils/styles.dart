import 'package:flutter/material.dart';
import 'constants.dart'; 

class AppTextStyles {
  // 透明顶部栏的标题样式
  static const appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 底部导航栏标签样式
  static const bottomNavLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // 页面大标题
  static const pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // 对话列表项标题
  static const conversationTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  // 对话列表项副标题/内容
  static const conversationSubtitle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  // 工具卡片标题
  static const toolCardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // 正文文本
  static const bodyText = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );

  // 强调文本
  static const emphasizedText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primary, // 使用常量中定义的颜色
  );
}

// 其他可能需要全局定义的样式
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'MiSans',
      ),
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.warmGrey200,
        surface: AppColors.background,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.warmGrey400,
        onSurface: AppColors.onSurface,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary, // 正常状态下的颜色
        surfaceTintColor: Colors.transparent, // 关键：禁用覆盖层
        scrolledUnderElevation: 0, // 禁用滚动时的阴影
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: AppTextStyles.appBarTitle,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedLabelStyle: AppTextStyles.bottomNavLabel,
        unselectedLabelStyle: AppTextStyles.bottomNavLabel,
      ),
    );
  }
}