import 'dart:convert';

abstract interface class IHttpService<IResponseType, IResponse, IE> {
  final List<IE> interceptors = [];

  Future<IResponse> get(
    String url, {
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    IResponseType responseType,
  });

  Future<IResponse> post(
    String url, {
    dynamic data,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    IResponseType responseType,
    Encoding? encoding,
  });

  Future<IResponse> put(
    String url, {
    dynamic data,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    IResponseType responseType,
    Encoding? encoding,
  });

  Future<IResponse> patch(
    String url, {
    dynamic data,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    IResponseType responseType,
    Encoding? encoding,
  });

  Future<IResponse> delete(
    String url, {
    dynamic data,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    IResponseType responseType,
  });

  Future<IResponse> request(
    String url, {
    dynamic data,
    String method = 'get',
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    IResponseType responseType,
    Encoding? encoding,
  });

  void add(IE element) {
    interceptors.add(element);
  }
}
