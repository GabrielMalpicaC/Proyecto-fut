import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/matches/presentation/matches_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchesController>().loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MatchesController>();

    return AppScaffold(
      title: 'Buscar partido',
      body: ListView(
        children: [
          const Text('Modo de juego', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'CASUAL', label: Text('Casual')),
              ButtonSegment(value: 'COMPETITIVE', label: Text('Competitivo')),
            ],
            selected: {controller.mode},
            onSelectionChanged: (value) => controller.setMode(value.first),
          ),
          const SizedBox(height: 12),
          if (controller.status == 'MATCH_FOUND' && controller.match != null)
            Card(
              child: ListTile(
                title: const Text('¡Partido encontrado!'),
                subtitle: Text(
                  '${controller.match!['homeTeam']?['name'] ?? '-'} vs ${controller.match!['awayTeam']?['name'] ?? '-'}',
                ),
              ),
            )
          else if (controller.status == 'SEARCHING')
            const ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Buscando rival...'),
              subtitle: Text('Te emparejaremos cuando otro equipo busque en el mismo modo.'),
            ),
          if (controller.error != null)
            Text(controller.error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: controller.loading
                ? null
                : () async {
                    await context.read<MatchesController>().search();
                    if (!context.mounted) return;
                    final status = context.read<MatchesController>().status;
                    if (status == 'MATCH_FOUND') {
                      showMessage(context, '¡Partido encontrado!');
                    } else {
                      showMessage(context, 'Buscando partido...');
                    }
                  },
            child: const Text('Buscar partido'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: controller.loading
                ? null
                : () async {
                    await context.read<MatchesController>().cancel();
                    if (!context.mounted) return;
                    showMessage(context, 'Búsqueda cancelada');
                  },
            child: const Text('Cancelar búsqueda'),
          )
        ],
      ),
    );
  }
}
