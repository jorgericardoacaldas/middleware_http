import 'dart:convert';
import 'package:dio/dio.dart';
import 'curl_logger_storage.dart';

class RemoteCurlLoggerStorage implements CurlLoggerStorage {
  final String endpoint;
  final Dio dio;

  RemoteCurlLoggerStorage({required this.endpoint, Dio? dioClient})
      : dio = dioClient ?? Dio();

  @override
  Future<void> save({
    required String curlCommand,
    required String? responseBody,
    required int? statusCode,
  }) async {
    try {
      await dio.post(endpoint, data: {
        'curl': curlCommand,
        'statusCode': statusCode,
        'response': responseBody,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending curl log to remote: $e');
    }
  }
}
