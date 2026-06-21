import 'dart:io';

import 'package:tos/enum.dart';
import 'package:tos/exception.dart';
import 'package:tos/tos.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// TOS预签名URL生成工具类
class TosPresignUtils {
  /// 生成TOS预签名下载URL（GET请求）
  /// [accessKeyId]：AccessKey ID
  /// [secretAccessKey]：SecretAccessKey（需保密）
  /// [region]：存储桶区域（如`cn-beijing`）
  /// [bucketName]：存储桶名称
  /// [objectKey]：对象键（文件路径，如`image/test.jpg`）
  /// [endpoint]：TOS Endpoint（如`tos-cn-beijing.volces.com`）
  /// [expires]：过期时间（秒，默认3600）
  static Future<String> generatePresignedUrl({
    required String accessKeyId,
    required String secretAccessKey,
    required String region,
    required String bucketName,
    required String objectKey,
    required String endpoint,
    int expires = 3600,
  }) async {
    // 1. 生成当前日期（ISO8601格式）
    final now = DateTime.now().toUtc();
    final dateTimeStr = _formatDateTime(now); // 20240520T123000Z
    final dateStr = dateTimeStr.substring(0, 8); // 20240520

    // 2. 构造规范请求（Canonical Request）
    final method = 'GET';
    final canonicalUri = '/${_encodePath(objectKey)}';//_encodeUriComponent('/$objectKey'); // 编码对象键
    final canonicalQueryParams = _buildCanonicalQueryParams(
      accessKeyId: accessKeyId,
      dateStr: dateStr,
      region: region,
      expires: expires,
      dateTimeStr: dateTimeStr,
    );
    final canonicalHeaders = 'host:${bucketName}.$endpoint\n';
    final signedHeaders = 'host';

    final canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryParams,
      canonicalHeaders,
      signedHeaders,
      'UNSIGNED-PAYLOAD',
    ].join('\n');

    // 3. 构造待签字符串（String to Sign）
    final credentialScope = '$dateStr/$region/tos/request';
    final hashedCanonicalRequest = sha256.convert(utf8.encode(canonicalRequest)).toString();
    final stringToSign = [
      'TOS4-HMAC-SHA256',
      dateTimeStr,
      credentialScope,
      hashedCanonicalRequest,
    ].join('\n');

    // 4. 计算签名（Signature）
    final signingKey = _deriveSigningKey(
      secretAccessKey: secretAccessKey,
      dateStr: dateStr,
      region: region,
    );
    final signatureBytes = hmacSha256(signingKey, stringToSign);
    final signature = bytesToHex(signatureBytes);

    // 5. 拼接预签名URL
    final encodedPath = _encodePath(objectKey);
    final baseUrl = 'https://${bucketName}.$endpoint/$encodedPath';
    final queryParams = '$canonicalQueryParams&X-Tos-Signature=$signature';
    return '$baseUrl?$queryParams';
  }

  /// 对路径分段编码（保留斜杠）
  static String _encodePath(String path) {
    return path.split('/').map(_encodeUriComponent).join('/');
  }
  /// 格式化日期为ISO8601格式（yyyyMMddTHHmmssZ）
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}'
        '${dateTime.month.toString().padLeft(2, '0')}'
        '${dateTime.day.toString().padLeft(2, '0')}T'
        '${dateTime.hour.toString().padLeft(2, '0')}'
        '${dateTime.minute.toString().padLeft(2, '0')}'
        '${dateTime.second.toString().padLeft(2, '0')}Z';
  }

  /// 编码URI组件（遵循TOS的编码规则）
  static String _encodeUriComponent(String value) {
    return Uri.encodeComponent(value)
        .replaceAll('+', '%20')
        .replaceAll('*', '%2A')
        .replaceAll('%7E', '~');
  }

  /// 构造规范查询参数（Canonical Query String）
  static String _buildCanonicalQueryParams({
    required String accessKeyId,
    required String dateStr,
    required String region,
    required int expires,
    required String dateTimeStr,
  }) {
    final params = {
      'X-Tos-Algorithm': 'TOS4-HMAC-SHA256',
      'X-Tos-Credential': '$accessKeyId/$dateStr/$region/tos/request',
      'X-Tos-Date': dateTimeStr,
      'X-Tos-Expires': expires.toString(),
      'X-Tos-SignedHeaders': 'host',
    };
    // 按字典序排序并拼接（key=value&key=value）
    return params.entries
        .map((e) => '${_encodeUriComponent(e.key)}=${_encodeUriComponent(e.value)}')
        .toList()
        .join('&');
  }

  /// 推导签名密钥（Signing Key）
  static List<int> _deriveSigningKey({
    required String secretAccessKey,
    required String dateStr,
    required String region,
  }) {
    final dateKey = hmacSha256(utf8.encode(secretAccessKey), dateStr);
    final regionKey = hmacSha256(dateKey, region);
    final serviceKey = hmacSha256(regionKey, 'tos');
    final signingKey = hmacSha256(serviceKey, 'request');
    return signingKey;
  }

  /// HMAC-SHA256计算
  static List<int> hmacSha256(List<int> key, String data) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(data)).bytes;
  }

  /// 将字节列表转换为小写十六进制字符串（用于签名）
  static String bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toLowerCase();
  }
}

