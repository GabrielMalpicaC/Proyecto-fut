import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/wallet/data/wallet_repository.dart';

class WalletController extends ChangeNotifier {
  WalletController(this._repository);

  final WalletRepository _repository;
  double balance = 0;
  bool loading = false;

  Future<void> fetchBalance() async {
    loading = true;
    notifyListeners();
    try {
      balance = await _repository.getBalance();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> topUp(double amount) async {
    await _repository.topUp(amount);
    await fetchBalance();
  }

  Future<void> createHold({
    required double amount,
    required String reason,
    required String referenceId,
  }) async {
    await _repository.createHold(amount: amount, reason: reason, referenceId: referenceId);
    await fetchBalance();
  }

  Future<void> releaseHold(String holdId) async {
    await _repository.releaseHold(holdId);
    await fetchBalance();
  }

  Future<void> settleHold({required String holdId, required String ownerUserId}) async {
    await _repository.settleHold(holdId: holdId, ownerUserId: ownerUserId);
    await fetchBalance();
  }
}
