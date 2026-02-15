import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _positions = const ['Arquero', 'Defensa', 'Lateral', 'Volante', 'Delantero'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProfileController>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProfileController>();
    final profile = ctrl.profile;
    final avatarUrl = profile['avatarUrl']?.toString();
    final selectedPositions = ctrl.preferredPositions.toSet();

    return AppScaffold(
      title: 'Perfil',
      body: ctrl.loading && profile.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF11162A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null || avatarUrl.isEmpty ? const Icon(Icons.person, size: 32) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['fullName']?.toString() ?? 'Jugador',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(profile['bio']?.toString() ?? 'Completa tu bio para conectar con más jugadores'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: selectedPositions.map((p) => Chip(label: Text(p))).toList(),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openEditProfile(context, ctrl),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar perfil'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openCreateStory(context, ctrl),
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Subir historia'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openCreatePost(context, ctrl),
                      icon: const Icon(Icons.post_add_outlined),
                      label: const Text('Publicar'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text('Historias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 102,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ctrl.stories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final story = ctrl.stories[index] as Map<String, dynamic>;
                      final highlighted = story['isHighlighted'] == true;
                      return _StoryCircle(
                        url: story['mediaUrl']?.toString() ?? '',
                        label: (story['caption']?.toString().isNotEmpty ?? false)
                            ? story['caption'].toString()
                            : 'Story ${index + 1}',
                        highlighted: highlighted,
                        onLongPress: () async {
                          await ctrl.setStoryHighlight(
                            storyId: story['id'].toString(),
                            isHighlighted: !highlighted,
                          );
                          if (!context.mounted) return;
                          showMessage(context, !highlighted ? 'Historia destacada' : 'Historia removida de destacadas');
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Historias destacadas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ctrl.highlightedStories
                      .map((s) => Chip(label: Text((s as Map<String, dynamic>)['caption']?.toString() ?? 'Destacada')))
                      .toList(),
                ),
                const SizedBox(height: 18),
                const Text('Preferencias para jugar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _positions
                      .map(
                        (position) => FilterChip(
                          selected: selectedPositions.contains(position),
                          label: Text(position),
                          onSelected: (_) async {
                            final next = selectedPositions.toSet();
                            if (next.contains(position)) {
                              next.remove(position);
                            } else {
                              next.add(position);
                            }
                            await ctrl.updateProfile(preferredPositions: next.toList());
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                const Text('Publicaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: ctrl.posts.length,
                  itemBuilder: (_, index) {
                    final post = ctrl.posts[index] as Map<String, dynamic>;
                    final imageUrl = post['imageUrl']?.toString();
                    return GestureDetector(
                      onTap: () => _showPost(context, post),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF171E38),
                          image: imageUrl != null && imageUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                              : null,
                        ),
                        child: imageUrl == null || imageUrl.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    post['content']?.toString() ?? '',
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                )
              ],
            ),
    );
  }

  Future<void> _openEditProfile(BuildContext context, ProfileController ctrl) async {
    final current = ctrl.profile;
    final nameCtrl = TextEditingController(text: current['fullName']?.toString() ?? '');
    final bioCtrl = TextEditingController(text: current['bio']?.toString() ?? '');
    final avatarCtrl = TextEditingController(text: current['avatarUrl']?.toString() ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
            const SizedBox(height: 8),
            TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio')),
            const SizedBox(height: 8),
            TextField(controller: avatarCtrl, decoration: const InputDecoration(labelText: 'URL foto de perfil')),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                await ctrl.updateProfile(
                  fullName: nameCtrl.text.trim(),
                  bio: bioCtrl.text.trim(),
                  avatarUrl: avatarCtrl.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateStory(BuildContext context, ProfileController ctrl) async {
    final mediaCtrl = TextEditingController();
    final captionCtrl = TextEditingController();
    bool isHighlighted = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva historia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: mediaCtrl, decoration: const InputDecoration(labelText: 'URL de imagen')),
              const SizedBox(height: 8),
              TextField(controller: captionCtrl, decoration: const InputDecoration(labelText: 'Texto corto')),
              CheckboxListTile(
                value: isHighlighted,
                onChanged: (v) => setState(() => isHighlighted = v ?? false),
                title: const Text('Marcar como destacada'),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                await ctrl.createStory(
                  mediaUrl: mediaCtrl.text.trim(),
                  caption: captionCtrl.text.trim().isEmpty ? null : captionCtrl.text.trim(),
                  isHighlighted: isHighlighted,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Publicar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _openCreatePost(BuildContext context, ProfileController ctrl) async {
    final contentCtrl = TextEditingController();
    final imageCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva publicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Contenido')),
            const SizedBox(height: 8),
            TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL imagen (opcional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await ctrl.createPost(
                content: contentCtrl.text.trim(),
                imageUrl: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Publicar'),
          )
        ],
      ),
    );
  }

  void _showPost(BuildContext context, Map<String, dynamic> post) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((post['imageUrl']?.toString().isNotEmpty ?? false))
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(post['imageUrl'].toString(), height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),
            Text(post['content']?.toString() ?? ''),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  const _StoryCircle({required this.url, required this.label, required this.highlighted, required this.onLongPress});

  final String url;
  final String label;
  final bool highlighted;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: highlighted ? const [Color(0xFF78FFB1), Color(0xFF32C4FF)] : const [Color(0xFFFF4D67), Color(0xFF8A3FFC)],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F1324)),
              child: ClipOval(
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 80,
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }
}
