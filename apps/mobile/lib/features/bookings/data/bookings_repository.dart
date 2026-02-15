import 'package:proyecto_fut_app/core/network/api_client.dart';

class BookingsRepository {
  BookingsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<void> createBooking({
    required String venueId,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    await _apiClient.dio.post('/bookings', data: {
      'venueId': venueId,
      'startsAt': startsAt.toIso8601String(),
      'endsAt': endsAt.toIso8601String(),
    });
  }

  Future<void> finalizeBooking(String bookingId) async {
    await _apiClient.dio.post('/bookings/$bookingId/finalize');
  }
}
