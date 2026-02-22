import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/auth/data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> bootstrap() async {
    _isAuthenticated = await _repository.isLoggedIn();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _run(() async {
      await _repository.login(email: email, password: password);
      _isAuthenticated = true;
    });
  }

  Future<void> register(String email, String fullName, String password, String role) async {
    await _run(() async {
      await _repository.register(email: email, fullName: fullName, password: password, role: role);
      _isAuthenticated = true;
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() fn) async {
    _isLoading = true;
    notifyListeners();
    try {
      await fn();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
