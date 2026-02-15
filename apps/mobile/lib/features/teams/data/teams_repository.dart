import 'package:proyecto_fut_app/core/network/api_client.dart';

class TeamsRepository {
  TeamsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createTeam(String name) async {
    await _apiClient.dio.post('/teams', data: {'name': name});
  }

  Future<void> inviteMember({required String teamId, required String invitedUserId}) async {
    await _apiClient.dio.post('/teams/$teamId/invite', data: {'invitedUserId': invitedUserId});
  }

  Future<void> acceptInvite({required String teamId}) async {
    await _apiClient.dio.post('/teams/$teamId/accept');
  }
}
