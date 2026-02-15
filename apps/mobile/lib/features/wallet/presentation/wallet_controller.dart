import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/wallet/data/wallet_repository.dart';

class WalletController extends ChangeNotifier {
  WalletController(this._repository);

  final WalletRepository _repository;
  double balance = 0;
  bool loading = false;
  String? error;

  Future<void> fetchBalance() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      balance = await _repository.getBalance();
    } catch (e) {
      error = _toReadableError(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> topUp(double amount) async {
    await _guard(() async {
      await _repository.topUp(amount);
      await fetchBalance();
    });
  }

  Future<void> createHold({
    required double amount,
    required String reason,
    required String referenceId,
  }) async {
    await _guard(() async {
      await _repository.createHold(amount: amount, reason: reason, referenceId: referenceId);
      await fetchBalance();
    });
  }

  Future<void> releaseHold(String holdId) async {
    await _guard(() async {
      await _repository.releaseHold(holdId);
      await fetchBalance();
    });
  }

  Future<void> settleHold({required String holdId, required String ownerUserId}) async {
    await _guard(() async {
      await _repository.settleHold(holdId: holdId, ownerUserId: ownerUserId);
      await fetchBalance();
    });
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      error = _toReadableError(e);
      notifyListeners();
      rethrow;
    }
  }

  String _toReadableError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }

      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'No hay conexión con el backend. Verifica que el API esté corriendo en localhost:3000.';
      }

      return 'No pudimos cargar wallet en este momento.';
    }

    return 'Ocurrió un error inesperado.';
  }
}
