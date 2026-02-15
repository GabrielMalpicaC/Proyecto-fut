import 'package:proyecto_fut_app/core/network/api_client.dart';

class WalletRepository {
  WalletRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<double> getBalance() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/wallet/balance');
    return (res.data?['balance'] as num?)?.toDouble() ?? 0;
  }

  Future<void> topUp(double amount) async {
    await _apiClient.dio.post('/wallet/top-up', data: {'amount': amount});
  }

  Future<void> createHold({
    required double amount,
    required String reason,
    required String referenceId,
  }) async {
    await _apiClient.dio.post('/wallet/holds', data: {
      'amount': amount,
      'reason': reason,
      'referenceId': referenceId,
    });
  }

  Future<void> releaseHold(String holdId) async {
    await _apiClient.dio.post('/wallet/holds/release', data: {'holdId': holdId});
  }

  Future<void> settleHold({required String holdId, required String ownerUserId}) async {
    await _apiClient.dio.post('/wallet/holds/settle', data: {
      'holdId': holdId,
      'ownerUserId': ownerUserId,
    });
  }
}
