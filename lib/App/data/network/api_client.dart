import 'dart:async';
import 'dart:convert';

import 'package:babershop_project/App/data/network/dio_client.dart';
import 'package:babershop_project/App/data/network/dio_exception.dart';
import 'package:babershop_project/App/data/network/error_config.dart';
import 'package:get/get.dart';


class ApiClient extends GetxService {
  final DioClient dioClient;

  ApiClient({required this.dioClient});

  Future downloadData(url,path) async {
   return await dioClient.dio.download(url, path);
  }

  Future getData(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      var response = await dioClient.dio.get(path, queryParameters: queryParameters);
      return getResponse(body: response.data);
    } catch (e) {
      return handleException(e);
    }
  }

  Future postData(String path, dynamic body,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      var response = await dioClient.dio.post(
        path,
        data: body,
      );
      return getResponse(body: response.data);
    } catch (e) {
      return handleException(e);
    }
  }

  Future putData(String path, dynamic body,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      var response = await dioClient.dio.put(
        path,
        data: body,
      );
      return getResponse(body: response.data);
    } catch (e) {
      return handleException(e);
    }
  }

  Future updateData(String path, dynamic body,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      var response = await dioClient.dio.patch(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return getResponse(body: response.data);
    } catch (e) {
      return handleException(e);
    }
  }

  Response handleException(dioException) {
    String errorCode = DioExceptions.fromDioError(dioException).toString();
    Map body = {
      "success": false,
      "data": null,
      "message": ErrorConfig.errorMessageMap[errorCode]
    };
    return getResponse(code: errorCode, body: jsonDecode(jsonEncode(body)));
  }

  getResponse({
    dynamic body,
    String? code,
  }) {
    return Response(
      body: body,
      statusText: code ?? ErrorConfig.C008,
    );
  }
}
