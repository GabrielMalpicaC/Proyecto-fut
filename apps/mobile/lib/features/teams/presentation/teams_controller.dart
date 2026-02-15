import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/teams/data/teams_repository.dart';

class TeamsController extends ChangeNotifier {
  TeamsController(this._repository);

  final TeamsRepository _repository;
  bool loading = false;

  Future<void> createTeam(String name) => _guard(() => _repository.createTeam(name));

  Future<void> inviteMember({required String teamId, required String invitedUserId}) =>
      _guard(() => _repository.inviteMember(teamId: teamId, invitedUserId: invitedUserId));

  Future<void> acceptInvite(String teamId) => _guard(() => _repository.acceptInvite(teamId: teamId));

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
