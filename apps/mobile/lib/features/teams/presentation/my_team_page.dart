import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/features/teams/presentation/teams_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamsController>().loadMyTeam();
      context.read<ProfileController>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final teams = context.watch<TeamsController>();
    final profile = context.watch<ProfileController>().profile;
    final team = teams.myTeam;

    if (team == null || team.isEmpty) {
      return const AppScaffold(
        title: 'Mi equipo',
        body: Center(child: Text('Aún no perteneces a un equipo.')),
      );
    }

    final ownerId = team['owner']?['id']?.toString();
    final isLeader = ownerId != null && ownerId == profile['id']?.toString();
    final members = (team['members'] as List<dynamic>? ?? []);

    return AppScaffold(
      title: 'Mi equipo',
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: (team['shieldUrl']?.toString().isNotEmpty ?? false)
                  ? NetworkImage(team['shieldUrl'].toString())
                  : null,
              child: (team['shieldUrl']?.toString().isNotEmpty ?? false) ? null : const Icon(Icons.shield),
            ),
            title: Text(team['name']?.toString() ?? 'Equipo'),
            subtitle: Text('Formación: ${team['formation'] ?? '-'} · Fútbol ${team['footballType'] ?? '-'}'),
            trailing: isLeader
                ? IconButton(
                    onPressed: () => _editTeam(context, team),
                    icon: const Icon(Icons.edit),
                  )
                : null,
          ),
          Text(team['description']?.toString() ?? 'Sin descripción'),
          const SizedBox(height: 12),
          Text('Jugadores (${members.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...members.map((raw) {
            final item = raw as Map<String, dynamic>;
            final user = (item['user'] as Map<String, dynamic>? ?? {});
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: (user['avatarUrl']?.toString().isNotEmpty ?? false)
                      ? NetworkImage(user['avatarUrl'].toString())
                      : null,
                  child: (user['avatarUrl']?.toString().isNotEmpty ?? false) ? null : const Icon(Icons.person),
                ),
                title: Text(user['fullName']?.toString() ?? 'Jugador'),
                subtitle: Text('Rol: ${item['role'] ?? 'MEMBER'}'),
              ),
            );
          })
        ],
      ),
    );
  }

  Future<void> _editTeam(BuildContext context, Map<String, dynamic> team) async {
    final name = TextEditingController(text: team['name']?.toString() ?? '');
    final description = TextEditingController(text: team['description']?.toString() ?? '');
    final shield = TextEditingController(text: team['shieldUrl']?.toString() ?? '');
    final formation = TextEditingController(text: team['formation']?.toString() ?? '4-4-2');
    int footballType = (team['footballType'] as num?)?.toInt() ?? 11;
    bool recruiting = team['isRecruiting'] == true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Editar equipo', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: description, decoration: const InputDecoration(labelText: 'Descripción')),
              TextField(controller: shield, decoration: const InputDecoration(labelText: 'Escudo URL')),
              TextField(controller: formation, decoration: const InputDecoration(labelText: 'Formación')),
              DropdownButtonFormField<int>(
                value: footballType,
                decoration: const InputDecoration(labelText: 'Tipo fútbol'),
                items: const [5, 6, 7, 8, 11]
                    .map((n) => DropdownMenuItem(value: n, child: Text('Fútbol $n')))
                    .toList(),
                onChanged: (v) => setModal(() => footballType = v ?? 11),
              ),
              SwitchListTile(
                value: recruiting,
                title: const Text('Equipo abierto a reclutamiento'),
                onChanged: (v) => setModal(() => recruiting = v),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await context.read<TeamsController>().updateTeam(
                          teamId: team['id'].toString(),
                          name: name.text.trim(),
                          description: description.text.trim(),
                          shieldUrl: shield.text.trim(),
                          formation: formation.text.trim(),
                          footballType: footballType,
                          isRecruiting: recruiting,
                        );
                    await context.read<TeamsController>().loadMyTeam();
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    showMessage(context, 'Equipo actualizado');
                  } catch (e) {
                    if (!context.mounted) return;
                    showMessage(context, e.toString(), error: true);
                  }
                },
                child: const Text('Guardar cambios'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
