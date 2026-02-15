import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/bookings/data/bookings_repository.dart';

class BookingsController extends ChangeNotifier {
  BookingsController(this._repository);

  final BookingsRepository _repository;
  bool loading = false;

  Future<void> createBooking({
    required String venueId,
    required DateTime startsAt,
    required DateTime endsAt,
  }) => _guard(() => _repository.createBooking(venueId: venueId, startsAt: startsAt, endsAt: endsAt));

  Future<void> finalizeBooking(String bookingId) => _guard(() => _repository.finalizeBooking(bookingId));

  Future<void> _guard(Future<void> Function() fn) async {
    loading = true;
    notifyListeners();
    try {
      await fn();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
