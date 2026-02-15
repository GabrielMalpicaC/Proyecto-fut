import 'package:dio/dio.dart';
import 'package:proyecto_fut_app/core/config/app_config.dart';
import 'package:proyecto_fut_app/core/storage/token_storage.dart';
import 'package:proyecto_fut_app/shared/models/api_error.dart';

class ApiClient {
  ApiClient(this._tokenStorage) {
    dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final data = error.response?.data;
          final message = data is Map<String, dynamic>
              ? (data['message']?.toString() ?? 'Error de red')
              : 'Error de red';
          final code = data is Map<String, dynamic> ? data['code']?.toString() : null;
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiError(message, code: code),
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio dio;
}
