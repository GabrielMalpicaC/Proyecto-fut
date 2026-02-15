import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/features/venues/data/venues_repository.dart';

class VenuesController extends ChangeNotifier {
  VenuesController(this._repository);

  final VenuesRepository _repository;
  bool loading = false;
  List<Map<String, dynamic>> venues = [];

  Future<void> fetch({String? query}) async {
    loading = true;
    notifyListeners();
    try {
      venues = await _repository.listVenues(query: query);
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
    await _repository.createVenue(name: name, location: location, pricePerHour: pricePerHour);
    await fetch();
  }
}
