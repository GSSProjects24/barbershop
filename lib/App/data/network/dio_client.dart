import 'package:babershop_project/App/config/app_config.dart';
import 'package:babershop_project/App/provider/canstant.dart';
import 'package:dio/dio.dart' show Dio, ResponseType;

import 'package:babershop_project/App/data/network/dio_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio) {
    dio
      ..options.baseUrl = Constants.baseUrl
      //..options.headers = ApiConfig.header
      ..options.connectTimeout = ApiConfig.connectionTimeout
      ..options.receiveTimeout = ApiConfig.receiveTimeout
      ..options.responseType = ResponseType.json
      ..interceptors.add(DioInterceptor());
  }
}
