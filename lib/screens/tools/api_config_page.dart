// api_config_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_settings.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class ApiConfigPage extends StatefulWidget {
  const ApiConfigPage({super.key});

  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  List<ApiConfig> _apiConfigs = [];
  TosConfig? _tosConfig;
  LocationConfig? _locationConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApiConfigs();
    _loadTosConfig();
    _loadLocationConfig();
  }

  Future<void> _loadApiConfigs() async {
    setState(() => _isLoading = true);
    final configs = await IsarStorageService.getApiConfigs();
    setState(() {
      _apiConfigs = configs;
      _isLoading = false;
    });
  }

  Future<void> _loadTosConfig() async {
    final config = await IsarStorageService.getTosConfig();
    setState(() => _tosConfig = config);
  }

  Future<void> _loadLocationConfig() async {
    final config = await IsarStorageService.getLocationConfig();
    setState(() => _locationConfig = config);
  }

  void _showEditDialog({ApiConfig? existingConfig, required String type}) {
    final isEditing = existingConfig != null;
    final configType = existingConfig?.type ?? type;
    
    // 根据类型选择不同的模型映射
    final modelMap = configType == 'tts' 
        ? ApiConstants.ttsModels 
        : ApiConstants.defaultModels;
    
    String selectedModel = existingConfig?.modelName ?? modelMap.keys.first;
    final apiKeyController = TextEditingController(text: existingConfig?.apiKey ?? '');
    bool isDefault = existingConfig?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('${isEditing ? '编辑' : '添加'}${configType == 'tts' ? 'TTS ' : ''}API配置'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedModel,
                    decoration: InputDecoration(
                      labelText: '模型名称',
                      hintText: configType == 'tts' ? '选择TTS模型' : '选择聊天模型',
                    ),
                    items: modelMap.keys.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? null // 编辑时禁止修改模型
                        : (value) => setState(() => selectedModel = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API密钥',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('设为默认配置'),
                    value: isDefault,
                    onChanged: (value) => setState(() => isDefault = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.warmGrey600,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  backgroundColor: Colors.transparent,
                  textStyle: const TextStyle(fontWeight: FontWeight.normal),
                ),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  if (isEditing) {
                    // 编辑现有配置
                    existingConfig
                      ..apiKey = apiKeyController.text
                      ..isDefault = isDefault;
                    
                    await IsarStorageService.updateApiConfig(existingConfig);
                    
                    if (isDefault) {
                      await IsarStorageService.setDefaultApiConfig(existingConfig.id);
                    }
                  } else {
                    // 添加新配置
                    final newConfig = ApiConfig()
                      ..type = configType
                      ..modelName = selectedModel  // 直接使用模型名称
                      ..apiKey = apiKeyController.text
                      ..isDefault = isDefault;
           
                    await IsarStorageService.addApiConfig(newConfig);
                    
                    if (isDefault) {
                      await IsarStorageService.setDefaultApiConfig(newConfig.id);
                    }
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                    _loadApiConfigs();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${isEditing ? '更新' : '添加'}配置成功')),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  backgroundColor: Colors.transparent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(isEditing ? '更新' : '添加'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteConfig(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除该配置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await IsarStorageService.deleteApiConfig(id);
      _loadApiConfigs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除配置')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatConfigs = _apiConfigs.where((c) => c.type != 'tts').toList();
    final ttsConfigs = _apiConfigs.where((c) => c.type == 'tts').toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('API配置管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSectionHeader('聊天API配置'),
                _buildConfigList(chatConfigs, 'chat'),                
                _buildSectionHeader('TTS API配置'),
                _buildConfigList(ttsConfigs, 'tts'),
                _buildSectionHeader('TOS AKSK配置'),
                _buildTosConfig(_tosConfig),
                _buildSectionHeader('Location配置'),
                _buildLocationConfig(_locationConfig),
              ],
            ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            // TOS和Location配置不显示添加按钮
            title.contains('TOS') || title.contains('Location')
                ? const SizedBox.shrink()
                : IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showEditDialog(
                type: title.contains('TTS') ? 'tts' : 'chat',
              ),
              tooltip: '添加${title.contains('TTS') ? 'TTS ' : ''}配置',
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildConfigList(List<ApiConfig> configs, String type) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final config = configs[index];
          return Card(
            key: ValueKey(config.id),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: config.isDefault
                  ? const Icon(Icons.star, color: Colors.amber)
                  : const Icon(Icons.cloud),
              title: Text(config.modelName), // 直接显示模型名称
              subtitle: Text(
                '模型: ${config.provider}\n密钥: ••••${config.apiKey.substring(config.apiKey.length - 4)}',
                maxLines: 2,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(
                      existingConfig: config,
                      type: type,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteConfig(config.id),
                  ),
                ],
              ),
              onTap: () => _showEditDialog(
                existingConfig: config,
                type: type,
              ),
            ),
          );
        },
        childCount: configs.length,
      ),
    );
  }

  static String getHintText(String? text){
    if (text == null || text.isEmpty) {
      return '请输入内容';
    }
    else if (text.length > 4) {
      return '••••${text.substring(text.length - 4)}';
    }
    else {
      return text;
    }
  }

  SliverToBoxAdapter _buildTosConfig(TosConfig? tosConfig) {
    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: const Icon(Icons.cloud_upload),
          title: const Text('火山引擎对象存储'),
          subtitle: tosConfig == null
              ? const Text('未配置TOS服务')
              : Text(
                  'AK: ${getHintText(tosConfig.ak)}\nSK: ${getHintText(tosConfig.sk)}\nBucket: ${tosConfig.bucket}',
                  maxLines: 3,
                ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final akController = TextEditingController(text: tosConfig?.ak ?? '');
                  final skController = TextEditingController(text: tosConfig?.sk ?? '');
                  final bucketController = TextEditingController(text: tosConfig?.bucket ?? 'summer-test');

                  return AlertDialog(
                    title: const Text('编辑TOS配置'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: akController,
                            decoration: const InputDecoration(labelText: 'Access Key (AK)'),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: skController,
                            decoration: const InputDecoration(labelText: 'Secret Key (SK)'),
                            obscureText: true,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: bucketController,
                            decoration: const InputDecoration(labelText: 'Bucket名称'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final newConfig = TosConfig(
                            ak: akController.text,
                            sk: skController.text,
                            bucket: bucketController.text,
                          );
                          await IsarStorageService.saveTosConfig(newConfig);
                          _loadTosConfig();
                          Navigator.pop(context);
                          setState(() {
                            _tosConfig = newConfig;
                          });
                        },
                        child: const Text('保存'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ), 
      ),
    );
  }

  SliverToBoxAdapter _buildLocationConfig(LocationConfig? locationConfig) {
    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('高德地图API配置'),
          subtitle: locationConfig == null
              ? const Text('未配置地图服务')
              : Text(
                  'Key: ${getHintText(locationConfig.key)}',
                  maxLines: 1,
                ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final keyController = TextEditingController(text: locationConfig?.key ?? '');

                  return AlertDialog(
                    title: const Text('编辑Location配置'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: keyController,
                            decoration: const InputDecoration(
                              labelText: 'Location Key',
                              hintText: '请输入地图API密钥',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.warmGrey600,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final newConfig = LocationConfig(key: keyController.text);
                          
                          await IsarStorageService.saveLocationConfig(newConfig);
                          _loadLocationConfig();
                          
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('地图API配置保存成功')),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          backgroundColor: Colors.transparent,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        child: const Text('保存'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}