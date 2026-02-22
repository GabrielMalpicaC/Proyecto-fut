import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/features/teams/presentation/teams_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final _teamName = TextEditingController();
  final _teamDescription = TextEditingController();
  final _maxPlayers = TextEditingController(text: '11');
  final _applyMessage = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamsController>().loadOpenTeams();
      context.read<ProfileController>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamsCtrl = context.watch<TeamsController>();
    final profileCtrl = context.watch<ProfileController>();
    final currentTeam = profileCtrl.profile['currentTeam'] as Map<String, dynamic>?;
    final isFreeAgent = profileCtrl.profile['isFreeAgent'] == true;

    return AppScaffold(
      title: 'Equipos',
      body: ListView(
        children: [
          if (currentTeam != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.shield),
                title: Text('Tu equipo: ${currentTeam['name']}'),
                subtitle: Text('Rol: ${currentTeam['role']}'),
              ),
            ),
          if (currentTeam == null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Estado: Agente libre'),
                subtitle: Text(isFreeAgent ? 'Puedes postularte a equipos abiertos' : 'Sin equipo actual'),
              ),
            ),
          const SizedBox(height: 12),
          const Text('Crear equipo', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _teamName, decoration: const InputDecoration(labelText: 'Nombre del equipo')),
          TextField(
            controller: _teamDescription,
            decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
          ),
          TextField(
            controller: _maxPlayers,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Máximo de jugadores (5-20)'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: teamsCtrl.loading
                ? null
                : () async {
                    try {
                      await context.read<TeamsController>().createTeam(
                            name: _teamName.text.trim(),
                            maxPlayers: int.tryParse(_maxPlayers.text.trim()) ?? 11,
                            description: _teamDescription.text.trim(),
                          );
                      await context.read<ProfileController>().fetch();
                      if (!context.mounted) return;
                      showMessage(context, 'Equipo creado');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, e.toString(), error: true);
                    }
                  },
            child: const Text('Crear equipo'),
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Equipos con vacantes', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: teamsCtrl.loading ? null : () => context.read<TeamsController>().loadOpenTeams(),
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
          if (teamsCtrl.openTeams.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No hay equipos abiertos por ahora.'),
            ),
          ...teamsCtrl.openTeams.map((rawTeam) {
            final team = rawTeam as Map<String, dynamic>;
            final members = (team['members'] as List<dynamic>? ?? []).length;
            final maxPlayers = team['maxPlayers'] ?? '-';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team['name']?.toString() ?? 'Equipo', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Líder: ${team['owner']?['fullName'] ?? 'N/D'}'),
                    Text('Jugadores: $members / $maxPlayers'),
                    if ((team['description']?.toString().isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(team['description'].toString()),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _applyMessage,
                      decoration: const InputDecoration(labelText: 'Mensaje de postulación (opcional)'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: teamsCtrl.loading
                              ? null
                              : () async {
                                  try {
                                    await context.read<TeamsController>().loadTeamProfile(team['id'].toString());
                                    if (!context.mounted) return;
                                    final selected = context.read<TeamsController>().selectedTeam ?? {};
                                    await showDialog<void>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(selected['name']?.toString() ?? 'Equipo'),
                                        content: Text(
                                          'Líder: ${selected['owner']?['fullName'] ?? 'N/D'}\n'
                                          'Capacidad: ${selected['members']?.length ?? 0}/${selected['maxPlayers'] ?? '-'}\n'
                                          'Postulaciones pendientes: ${selected['_count']?['applications'] ?? 0}\n\n'
                                          '${selected['description'] ?? ''}',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    showMessage(context, e.toString(), error: true);
                                  }
                                },
                          child: const Text('Ver perfil'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: teamsCtrl.loading || currentTeam != null
                              ? null
                              : () async {
                                  try {
                                    await context.read<TeamsController>().applyToTeam(
                                          teamId: team['id'].toString(),
                                          message: _applyMessage.text.trim(),
                                        );
                                    if (!context.mounted) return;
                                    showMessage(context, 'Postulación enviada');
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    showMessage(context, e.toString(), error: true);
                                  }
                                },
                          child: const Text('Postularme'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
