import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:taskpro/services/data_loading_service.dart';

import 'api_exception.dart';
import 'dio_client.dart';

class ApiService {
  final Dio _dio = DioClient().dio;

  Future<bool> checkInternet() async {
    try {
      // 1. checkConnectivity() now returns List<ConnectivityResult>
      final List<ConnectivityResult> connectivityResult =
      await Connectivity().checkConnectivity();

      // 2. Check if the list contains 'none' or is empty
      if (connectivityResult.contains(ConnectivityResult.none) ||
          connectivityResult.isEmpty) {
        return false;
      }

      // 3. Perform DNS lookup
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // GET
  // ============================================================

  Future<Response<T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        bool isLoaderShow = false,
      }) async {
    bool showedLoader = false;
    try {
      if (isLoaderShow) {
        LoadingService.show("Fetching data...");
        showedLoader = true;
      }
      final response = await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _mergeOptions(
          options,
          headers,
        ),
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } finally {
      if (showedLoader) {
        LoadingService.hide();
      }
    }
  }

  // ============================================================
  // POST JSON
  // ============================================================

  Future<Response<T>> post<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        bool isLoaderShow = false,
      }) async {
    bool showedLoader = false;
    try {
      if (isLoaderShow) {
        LoadingService.show("Processing...");
        showedLoader = true;
      }
      final response = await _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _mergeOptions(
          options,
          headers,
        ),
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } finally {
      if (showedLoader) {
        LoadingService.hide();
      }
    }
  }

  // ============================================================
  // POST MULTIPART
  // ============================================================

  Future<Response<T>> postMultipart<T>(
      String endpoint, {
        required FormData data,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool isLoaderShow = false,
      }) async {
    bool showedLoader = false;
    try {
      if (isLoaderShow) {
        LoadingService.show("Uploading...");
        showedLoader = true;
      }
      final response = await _dio.post<T>(
        endpoint,
        data: data,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: _mergeOptions(
          options,
          {
            ...?headers,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } finally {
      if (showedLoader) {
        LoadingService.hide();
      }
    }
  }

  // ============================================================
  // PUT
  // ============================================================

  Future<Response<T>> put<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        bool isLoaderShow = false,
      }) async {
    bool showedLoader = false;
    try {
      if (isLoaderShow) {
        LoadingService.show("Updating...");
        showedLoader = true;
      }
      final response = await _dio.put<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _mergeOptions(
          options,
          headers,
        ),
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } finally {
      if (showedLoader) {
        LoadingService.hide();
      }
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<Response<T>> delete<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
        Options? options,
        CancelToken? cancelToken,
        bool isLoaderShow = false,
      }) async {
    bool showedLoader = false;
    try {
      if (isLoaderShow) {
        LoadingService.show("Deleting...");
        showedLoader = true;
      }
      final response = await _dio.delete<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _mergeOptions(
          options,
          headers,
        ),
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } finally {
      if (showedLoader) {
        LoadingService.hide();
      }
    }
  }

  // ============================================================
  // OPTIONS
  // ============================================================

  Options _mergeOptions(
      Options? options,
      Map<String, dynamic>? headers,
      ) {
    final mergedHeaders = <String, dynamic>{
      ...?options?.headers,
      ...?headers,
    };

    return Options(
      method: options?.method,
      headers: mergedHeaders,
      responseType: options?.responseType,
      contentType: options?.contentType,
      validateStatus: options?.validateStatus,
      receiveDataWhenStatusError:
      options?.receiveDataWhenStatusError,
      sendTimeout: options?.sendTimeout,
      receiveTimeout: options?.receiveTimeout,
      extra: options?.extra,
      followRedirects: options?.followRedirects,
      maxRedirects: options?.maxRedirects,
      persistentConnection: options?.persistentConnection,
      requestEncoder: options?.requestEncoder,
      responseDecoder: options?.responseDecoder,
    );
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  ApiException _handleDioException(
      DioException error,
      ) {
    final response = error.response;

    final statusCode = response?.statusCode;

    if (statusCode == 400) {
      return ApiException(
        message: _getServerMessage(
          response?.data,
          'Invalid request.',
        ),
        statusCode: statusCode,
        data: response?.data,
      );
    }

    if (statusCode == 401) {
      return ApiException(
        message: 'Your session has expired. Please login again.',
        statusCode: statusCode,
        data: response?.data,
      );
    }

    if (statusCode == 403) {
      return ApiException(
        message: 'You do not have permission to perform this action.',
        statusCode: statusCode,
        data: response?.data,
      );
    }

    if (statusCode == 404) {
      return ApiException(
        message: 'Requested resource was not found.',
        statusCode: statusCode,
        data: response?.data,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        message: 'Server error. Please try again later.',
        statusCode: statusCode,
        data: response?.data,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: statusCode,
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request upload timed out.',
          statusCode: statusCode,
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Server response timed out.',
          statusCode: statusCode,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect to the server.',
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: statusCode,
        );

      default:
        return ApiException(
          message: error.message ?? 'Something went wrong.',
          statusCode: statusCode,
          data: response?.data,
        );
    }
  }

  String _getServerMessage(
      dynamic data,
      String fallback,
      ) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }
}


