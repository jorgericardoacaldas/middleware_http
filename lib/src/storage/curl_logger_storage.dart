abstract class CurlLoggerStorage {
  Future<void> save({
    required String curlCommand,
    required String? responseBody,
    required int? statusCode,
  });
}
