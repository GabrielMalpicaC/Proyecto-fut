import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class RefereeDashboardPage extends StatelessWidget {
  const RefereeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final assignments = controller.refereeAssignments;

    return AppScaffold(
      title: 'Arbitraje',
      body: ListView(
        children: [
          FilledButton.tonal(
            onPressed: () => _submitVerification(context),
            child: const Text('Enviar documento de verificación'),
          ),
          const SizedBox(height: 12),
          const Text('Partidos asignados', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...assignments.map((raw) {
            final item = raw as Map<String, dynamic>;
            final match = item['match'] as Map<String, dynamic>? ?? {};
            return ListTile(
              title: Text(
                '${match['homeTeam']?['name'] ?? '-'} vs ${match['awayTeam']?['name'] ?? '-'}',
              ),
              subtitle: Text('Lugar: ${item['venueName'] ?? '-'} · Fecha: ${item['scheduledAt'] ?? '-'}'),
            );
          })
        ],
      ),
    );
  }

  Future<void> _submitVerification(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Documento árbitro'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'URL del documento'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await context.read<ProfileController>().submitRefereeVerification(controller.text.trim());
                if (!context.mounted) return;
                Navigator.pop(ctx);
                showMessage(context, 'Documento enviado para revisión');
              } catch (e) {
                if (!context.mounted) return;
                showMessage(context, e.toString(), error: true);
              }
            },
            child: const Text('Enviar'),
          )
        ],
      ),
    );
  }
}
