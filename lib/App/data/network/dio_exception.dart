import 'dart:io';
import 'package:babershop_project/App/data/network/error_config.dart';
import 'package:dio/dio.dart' show DioException, DioExceptionType;


class DioExceptions implements Exception {
  late String errorCode;
  DioExceptions.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        errorCode = ErrorConfig.C003;
        break;
      case DioExceptionType.connectionTimeout:
        errorCode = ErrorConfig.C004;
        break;
      case DioExceptionType.receiveTimeout:
        errorCode = ErrorConfig.C005;
        break;
      case DioExceptionType.badResponse:
        try {
          errorCode = dioException.response?.statusCode as String;
        } catch (e) {
          errorCode = ErrorConfig.C006;
        }
        break;
      case DioExceptionType.sendTimeout:
        errorCode = ErrorConfig.C007;
        break;
      case DioExceptionType.connectionError:
        if (dioException.error is SocketException) {
          errorCode = ErrorConfig.C001;
          break;
        } else {
          errorCode = ErrorConfig.C002;
        }
        break;
      case DioExceptionType.unknown:
        if (dioException.error is SocketException) {
          errorCode = ErrorConfig.C001;
          break;
        } else {
          errorCode = ErrorConfig.C002;
        }
        break;
      default:
        errorCode = ErrorConfig.C002;
        break;
    }
  }

  @override
  String toString() => errorCode;
}
