import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/auth/presentation/auth_controller.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/features/teams/presentation/teams_controller.dart';
import 'package:proyecto_fut_app/shared/models/api_error.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final _searchCtrl = TextEditingController();
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

    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = teamsCtrl.openTeams.where((raw) {
      final team = raw as Map<String, dynamic>;
      final name = team['name']?.toString().toLowerCase() ?? '';
      return query.isEmpty || name.contains(query);
    }).toList();

    return AppScaffold(
      title: 'Equipos',
      body: ListView(
        children: [
          _TopBanner(currentTeam: currentTeam, onCreate: () => _openCreateTeamSheet(context)),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar equipo...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(_searchCtrl.clear),
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Equipos abiertos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: teamsCtrl.loading ? null : () => context.read<TeamsController>().loadOpenTeams(),
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              )
            ],
          ),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No hay equipos disponibles con ese criterio.'),
            ),
          ...filtered.map((rawTeam) {
            final team = rawTeam as Map<String, dynamic>;
            final members = (team['members'] as List<dynamic>? ?? []).length;
            final maxPlayers = (team['maxPlayers'] as num?)?.toInt() ?? 0;
            final footballType = (team['footballType'] as num?)?.toInt() ?? 11;
            final shield = team['shieldUrl']?.toString();

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundImage: (shield?.isNotEmpty ?? false) ? NetworkImage(shield!) : null,
                  child: (shield?.isNotEmpty ?? false) ? null : const Icon(Icons.shield),
                ),
                title: Text(team['name']?.toString() ?? 'Equipo'),
                subtitle: Text(
                  'Líder: ${team['owner']?['fullName'] ?? 'N/D'}\n'
                  'Fútbol $footballType · Jugadores: $members/$maxPlayers',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'view') {
                      await _openTeamProfile(context, team['id'].toString());
                    }
                    if (value == 'apply') {
                      await _apply(context, team['id'].toString(), currentTeam != null);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'view', child: Text('Ver perfil')),
                    PopupMenuItem(value: 'apply', child: Text('Postularme')),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _apply(BuildContext context, String teamId, bool alreadyInTeam) async {
    if (alreadyInTeam) {
      showMessage(context, 'Ya perteneces a un equipo activo', error: true);
      return;
    }

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
          children: [
            const Text('Postularme al equipo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _applyMessage,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Mensaje (opcional)'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                try {
                  await context.read<TeamsController>().applyToTeam(
                        teamId: teamId,
                        message: _applyMessage.text.trim(),
                      );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _applyMessage.clear();
                  showMessage(context, 'Postulación enviada');
                } catch (e) {
                  if (!context.mounted) return;
                  showMessage(context, _toReadableError(e), error: true);
                }
              },
              child: const Text('Enviar postulación'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _openTeamProfile(BuildContext context, String teamId) async {
    try {
      await context.read<TeamsController>().loadTeamProfile(teamId);
      if (!context.mounted) return;
      final team = context.read<TeamsController>().selectedTeam ?? {};
      final members = (team['members'] as List<dynamic>? ?? []);
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          builder: (ctx, scrollCtrl) => Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollCtrl,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: (team['shieldUrl']?.toString().isNotEmpty ?? false)
                        ? NetworkImage(team['shieldUrl'].toString())
                        : null,
                    child: (team['shieldUrl']?.toString().isNotEmpty ?? false)
                        ? null
                        : const Icon(Icons.shield, size: 28),
                  ),
                  title: Text(team['name']?.toString() ?? 'Equipo'),
                  subtitle: Text('Líder: ${team['owner']?['fullName'] ?? 'N/D'}'),
                ),
                Text(team['description']?.toString() ?? 'Sin descripción'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: 'Fútbol ${team['footballType'] ?? '-'}'),
                    _InfoChip(label: 'Formación ${team['formation'] ?? '-'}'),
                    _InfoChip(label: 'Capacidad ${members.length}/${team['maxPlayers'] ?? '-'}'),
                    _InfoChip(label: 'Pendientes ${team['_count']?['applications'] ?? 0}'),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Plantilla del equipo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...members.map((raw) {
                  final item = raw as Map<String, dynamic>;
                  final user = (item['user'] as Map<String, dynamic>? ?? {});
                  final positions = (user['preferredPositions'] as List<dynamic>? ?? []).join(', ');
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (user['avatarUrl']?.toString().isNotEmpty ?? false)
                            ? NetworkImage(user['avatarUrl'].toString())
                            : null,
                        child: (user['avatarUrl']?.toString().isNotEmpty ?? false)
                            ? null
                            : const Icon(Icons.person),
                      ),
                      title: Text(user['fullName']?.toString() ?? 'Jugador'),
                      subtitle: Text('Rol: ${item['role'] ?? 'MEMBER'}\nPosiciones: ${positions.isEmpty ? 'N/D' : positions}'),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      showMessage(context, _toReadableError(e), error: true);
    }
  }

  Future<void> _openCreateTeamSheet(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final shieldCtrl = TextEditingController();
    final formationCtrl = TextEditingController(text: '4-4-2');
    int footballType = 11;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final maxPlayers = footballType * 2;
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Crear equipo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del equipo')),
                TextField(
                  controller: descriptionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: shieldCtrl,
                  decoration: const InputDecoration(labelText: 'URL del escudo (opcional)'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: footballType,
                  decoration: const InputDecoration(labelText: 'Tipo de fútbol'),
                  items: const [5, 6, 7, 8, 11]
                      .map((n) => DropdownMenuItem(value: n, child: Text('Fútbol $n')))
                      .toList(),
                  onChanged: (value) => setModalState(() => footballType = value ?? 11),
                ),
                TextField(
                  controller: formationCtrl,
                  decoration: const InputDecoration(labelText: 'Formación (opcional, ej: 4-4-2)'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Máximo de jugadores: $maxPlayers (doble de fútbol $footballType)'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await context.read<TeamsController>().createTeam(
                            name: nameCtrl.text.trim(),
                            footballType: footballType,
                            formation: formationCtrl.text.trim().isEmpty ? '4-4-2' : formationCtrl.text.trim(),
                            description: descriptionCtrl.text.trim(),
                            shieldUrl: shieldCtrl.text.trim(),
                          );
                      await context.read<ProfileController>().fetch();
                      await context.read<TeamsController>().loadOpenTeams();
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      showMessage(context, 'Equipo creado correctamente');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, _toReadableError(e), error: true);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Crear equipo'),
                )
              ],
            ),
          );
        },
      ),
    );
  }


  String _toReadableError(Object error) {
    if (error is DioException) {
      final base = error.error;
      if (base is ApiError) {
        if (base.code == 'UNAUTHORIZED') {
          if (mounted) {
            context.read<AuthController>().logout();
          }
        }
        return base.message;
      }

      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
      return 'No se pudo completar la operación.';
    }

    return 'Ocurrió un error inesperado.';
  }
}

class _TopBanner extends StatelessWidget {
  const _TopBanner({required this.currentTeam, required this.onCreate});

  final Map<String, dynamic>? currentTeam;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF0E3D59), Color(0xFF142850)]),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.groups, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTeam == null ? 'Eres agente libre' : 'Tu equipo: ${currentTeam!['name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currentTeam == null
                      ? 'Busca un equipo o crea uno nuevo'
                      : 'Rol actual: ${currentTeam!['role']}',
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onCreate,
            child: const Text('Crear equipo'),
          )
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }
}
