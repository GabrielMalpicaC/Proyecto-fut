import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/teams/data/teams_repository.dart';

class TeamsController extends ChangeNotifier {
  TeamsController(this._repository);

  final TeamsRepository _repository;
  bool loading = false;
  List<dynamic> openTeams = [];
  Map<String, dynamic>? selectedTeam;

  Future<void> loadOpenTeams() => _guard(() async {
        openTeams = await _repository.listOpenTeams();
      });

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

  Future<void> applyToTeam({required String teamId, String? message}) =>
      _guard(() => _repository.applyToTeam(teamId: teamId, message: message));

  Future<void> _guard(Future<void> Function() action) async {
    loading = true;
    notifyListeners();
    try {
      await action();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
