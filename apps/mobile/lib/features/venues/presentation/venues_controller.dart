import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/venues/data/venues_repository.dart';

class VenuesController extends ChangeNotifier {
  VenuesController(this._repository);

  final VenuesRepository _repository;
  bool loading = false;
  String? error;
  List<Map<String, dynamic>> venues = [];

  Future<void> fetch({String? query}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      venues = await _repository.listVenues(query: query);
    } catch (e) {
      error = _toReadableError(e);
      venues = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createVenue({
    required String name,
    required String location,
    required double pricePerHour,
  }) async {
    try {
      await _repository.createVenue(name: name, location: location, pricePerHour: pricePerHour);
      await fetch();
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

      return 'No pudimos cargar canchas en este momento.';
    }

    return 'Ocurrió un error inesperado.';
  }
}
