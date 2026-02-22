import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/teams/data/teams_repository.dart';

class TeamsController extends ChangeNotifier {
  TeamsController(this._repository);

  final TeamsRepository _repository;
  bool loading = false;
  String? error;
  List<dynamic> openTeams = [];
  Map<String, dynamic>? selectedTeam;
  Map<String, dynamic>? myTeam;
  Map<String, dynamic>? selectedPlayerProfile;

  Future<void> loadOpenTeams() => _guard(
        () async {
          openTeams = await _repository.listOpenTeams();
        },
        rethrowError: false,
      );

  Future<void> loadMyTeam() => _guard(
        () async {
          myTeam = await _repository.getMyTeam();
        },
        rethrowError: false,
      );

  Future<void> loadTeamProfile(String teamId) => _guard(() async {
        selectedTeam = await _repository.getTeamProfile(teamId);
      });

  Future<void> createTeam({
    required String name,
    required int footballType,
    required String formation,
    String? description,
    String? shieldUrl,
  }) =>
      _guard(
        () => _repository.createTeam(
          name: name,
          footballType: footballType,
          formation: formation,
          description: description,
          shieldUrl: shieldUrl,
        ),
      );

  Future<void> updateTeam({
    required String teamId,
    String? name,
    String? description,
    String? formation,
    int? footballType,
    String? shieldUrl,
    bool? isRecruiting,
  }) =>
      _guard(
        () => _repository.updateTeam(
          teamId: teamId,
          name: name,
          description: description,
          formation: formation,
          footballType: footballType,
          shieldUrl: shieldUrl,
          isRecruiting: isRecruiting,
        ),
      );

  Future<void> applyToTeam({required String teamId, String? message}) =>
      _guard(() => _repository.applyToTeam(teamId: teamId, message: message));


  Future<void> loadPlayerProfile(String userId) => _guard(() async {
        selectedPlayerProfile = await _repository.getUserProfile(userId);
      });

  Future<void> setMemberRole({
    required String teamId,
    required String memberUserId,
    required String role,
  }) =>
      _guard(
        () => _repository.updateMemberRole(
          teamId: teamId,
          memberUserId: memberUserId,
          role: role,
        ),
      );

  Future<void> kickMember({
    required String teamId,
    required String memberUserId,
  }) =>
      _guard(
        () => _repository.removeMember(
          teamId: teamId,
          memberUserId: memberUserId,
        ),
      );


  Future<void> _guard(
    Future<void> Function() action, {
    bool rethrowError = true,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = e.toString();
      if (rethrowError) rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
