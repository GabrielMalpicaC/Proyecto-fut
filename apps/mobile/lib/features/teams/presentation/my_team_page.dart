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
    final myUserId = profile['id']?.toString();
    final myRole = _findMyRole(team, myUserId);
    final isLeader = ownerId != null && ownerId == myUserId;
    final canManage = isLeader || myRole == 'CO_LEADER';
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
              child: (team['shieldUrl']?.toString().isNotEmpty ?? false)
                  ? null
                  : const Icon(Icons.shield),
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
          const SizedBox(height: 8),
          Text(
            'Estadísticas equipo · PJ ${team['matchesPlayed'] ?? 0} · G ${team['wins'] ?? 0} · E ${team['draws'] ?? 0} · P ${team['losses'] ?? 0} · GF ${team['goalsFor'] ?? 0} · GC ${team['goalsAgainst'] ?? 0}',
          ),
          const SizedBox(height: 12),
          Text('Jugadores (${members.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...members.map((raw) {
            final item = raw as Map<String, dynamic>;
            final user = (item['user'] as Map<String, dynamic>? ?? {});
            return Card(
              child: ListTile(
                onTap: () => _openPlayerDetail(context, team, item, canManage, isLeader),
                leading: CircleAvatar(
                  backgroundImage: (user['avatarUrl']?.toString().isNotEmpty ?? false)
                      ? NetworkImage(user['avatarUrl'].toString())
                      : null,
                  child: (user['avatarUrl']?.toString().isNotEmpty ?? false)
                      ? null
                      : const Icon(Icons.person),
                ),
                title: Text(user['fullName']?.toString() ?? 'Jugador'),
                subtitle: Text(
                  'Rol: ${item['role'] ?? 'MEMBER'} · Goles ${item['goals'] ?? 0} · Asist ${item['assists'] ?? 0}',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          })
        ],
      ),
    );
  }

  String? _findMyRole(Map<String, dynamic> team, String? myUserId) {
    if (myUserId == null) return null;
    final members = team['members'] as List<dynamic>? ?? [];
    for (final raw in members) {
      final item = raw as Map<String, dynamic>;
      if (item['user']?['id']?.toString() == myUserId) return item['role']?.toString();
    }
    return null;
  }

  Future<void> _openPlayerDetail(
    BuildContext context,
    Map<String, dynamic> team,
    Map<String, dynamic> member,
    bool canManage,
    bool isLeader,
  ) async {
    final user = member['user'] as Map<String, dynamic>? ?? {};
    final userId = user['id']?.toString() ?? '';
    if (userId.isEmpty) return;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['fullName']?.toString() ?? 'Jugador', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Rol: ${member['role'] ?? 'MEMBER'}'),
            Text('PJ: ${member['matchesPlayed'] ?? 0}'),
            Text('Goles: ${member['goals'] ?? 0} · Asistencias: ${member['assists'] ?? 0}'),
            Text('Amarillas: ${member['yellowCards'] ?? 0} · Rojas: ${member['redCards'] ?? 0}'),
            Text('Arcos en cero: ${member['cleanSheets'] ?? 0}'),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => _goToPlayerProfile(context, userId),
              child: const Text('Ver perfil del jugador'),
            ),
            if (isLeader) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _setRole(context, team['id'].toString(), userId, 'CAPTAIN'),
                    child: const Text('Hacer capitán'),
                  ),
                  OutlinedButton(
                    onPressed: () => _setRole(context, team['id'].toString(), userId, 'CO_LEADER'),
                    child: const Text('Hacer colíder'),
                  ),
                  OutlinedButton(
                    onPressed: () => _setRole(context, team['id'].toString(), userId, 'MEMBER'),
                    child: const Text('Quitar cargos'),
                  ),
                ],
              ),
            ],
            if (canManage && member['role']?.toString() != 'LEADER') ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _kickMember(context, team['id'].toString(), userId),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Expulsar jugador'),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _goToPlayerProfile(BuildContext context, String userId) async {
    try {
      await context.read<TeamsController>().loadPlayerProfile(userId);
      if (!context.mounted) return;
      final player = context.read<TeamsController>().selectedPlayerProfile ?? {};
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(player['fullName']?.toString() ?? 'Perfil jugador'),
          content: Text(player['bio']?.toString() ?? 'Sin biografía'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      showMessage(context, e.toString(), error: true);
    }
  }

  Future<void> _setRole(BuildContext context, String teamId, String userId, String role) async {
    try {
      await context.read<TeamsController>().setMemberRole(
            teamId: teamId,
            memberUserId: userId,
            role: role,
          );
      await context.read<TeamsController>().loadMyTeam();
      if (!context.mounted) return;
      Navigator.pop(context);
      showMessage(context, 'Rol actualizado');
    } catch (e) {
      if (!context.mounted) return;
      showMessage(context, e.toString(), error: true);
    }
  }

  Future<void> _kickMember(BuildContext context, String teamId, String userId) async {
    try {
      await context.read<TeamsController>().kickMember(teamId: teamId, memberUserId: userId);
      await context.read<TeamsController>().loadMyTeam();
      if (!context.mounted) return;
      Navigator.pop(context);
      showMessage(context, 'Jugador expulsado');
    } catch (e) {
      if (!context.mounted) return;
      showMessage(context, e.toString(), error: true);
    }
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
