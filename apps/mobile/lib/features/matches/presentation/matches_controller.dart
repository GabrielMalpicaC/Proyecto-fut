import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/matches/data/matches_repository.dart';

class MatchesController extends ChangeNotifier {
  MatchesController(this._repository);

  final MatchesRepository _repository;
  bool loading = false;
  String mode = 'CASUAL';
  String? status;
  Map<String, dynamic>? match;
  String? error;

  Future<void> loadStatus() => _guard(() async {
        final res = await _repository.searchStatus();
        status = res['searching'] == true ? 'SEARCHING' : null;
      });

  Future<void> search() => _guard(() async {
        final res = await _repository.searchMatch(mode);
        status = res['status']?.toString();
        match = res['match'] as Map<String, dynamic>?;
      });

  Future<void> cancel() => _guard(() async {
        await _repository.cancelSearch(mode);
        status = null;
        match = null;
      });

  void setMode(String nextMode) {
    mode = nextMode;
    notifyListeners();
  }

  Future<void> _guard(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
