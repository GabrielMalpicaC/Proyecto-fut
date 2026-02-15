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
        onError: (error, handler) async {
          if (_shouldRefresh(error.requestOptions, error.response?.statusCode)) {
            try {
              final newAccessToken = await _refreshAccessToken();
              final requestOptions = error.requestOptions;
              requestOptions.extra['retried'] = true;
              requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await dio.fetch<dynamic>(requestOptions);
              handler.resolve(retryResponse);
              return;
            } catch (_) {
              await _tokenStorage.clear();
              handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: ApiError('Sesión expirada. Inicia sesión nuevamente.', code: 'UNAUTHORIZED'),
                  response: error.response,
                  type: error.type,
                ),
              );
              return;
            }
          }

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

  bool _shouldRefresh(RequestOptions options, int? statusCode) {
    final path = options.path;
    final isAuthEndpoint = path.contains('/auth/login') || path.contains('/auth/register') || path.contains('/auth/refresh');
    final alreadyRetried = options.extra['retried'] == true;
    return statusCode == 401 && !isAuthEndpoint && !alreadyRetried;
  }

  Future<String> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiError('No hay refresh token');
    }

    final client = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
    final response = await client.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final accessToken = response.data?['accessToken']?.toString();
    final nextRefreshToken = response.data?['refreshToken']?.toString();

    if (accessToken == null || nextRefreshToken == null) {
      throw ApiError('No se pudo refrescar la sesión');
    }

    await _tokenStorage.saveTokens(accessToken: accessToken, refreshToken: nextRefreshToken);
    return accessToken;
  }
}
