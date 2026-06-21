import 'package:flutter/material.dart';
import 'package:summer/services/tools_service.dart';
import '../screens/main_screen.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import 'services/storage_service.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import '../services/api_service.dart';
import '../services/voice_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// TODO:手机需要请求权限才能存储文件
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 创建服务实例
  final apiService = ApiService();
  final voiceService = VoiceService();
  // 注册生命周期观察者
  final lifecycleObserver = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(lifecycleObserver);
  
  // 初始化工具
  final toolStorage = ToolStorageService();
  await toolStorage.initialize();
  ToolsService().initialize();
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 确保在应用退出时关闭数据库
  final instance = WidgetsBinding.instance;
  instance.addPostFrameCallback((_) {
    instance.addPersistentFrameCallback((_) {});
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // 底部导航栏背景透明
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness: Brightness.light, 
      // 顶部状态栏透明
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<VoiceService>.value(value: voiceService),
        // 添加数据库状态监听器
        ChangeNotifierProvider(create: (_) => DatabaseStateNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用回到前台 - 确保数据库连接正常
        DatabaseStateNotifier().markDatabaseAvailable();
        break;
      case AppLifecycleState.inactive:
        // 应用处于非活动状态
        break;
      case AppLifecycleState.paused:
        // 应用进入后台 - 不需要关闭数据库
        break;
      case AppLifecycleState.detached:
        // 应用即将终止
        IsarStorageService.closeDatabase();
        break;
      case AppLifecycleState.hidden:
        // 应用完全隐藏
        break;
    }
  }
}

// 数据库状态通知器
class DatabaseStateNotifier with ChangeNotifier {
  bool _isDatabaseAvailable = true;
  
  bool get isDatabaseAvailable => _isDatabaseAvailable;
  
  void markDatabaseAvailable() {
    _isDatabaseAvailable = true;
    notifyListeners();
  }
  
  void markDatabaseUnavailable() {
    _isDatabaseAvailable = false;
    notifyListeners();
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializationFuture = _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // 预初始化数据库
    try {
      await IsarStorageService.database;
    } catch (e) {
      // 处理初始化错误
      debugPrint('数据库初始化错误: $e');
      // 标记数据库不可用
      Provider.of<DatabaseStateNotifier>(context, listen: false).markDatabaseUnavailable();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 处理额外的生命周期事件
    if (state == AppLifecycleState.resumed) {
      // 应用回到前台时刷新依赖数据库的组件
      Provider.of<DatabaseStateNotifier>(context, listen: false).markDatabaseAvailable();
    } else if (state == AppLifecycleState.detached) {
      // 应用即将终止
      IsarStorageService.closeDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // 检查初始化状态
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // 初始化失败时显示错误界面
            return _buildErrorScreen(snapshot.error!);
          }
          
          // 初始化成功，构建主应用
          return _buildMainApp();
        }
        
        // 显示加载指示器
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainApp() {
    return Consumer<DatabaseStateNotifier>(
      builder: (context, dbNotifier, child) {
        // 如果数据库不可用，显示错误界面
        if (!dbNotifier.isDatabaseAvailable) {
          return _buildDatabaseErrorScreen();
        }
        
        return MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
          ],
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.initial,
          routes: {
            AppRoutes.initial: (context) => const MainScreen(),
          },
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }

  Widget _buildErrorScreen(Object error) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                SizedBox(height: 20),
                Text(
                  '应用初始化失败',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '错误信息: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 尝试重新初始化
                    setState(() {
                      _initializationFuture = _initializeApp();
                    });
                  },
                  child: Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatabaseErrorScreen() {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storage, color: Colors.orange, size: 50),
                SizedBox(height: 20),
                Text(
                  '数据库不可用',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '无法访问本地数据库，部分功能可能受限',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // 尝试重新连接数据库
                    Provider.of<DatabaseStateNotifier>(context, listen: false)
                      ..markDatabaseUnavailable();
                    
                    IsarStorageService.reset();
                    
                    setState(() {
                      _initializationFuture = _initializeApp();
                    });
                  },
                  child: Text('重新连接数据库'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}