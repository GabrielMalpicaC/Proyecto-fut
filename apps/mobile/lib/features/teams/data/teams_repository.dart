import 'package:proyecto_fut_app/core/network/api_client.dart';

class TeamsRepository {
  TeamsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createTeam({required String name, required int maxPlayers, String? description}) async {
    await _apiClient.dio.post('/teams', data: {
      'name': name,
      'maxPlayers': maxPlayers,
      if (description != null && description.isNotEmpty) 'description': description,
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

  Future<void> inviteMember({required String teamId, required String invitedUserId}) async {
    await _apiClient.dio.post('/teams/$teamId/invite', data: {'invitedUserId': invitedUserId});
  }

  Future<void> acceptInvite({required String teamId}) async {
    await _apiClient.dio.post('/teams/$teamId/accept');
  }
}
