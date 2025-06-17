
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'curl_logger_storage.dart';

class FileCurlLoggerStorage implements CurlLoggerStorage {
  final String fileName;

  FileCurlLoggerStorage({this.fileName = 'curl_logs.txt'});

  @override
  Future<void> save({
    required String curlCommand,
    required String? responseBody,
    required int? statusCode,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');

      final responseLog = 'Status: ${statusCode ?? 'No status code'}\n'
          'Response: ${responseBody ?? 'No response body'}\n';

      await file.writeAsString('$curlCommand\n$responseLog\n\n', mode: FileMode.append);
    } catch (e) {
      print('Error writing curl log to file: $e');
    }
  }
}
