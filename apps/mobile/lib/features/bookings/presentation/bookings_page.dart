import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/bookings/presentation/bookings_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class BookingsPage extends StatelessWidget {
  BookingsPage({super.key});

  final _venueId = TextEditingController();
  final _bookingId = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<BookingsController>();

    return AppScaffold(
      title: 'Reservas',
      body: ListView(
        children: [
          TextField(controller: _venueId, decoration: const InputDecoration(labelText: 'Venue ID')),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: ctrl.loading
                ? null
                : () async {
                    try {
                      final now = DateTime.now().add(const Duration(hours: 1));
                      await context.read<BookingsController>().createBooking(
                            venueId: _venueId.text.trim(),
                            startsAt: now,
                            endsAt: now.add(const Duration(hours: 1)),
                          );
                      if (!context.mounted) return;
                      showMessage(context, 'Reserva creada');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, e.toString(), error: true);
                    }
                  },
            child: const Text('Crear reserva (1h)'),
          ),
          const Divider(height: 28),
          TextField(controller: _bookingId, decoration: const InputDecoration(labelText: 'Booking ID')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: ctrl.loading
                ? null
                : () async {
                    try {
                      await context.read<BookingsController>().finalizeBooking(_bookingId.text.trim());
                      if (!context.mounted) return;
                      showMessage(context, 'Reserva finalizada');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, e.toString(), error: true);
                    }
                  },
            child: const Text('Finalizar reserva'),
          ),
        ],
      ),
    );
  }
}
