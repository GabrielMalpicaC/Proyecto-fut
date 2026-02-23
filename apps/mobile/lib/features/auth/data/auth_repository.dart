import 'package:dio/dio.dart';
import 'package:proyecto_fut_app/core/network/api_client.dart';
import 'package:proyecto_fut_app/core/storage/token_storage.dart';
import 'package:proyecto_fut_app/shared/models/api_error.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> register({
    required String email,
    required String fullName,
    required String password,
    required String role,
  }) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'fullName': fullName,
        'password': password,
        'role': role,
        'roles': [role],
      },
    );
    await _saveTokens(res.data);
  }

  Future<void> login({required String email, required String password}) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    await _saveTokens(res.data);
  }

  Future<void> refresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) throw ApiError('No hay refresh token');

    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    await _saveTokens(res.data);
  }

  Future<void> logout() => _tokenStorage.clear();

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveTokens(Map<String, dynamic>? data) async {
    if (data == null) throw ApiError('Respuesta inválida');
    final accessToken = data['accessToken']?.toString();
    final refreshToken = data['refreshToken']?.toString();
    if (accessToken == null || refreshToken == null) {
      throw ApiError('No se recibieron tokens');
    }
    await _tokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
  }
}
