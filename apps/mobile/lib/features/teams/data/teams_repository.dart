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

  Future<Map<String, dynamic>> getMyTeam() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/teams/me');
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> getTeamProfile(String teamId) async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/teams/$teamId');
    return res.data ?? {};
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/profile/users/$userId');
    return res.data ?? {};
  }

  Future<void> updateTeam({
    required String teamId,
    String? name,
    String? description,
    String? formation,
    int? footballType,
    String? shieldUrl,
    bool? isRecruiting,
  }) async {
    await _apiClient.dio.patch('/teams/$teamId', data: {
      if (name != null && name.isNotEmpty) 'name': name,
      if (description != null) 'description': description,
      if (formation != null && formation.isNotEmpty) 'formation': formation,
      if (footballType != null) 'footballType': footballType,
      if (shieldUrl != null && shieldUrl.isNotEmpty) 'shieldUrl': shieldUrl,
      if (isRecruiting != null) 'isRecruiting': isRecruiting,
    });
  }

  Future<void> updateMemberRole({
    required String teamId,
    required String memberUserId,
    required String role,
  }) async {
    await _apiClient.dio.patch('/teams/$teamId/members/$memberUserId/role', data: {'role': role});
  }

  Future<void> removeMember({
    required String teamId,
    required String memberUserId,
  }) async {
    await _apiClient.dio.patch('/teams/$teamId/members/$memberUserId/remove');
  }

  Future<void> applyToTeam({required String teamId, String? message}) async {
    await _apiClient.dio.post('/teams/$teamId/apply', data: {
      if (message != null && message.isNotEmpty) 'message': message,
    });
  }
}
