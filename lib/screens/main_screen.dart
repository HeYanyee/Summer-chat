import 'package:flutter/material.dart';
import '../screens/characters/c_list_page.dart';
import '../screens/conversation/list_page.dart';
import '../screens/home/home_page.dart';
import '../screens/tools/tools_page.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // 默认选中主页

  // 页面列表，对应底部导航栏的每一项
  final List<Widget> _pages = const [
    CharacterListPage(), 
    ConversationPage(),
    HomePage(),
    ToolsPage(),
  ];

  // AppBar 标题列表，对应每个页面
  final List<String> _appBarTitles = [
    AppStrings.characterTitle,
    AppStrings.conversationsTitle,
    AppStrings.homeTitle,
    AppStrings.toolsTitle,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 让 body 延伸到 AppBar 背后
      extendBody: true, // 让 body 延伸到底部导航栏背后
      backgroundColor: Theme.of(context).colorScheme.surface, // 整体背景色
      body: Container(
        color: Theme.of(context).colorScheme.surface, // IndexedStack 背景色
        child: IndexedStack(
          index: _currentIndex, // 当前显示的页面索引
          children: _pages, // 页面内容
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(), // 底部导航栏
    );
  }

  // 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    return Container(
      color: Theme.of(context).colorScheme.surface, // 底部导航栏背景色
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.borderRadiusLarge), // 顶部圆角
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex, // 当前选中的索引
          onTap: (index) => setState(() => _currentIndex = index), // 切换页面
          backgroundColor: Theme.of(context).colorScheme.surface, // 背景色
          selectedItemColor: Theme.of(context).primaryColor, // 选中项颜色
          unselectedItemColor: Theme.of(context).colorScheme.secondary, // 未选中项颜色
          type: BottomNavigationBarType.fixed, // 固定类型
          elevation: 0, // 无阴影
          showUnselectedLabels: false, // 不显示未选中项文字
          items: [
            _buildNavItem(Icons.perm_identity, AppStrings.characterTab), // 角色
            _buildNavItem(Icons.chat, AppStrings.conversationsTab), // 会话
            _buildNavItem(Icons.home, AppStrings.homeTab), // 主页
            _buildNavItem(Icons.build, AppStrings.toolsTab), // 工具
          ],
        ),
      ),
    );
  }

  // 构建底部导航栏的每一项
  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.spaceTiny), // 图标底部间距
        child: Icon(icon),
      ),
      label: label, // 标签文字
    );
  }
}