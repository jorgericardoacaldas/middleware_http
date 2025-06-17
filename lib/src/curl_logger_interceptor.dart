import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:middleware_http/curl_logger_interceptor.dart';

class CurlLoggerInterceptor extends Interceptor {
  final CurlLoggerStorage storage;

  CurlLoggerInterceptor({required this.storage});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final curlCommand = _generateCurlCommand(options);
    print('cURL: $curlCommand');

    // Salvando apenas o curl na requisição (sem status ou resposta ainda)
    await storage.save(
      curlCommand: curlCommand,
      responseBody: null,
      statusCode: null,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final curlCommand = _generateCurlCommand(response.requestOptions);
    final responseLog = jsonEncode(response.data);
    print('Response [${response.statusCode}]: $responseLog');

    await storage.save(
      curlCommand: curlCommand,
      responseBody: responseLog,
      statusCode: response.statusCode,
    );

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final curlCommand = _generateCurlCommand(err.requestOptions);
    final statusCode = err.response?.statusCode;
    final errorLog = err.message;
    print('Error [${statusCode ?? 'No status code'}]: $errorLog');

    await storage.save(
      curlCommand: curlCommand,
      responseBody: errorLog,
      statusCode: statusCode,
    );

    handler.next(err);
  }

  String _generateCurlCommand(RequestOptions options) {
    final buffer = StringBuffer();

    buffer.write('curl -X ${options.method} \'${options.uri}\'');
    options.headers.forEach((key, value) {
      buffer.write(' -H \'$key: $value\'');
    });

    if (options.data != null) {
      if (options.headers['Content-Type'] == 'application/json' && options.data is Map) {
        buffer.write(' -d \'${jsonEncode(options.data)}\'');
      } else if (options.data is FormData) {
        final formData = options.data as FormData;

        formData.fields.forEach((field) {
          buffer.write(' -F \'${field.key}=${field.value}\'');
        });

        formData.files.forEach((file) {
          final filePath = file.value.filename;
          buffer.write(' -F \'${file.key}=@$filePath\'');
        });
      }
    }

    return buffer.toString();
  }
}
