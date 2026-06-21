import 'package:flutter/material.dart';
import 'package:summer/tools/location_tool.dart';

// 放置一个占位页面，未来可以扩展为工具管理界面
class ToolsManagePage extends StatelessWidget {
  const ToolsManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          '工具管理',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        // 放置一个按钮，触发类内的测试函数
        child: ElevatedButton(
          onPressed: () => _testFunction(), // 这里暂时不绑定函数，后续可以改为调用工具服务的测试函数
          child: const Text('测试工具功能'),
        ),  
      )     
    );
  }

  Future<void> _testFunction() async {
    // 这里可以放置一些测试代码，比如调用工具服务的函数，或者打印一些信息
    LocationResult result = await LocationService.getLocation();
    print(result);  // 输出结果
  }
}

