import 'package:proyecto_fut_app/core/network/api_client.dart';

class TeamsRepository {
  TeamsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createTeam({
    required String name,
    required int footballType,
    required String formation,
    String? description,
    String? shieldUrl,
  }) async {
    await _apiClient.dio.post('/teams', data: {
      'name': name,
      'footballType': footballType,
      'formation': formation,
      if (description != null && description.isNotEmpty) 'description': description,
      if (shieldUrl != null && shieldUrl.isNotEmpty) 'shieldUrl': shieldUrl,
    });
  }

  Future<List<dynamic>> listOpenTeams() async {
    final res = await _apiClient.dio.get<List<dynamic>>('/teams/open');
    return res.data ?? [];
  }

  Future<Map<String, dynamic>> getTeamProfile(String teamId) async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/teams/$teamId');
    return res.data ?? {};
  }

  Future<void> applyToTeam({required String teamId, String? message}) async {
    await _apiClient.dio.post('/teams/$teamId/apply', data: {
      if (message != null && message.isNotEmpty) 'message': message,
    });
  }
}
