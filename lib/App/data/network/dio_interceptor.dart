import 'dart:convert';
import 'dart:developer';
import 'package:babershop_project/App/config/app_config.dart';
import 'package:babershop_project/App/data/network/app_extention.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';


class DioInterceptor extends Interceptor {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
    ),
  );

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (AppConfig.canLog) {
      log('====================START====================');
      log('HTTP method => ${options.method} ');
      log('Request => ${options.baseUrl}${options.path}${options.queryParameters.format}');
      log('Header  => ${options.headers}');
      log('Request Body  => ${jsonEncode(options.data)}');
      log('Request Parameter  => ${jsonEncode(options.queryParameters)}');
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (AppConfig.canLog) {
      final options = err.requestOptions;
      logger.e(options.method); // Debug log
      logger.e('Error: ${err.error}, Message: ${err.message}');
    }

    return super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.canLog) {
      logger.d('Response => StatusCode: ${response.statusCode}'); // Debug log
      logger.d('Response => Body: ${response.data}'); // Debug log
      log("Response =>Data:${jsonEncode(response.data)}");
    }

    return super.onResponse(response, handler);
  }
}
