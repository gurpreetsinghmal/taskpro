import 'package:dio/dio.dart';
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
        baseUrl: 'https://api.taskpro.com/api/',
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 90),
        receiveTimeout: const Duration(seconds: 90),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

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
          handler.next(response);
        },

        onError: (DioException error, handler) {
          handler.next(error);
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