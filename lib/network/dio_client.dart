import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';


class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() {
    return _instance;
  }

  late final Dio dio;

  final  _tokenStorage = SecureStorageService.instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiRoutes.baseURL,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

    _configureInterceptors();
  }

  void _configureInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Some APIs may not require authentication.
          final requiresAuth =
              options.extra['requiresAuth'] ?? true;

          if (requiresAuth) {
            final token = await _tokenStorage.getAccessToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] =
              'Bearer $token';
            }
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          print("===================================================");
          print("||URL: ${response.requestOptions.uri}");
          print("||METHOD:  ${response.requestOptions.method}");
          print("||HEADERS: ${response.requestOptions.headers}");
          print("||BODY: ${response.requestOptions.data}");
          print("||✅ RESPONSE");
          print("||DATA: ${response.data}");
          print("===================================================");

          if(response.statusCode == 200 && response.data["status_code"].toString()=="999"){
            final storage = SecureStorageService.instance;
            storage.loggedOut();
          }
          handler.next(response);
        },

        onError: (DioException e, handler) {
          print("❌ ERROR");
          print("URL: ${e.requestOptions.uri}");
          print("MESSAGE: ${e.message}");

          /// 🔥 Handle Token Expired (401)
          if (e.response?.statusCode == 401) {
            // TODO: refresh token or logout
            print("⚠️ Unauthorized - Token expired");
          }
          handler.next(e);
        },
      ),
    );

    // Add LogInterceptor only in development.
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<void> setAccessToken(String token) async {
    await _tokenStorage.write(StorageKeys.accessToken, token);
  }

  Future<void> clearAuthentication() async {
    await _tokenStorage.delete(StorageKeys.accessToken);
  }
}