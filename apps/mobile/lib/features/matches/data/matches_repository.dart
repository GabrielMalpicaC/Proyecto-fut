import 'package:proyecto_fut_app/core/network/api_client.dart';

class MatchesRepository {
  MatchesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> searchMatch(String mode) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>('/matches/search', data: {'mode': mode});
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> cancelSearch(String mode) async {
    final res = await _apiClient.dio
        .post<Map<String, dynamic>>('/matches/cancel-search', data: {'mode': mode});
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> searchStatus() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/matches/search-status');
    return res.data ?? {};
  }
}
