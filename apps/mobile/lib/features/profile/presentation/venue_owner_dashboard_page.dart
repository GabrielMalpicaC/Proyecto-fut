import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class VenueOwnerDashboardPage extends StatelessWidget {
  const VenueOwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final data = controller.venueOwnerProfile;

    return AppScaffold(
      title: 'Mi lugar',
      body: ListView(
        children: [
          ListTile(
            title: Text(data['venueName']?.toString() ?? 'Configura tu lugar'),
            subtitle: Text(data['address']?.toString() ?? 'Sin dirección'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openEdit(context, data),
            ),
          ),
          const SizedBox(height: 8),
          Text('Contacto: ${data['contactPhone'] ?? '-'}'),
          Text('Horarios: ${data['openingHours'] ?? '-'}'),
          const SizedBox(height: 12),
          const Text('Reservas (equipos)', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Próximamente: listado detallado por equipo, fecha y cancha.'),
        ],
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, Map<String, dynamic> current) async {
    final venueName = TextEditingController(text: current['venueName']?.toString() ?? '');
    final photo = TextEditingController(text: current['venuePhotoUrl']?.toString() ?? '');
    final bio = TextEditingController(text: current['bio']?.toString() ?? '');
    final address = TextEditingController(text: current['address']?.toString() ?? '');
    final phone = TextEditingController(text: current['contactPhone']?.toString() ?? '');
    final hours = TextEditingController(text: current['openingHours']?.toString() ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: venueName, decoration: const InputDecoration(labelText: 'Nombre del lugar')),
              TextField(controller: photo, decoration: const InputDecoration(labelText: 'Foto URL')),
              TextField(controller: bio, decoration: const InputDecoration(labelText: 'Biografía')),
              TextField(controller: address, decoration: const InputDecoration(labelText: 'Dirección')),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Contacto')),
              TextField(controller: hours, decoration: const InputDecoration(labelText: 'Horarios')),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () async {
                  try {
                    await context.read<ProfileController>().saveVenueOwnerProfile(
                          venueName: venueName.text.trim(),
                          venuePhotoUrl: photo.text.trim(),
                          bio: bio.text.trim(),
                          address: address.text.trim(),
                          contactPhone: phone.text.trim(),
                          openingHours: hours.text.trim(),
                          fields: [
                            {
                              'name': 'Cancha 1',
                              'rates': [
                                {'dayOfWeek': 1, 'startHour': 8, 'endHour': 18, 'price': 120.0},
                                {'dayOfWeek': 5, 'startHour': 18, 'endHour': 23, 'price': 180.0}
                              ]
                            }
                          ],
                        );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    showMessage(context, 'Perfil de lugar actualizado');
                  } catch (e) {
                    if (!context.mounted) return;
                    showMessage(context, e.toString(), error: true);
                  }
                },
                child: const Text('Guardar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
