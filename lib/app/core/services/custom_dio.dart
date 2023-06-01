import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:leviathan_app/app/core/interfaces/http_service.dart';

class _DioStatus extends dio.Interceptor {
  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    final message = 'REQUEST[${options.method}] => PATH: ${options.path}';
    log(message);
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) {
    final message = 'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}';
    log(message);
    return super.onResponse(response, handler);
  }

  @override
  void onError(dio.DioError err, dio.ErrorInterceptorHandler handler) {
    log(err.message ?? '', error: err);
    super.onError(err, handler);
  }
}

class CustomDio implements IHttpService<dio.ResponseType, dio.Response, dio.Interceptor> {
  late final dio.Dio _dio;

  CustomDio._internal([dio.BaseOptions? options]) {
    _dio = dio.Dio(options);
    add(_DioStatus());
  }

  factory CustomDio.createInstance([dio.BaseOptions? options]) => CustomDio._internal(options);

  factory CustomDio() => _instance;

  static final _instance = CustomDio._internal();

  @override
  Future<dio.Response> delete(
    String url, {
    data,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    responseType = dio.ResponseType.json,
  }) async {
    return await _dio.delete(
      url,
      data: data,
      queryParameters: params,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> get(
    String url, {
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    responseType = dio.ResponseType.json,
  }) async {
    return await _dio.get(
      url,
      queryParameters: params,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> patch(
    String url, {
    data,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    responseType = dio.ResponseType.json,
    Encoding? encoding,
  }) async {
    return await _dio.patch(
      url,
      data: data,
      queryParameters: params,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> post(
    String url, {
    data,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    responseType = dio.ResponseType.json,
    Encoding? encoding,
  }) async {
    return await _dio.post(
      url,
      data: data,
      queryParameters: params,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> put(
    String url, {
    data,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    responseType = dio.ResponseType.json,
    Encoding? encoding,
  }) async {
    return await _dio.put(
      url,
      data: data,
      queryParameters: params,
      options: dio.Options(
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  Future<dio.Response> request(
    String url, {
    data,
    String method = 'get',
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    responseType = dio.ResponseType.json,
    Encoding? encoding,
  }) async {
    return await _dio.request(
      url,
      data: data,
      queryParameters: params,
      options: dio.Options(
        method: method,
        headers: headers,
        responseType: responseType,
      ),
    );
  }

  @override
  void add(dio.Interceptor element) {
    if (!interceptors.contains(element)) _dio.interceptors.add(element);
  }

  @override
  List<dio.Interceptor> get interceptors => _dio.interceptors;
}