class TosService {
  static final TosService _instance = TosService._internal(); 
  factory TosService() => _instance;
  TosService._internal();

  static Future<String> test() async{
    final tosConfig = await IsarStorageService.getTosConfig();
    if (tosConfig == null) {
      throw Exception('TOS配置未设置，请先配置TOS服务');
    }
    TosClient client = TosClientBuilder()
        .ak(tosConfig.ak)
        .sk(tosConfig.sk)
        .region(TosConstants.region)
        .endpoint(TosConstants.endpoint)
        .build();
    String name = '';
    var output = await client.listBuckets(ListBucketsInput());
    print(output.requestId);
    for(var bucket in output.buckets){
        print(bucket.name);
        name= bucket.name;
    }
    client.close();
    return name;
  }

  static Future<void> uploadFile(String filePath,String fileKey) async {
    final tosConfig = await IsarStorageService.getTosConfig();
    if (tosConfig == null) {
      throw Exception('TOS配置未设置，请先配置TOS服务');
    }
    TosClient client = TosClientBuilder()
        .ak(tosConfig.ak)
        .sk(tosConfig.sk)
        .region(TosConstants.region)
        .endpoint(TosConstants.endpoint)
        .build();
    
    try {
      await client.putObjectFromFile(
        PutObjectFromFileInput(tosConfig.bucket, fileKey, filePath),
      );
    } finally {
      client.close();
    }
  }

  static Future<String> generateUrl(String fileKey) async {
    final tosConfig = await IsarStorageService.getTosConfig();
    if (tosConfig == null) {
      throw Exception('TOS配置未设置，请先配置TOS服务');
    }
    // 配置参数（替换为你的实际值）
  const expires = 3600; // 预签名URL过期时间（秒）

  // 生成预签名URL
  try {
    final presignedUrl = await TosPresignUtils.generatePresignedUrl(
      accessKeyId: tosConfig.ak,
      secretAccessKey: tosConfig.sk,
      region: TosConstants.region,
      bucketName: tosConfig.bucket,
      objectKey: fileKey,
      endpoint: TosConstants.endpoint2,
      expires: expires,
    );
    // 测试
    //   final presignedUrl = await TosPresignUtils.generatePresignedUrl(
    //   accessKeyId: 'testAK',
    //   secretAccessKey: 'testSK',
    //   region: TosConstants.region,
    //   bucketName: 'bucket-test',
    //   objectKey: '测试.jpg',
    //   endpoint: TosConstants.endpoint2,
    //   expires: expires,
    // );
    return presignedUrl;
  } catch (e) {
    throw Exception('生成预签名URL失败: $e');
  }
  }

  static Future<String> uploadFileAndGetUrl(String filePath, {String? fileKey=''}) async {
    if(filePath.isEmpty) {
      throw Exception('文件路径不能为空');
    }
    if (fileKey == null || fileKey.isEmpty) {
      // 支持正斜杠和反斜杠分隔符
      fileKey = filePath.split(RegExp(r'[\/\\]')).last;
    }
    await uploadFile(filePath, 'temp/$fileKey');
    await Future.delayed(const Duration(seconds: 3));
    return await generateUrl('temp/$fileKey');
  }

  static Future<void> downloadFile(String fileKey, {String? filePath = ''}) async {
    final tosConfig = await IsarStorageService.getTosConfig();
    if (tosConfig == null) {
      throw Exception('TOS配置未设置，请先配置TOS服务');
    }
    // 获取预签名下载链接
    final url = await generateUrl(fileKey);

    // 计算保存路径
    String savePath;
    if (filePath == null || filePath.isEmpty) {
      // 保存到当前工作目录
      final fileName = fileKey.split(RegExp(r'[\/\\]')).last;
      savePath = path.join(Directory.current.path, fileName);
    } else {
      savePath = path.isAbsolute(filePath) ? filePath : path.join(Directory.current.path, filePath);
    }

    // 若文件夹不存在则创建
    final dir = Directory(path.dirname(savePath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 下载文件
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('文件下载失败，状态码: ${response.statusCode}');
    }
  }

}