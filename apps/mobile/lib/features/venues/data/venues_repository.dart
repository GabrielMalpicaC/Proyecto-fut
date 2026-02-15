import 'package:proyecto_fut_app/core/network/api_client.dart';

class VenuesRepository {
  VenuesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createVenue({
    required String name,
    required String location,
    required double pricePerHour,
  }) async {
    await _apiClient.dio.post('/venues', data: {
      'name': name,
      'location': location,
      'pricePerHour': pricePerHour,
    });
  }

  Future<List<Map<String, dynamic>>> listVenues({String? query}) async {
    final response = await _apiClient.dio.get<List<dynamic>>('/venues', queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query,
    });
    return (response.data ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
