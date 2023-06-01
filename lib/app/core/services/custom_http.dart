// import 'dart:convert';

// // ignore: depend_on_referenced_packages
// import 'package:http/http.dart' as http;
// import 'package:leviathan_app/app/core/interfaces/ihttp_service.dart';

// class HttpService implements IHttpService<dynamic, http.Response, dynamic> {
//   @override
//   void add(element) {
//     interceptors.add(element);
//   }

//   @override
//   Future<http.Response> delete(
//     String url, {
//     data,
//     Map<String, String> headers = const {},
//     Map<String, String> params = const {},
//     responseType,
//   }) async {
//     final uriParse = Uri.parse(url);
//     return http.delete(
//       uriParse,
//       headers: headers,
//     );
//   }

//   @override
//   Future<http.Response> get(
//     String url, {
//     Map<String, String> headers = const {},
//     Map<String, String> params = const {},
//     responseType,
//   }) async {
//     final uriParse = Uri.parse(url);
//     return http.get(
//       uriParse,
//       headers: headers,
//     );
//   }

//   @override
//   List get interceptors => [];

//   @override
//   Future<http.Response> patch(
//     String url, {
//     data,
//     Map<String, String> headers = const {},
//     Map<String, String> params = const {},
//     responseType,
//     Encoding? encoding,
//   }) async {
//     final uriParse = Uri.parse(url);
//     return http.patch(
//       uriParse,
//       body: data,
//       encoding: encoding,
//       headers: headers,
//     );
//   }

//   @override
//   Future<http.Response> post(
//     String url, {
//     data,
//     Map<String, String> headers = const {},
//     Map<String, String> params = const {},
//     responseType,
//     Encoding? encoding,
//   }) async {
//     final uriParse = Uri.parse(url);
//     return await http.post(
//       uriParse,
//       body: data,
//       encoding: encoding,
//       headers: headers,
//     );
//   }

//   @override
//   Future<http.Response> put(
//     String url, {
//     data,
//     Map<String, String> headers = const {},
//     Map<String, String> params = const {},
//     responseType,
//     Encoding? encoding,
//   }) async {
//     final uriParse = Uri.parse(url);
//     return await http.put(
//       uriParse,
//       body: data,
//       encoding: encoding,
//       headers: headers,
//     );
//   }

//   @override
//   Future<http.Response> request(
//     String url, {
//     data,
//     String method = 'get',
//     Map<String, String> headers = const {},
//     Map<String, String> params = const {},
//     responseType,
//     Encoding? encoding,
//   }) {
//     throw UnimplementedError();
//   }
// }
