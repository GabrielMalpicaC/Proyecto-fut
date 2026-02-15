import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/teams/presentation/teams_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class TeamsPage extends StatelessWidget {
  TeamsPage({super.key});

  final _teamName = TextEditingController();
  final _teamId = TextEditingController();
  final _inviteUserId = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TeamsController>();

    return AppScaffold(
      title: 'Equipos',
      body: ListView(
        children: [
          const Text('Crear equipo', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _teamName, decoration: const InputDecoration(labelText: 'Nombre del equipo')),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: ctrl.loading
                ? null
                : () async {
                    try {
                      await context.read<TeamsController>().createTeam(_teamName.text.trim());
                      if (!context.mounted) return;
                      showMessage(context, 'Equipo creado');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, e.toString(), error: true);
                    }
                  },
            child: const Text('Crear'),
          ),
          const Divider(height: 28),
          const Text('Invitar miembro', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _teamId, decoration: const InputDecoration(labelText: 'Team ID')),
          const SizedBox(height: 8),
          TextField(controller: _inviteUserId, decoration: const InputDecoration(labelText: 'User ID invitado')),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: ctrl.loading
                ? null
                : () async {
                    try {
                      await context.read<TeamsController>().inviteMember(
                            teamId: _teamId.text.trim(),
                            invitedUserId: _inviteUserId.text.trim(),
                          );
                      if (!context.mounted) return;
                      showMessage(context, 'Invitación enviada');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, e.toString(), error: true);
                    }
                  },
            child: const Text('Invitar'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: ctrl.loading
                ? null
                : () async {
                    try {
                      await context.read<TeamsController>().acceptInvite(_teamId.text.trim());
                      if (!context.mounted) return;
                      showMessage(context, 'Invitación aceptada');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, e.toString(), error: true);
                    }
                  },
            child: const Text('Aceptar invitación (teamId)'),
          ),
        ],
      ),
    );
  }
}
