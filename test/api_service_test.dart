import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskpro/network/api_exception.dart';
import 'package:taskpro/network/api_service.dart';

void main() {
  test(
    'transport refactor preserves method, payload, query, and header precedence',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final requests = <RequestOptions>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'ok': true},
              ),
            );
          },
        ),
      );
      final api = ApiService(dio: dio);
      await api.get(
        '/orders',
        queryParameters: {'page': 2},
        options: Options(headers: {'X-Mode': 'old'}),
        headers: {'X-Mode': 'new'},
      );
      await api.post('/orders', data: {'status_id': 59});
      await api.put('/orders/1', data: {'name': 'changed'});
      await api.delete('/orders/1');
      await api.postMultipart(
        '/photos',
        data: FormData.fromMap({'remarks': 'done'}),
      );
      expect(requests.map((request) => request.method), [
        'GET',
        'POST',
        'PUT',
        'DELETE',
        'POST',
      ]);
      expect(requests.first.queryParameters, {'page': 2});
      expect(requests.first.headers['X-Mode'], 'new');
      expect(requests[1].data, {'status_id': 59});
      expect(requests.last.contentType, contains('multipart/form-data'));
    },
  );

  test(
    'transport errors retain the existing mapped API message and status',
    () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {'message': 'Invalid work order'},
                ),
              ),
            );
          },
        ),
      );
      await expectLater(
        ApiService(dio: dio).post('/orders'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 400)
              .having((e) => e.message, 'message', 'Invalid work order'),
        ),
      );
    },
  );
}
