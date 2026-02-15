import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _picker = ImagePicker();

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
          : ctrl.error != null && profile.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('No pudimos cargar tu perfil', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(ctrl.error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () => ctrl.fetch(), child: const Text('Reintentar')),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    _HeaderCard(
                      avatarUrl: avatarUrl,
                      fullName: profile['fullName']?.toString() ?? 'Jugador',
                      bio: profile['bio']?.toString() ?? 'Completa tu bio para conectar con más jugadores',
                      positions: selectedPositions,
                      storiesCount: ctrl.stories.length,
                      postsCount: ctrl.posts.length,
                      highlightsCount: ctrl.highlightedStories.length,
                      onEdit: () => _openEditProfile(context, ctrl),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11162A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                            onPressed: () async {
                              try {
                                await _createStoryFromDevice(context, ctrl);
                              } catch (_) {
                                if (!context.mounted) return;
                                showMessage(context, ctrl.error ?? 'No pudimos crear la historia');
                              }
                            },
                              icon: const Icon(Icons.auto_stories),
                              label: const Text('Historia'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.tonalIcon(
                            onPressed: () async {
                              try {
                                await _createPostFromDevice(context, ctrl);
                              } catch (_) {
                                if (!context.mounted) return;
                                showMessage(context, ctrl.error ?? 'No pudimos crear la publicación');
                              }
                            },
                              icon: const Icon(Icons.add_box_outlined),
                              label: const Text('Publicar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Historias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 10),
                    if (ctrl.stories.isEmpty)
                      const Text('Todavía no tienes historias. Crea la primera 👆'),
                    if (ctrl.stories.isNotEmpty)
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
                              try {
                                await ctrl.setStoryHighlight(
                                  storyId: story['id'].toString(),
                                  isHighlighted: !highlighted,
                                );
                              } catch (_) {
                                if (!context.mounted) return;
                                showMessage(context, ctrl.error ?? 'No se pudo actualizar la historia');
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Posiciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _positions
                          .map(
                            (position) => FilterChip(
                              selected: selectedPositions.contains(position),
                              label: Text(position),
                              onSelected: (_) async {
                                try {
                                  final next = selectedPositions.toSet();
                                  next.contains(position) ? next.remove(position) : next.add(position);
                                  await ctrl.updateProfile(preferredPositions: next.toList());
                                } catch (_) {
                                  if (!context.mounted) return;
                                  showMessage(context, ctrl.error ?? 'No se pudo actualizar tus posiciones');
                                }
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    const Text('Mis publicaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 10),
                    if (ctrl.posts.isEmpty)
                      const Text('Aún no publicaste nada.'),
                    if (ctrl.posts.isNotEmpty) _PostsGrid(posts: ctrl.posts),
                    const SizedBox(height: 18),
                    const Text('Muro de la comunidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 10),
                    if (ctrl.feed.isEmpty)
                      const Text('Todavía no hay publicaciones en la comunidad.'),
                    ...ctrl.feed.map((item) {
                      final post = item as Map<String, dynamic>;
                      final user = (post['user'] as Map<String, dynamic>?) ?? {};
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: (user['avatarUrl']?.toString().isNotEmpty ?? false)
                                        ? NetworkImage(user['avatarUrl'].toString())
                                        : null,
                                    child: (user['avatarUrl']?.toString().isNotEmpty ?? false)
                                        ? null
                                        : const Icon(Icons.person, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(user['fullName']?.toString() ?? 'Jugador'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (post['imageUrl']?.toString().isNotEmpty ?? false)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    post['imageUrl'].toString(),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(post['content']?.toString() ?? ''),
                              const SizedBox(height: 10),
                              const Row(
                                children: [
                                  Icon(Icons.favorite_border, size: 18),
                                  SizedBox(width: 6),
                                  Text('Me gusta'),
                                  SizedBox(width: 16),
                                  Icon(Icons.mode_comment_outlined, size: 18),
                                  SizedBox(width: 6),
                                  Text('Comentar'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }

  Future<void> _openEditProfile(BuildContext context, ProfileController ctrl) async {
    final current = ctrl.profile;
    final nameCtrl = TextEditingController(text: current['fullName']?.toString() ?? '');
    final bioCtrl = TextEditingController(text: current['bio']?.toString() ?? '');

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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (file == null) return;
                        final mediaUrl = await ctrl.uploadMedia(file);
                        await ctrl.updateProfile(
                          fullName: nameCtrl.text.trim(),
                          bio: bioCtrl.text.trim(),
                          avatarUrl: mediaUrl,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } catch (_) {
                        if (!context.mounted) return;
                        showMessage(context, ctrl.error ?? 'No se pudo actualizar la foto de perfil');
                      }
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Subir foto'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if (file == null) return;
                        final mediaUrl = await ctrl.uploadMedia(file);
                        await ctrl.updateProfile(
                          fullName: nameCtrl.text.trim(),
                          bio: bioCtrl.text.trim(),
                          avatarUrl: mediaUrl,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } catch (_) {
                        if (!context.mounted) return;
                        showMessage(context, ctrl.error ?? 'No se pudo actualizar la foto de perfil');
                      }
                    },
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Tomar foto'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () async {
                try {
                  await ctrl.updateProfile(
                    fullName: nameCtrl.text.trim(),
                    bio: bioCtrl.text.trim(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (_) {
                  if (!context.mounted) return;
                  showMessage(context, ctrl.error ?? 'No se pudo actualizar el perfil');
                }
              },
              child: const Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _createStoryFromDevice(BuildContext context, ProfileController ctrl) async {
    final captionCtrl = TextEditingController();
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva historia'),
        content: TextField(controller: captionCtrl, decoration: const InputDecoration(labelText: 'Texto corto')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                final mediaUrl = await ctrl.uploadMedia(file);
                await ctrl.createStory(
                  mediaUrl: mediaUrl,
                  caption: captionCtrl.text.trim().isEmpty ? null : captionCtrl.text.trim(),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                showMessage(context, 'Historia publicada');
              } catch (_) {
                if (!context.mounted) return;
                showMessage(context, ctrl.error ?? 'No se pudo publicar la historia');
              }
            },
            child: const Text('Publicar'),
          )
        ],
      ),
    );
  }

  Future<void> _createPostFromDevice(BuildContext context, ProfileController ctrl) async {
    final contentCtrl = TextEditingController();
    XFile? selected;

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva publicación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: '¿Qué estás pensando?')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        setState(() => selected = image);
                      },
                      child: const Text('Galería'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        setState(() => selected = image);
                      },
                      child: const Text('Cámara'),
                    ),
                  ),
                ],
              ),
              if (selected != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Imagen seleccionada: ${selected!.name}', style: Theme.of(context).textTheme.bodySmall),
                )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final content = contentCtrl.text.trim();
                if (content.isEmpty) {
                  showMessage(context, 'Escribe algo para publicar');
                  return;
                }

                try {
                  String? mediaUrl;
                  if (selected != null) {
                    mediaUrl = await ctrl.uploadMedia(selected!);
                  }
                  await ctrl.createPost(
                    content: content,
                    imageUrl: mediaUrl,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  showMessage(context, 'Publicación creada');
                } catch (_) {
                  if (!context.mounted) return;
                  showMessage(context, ctrl.error ?? 'No se pudo crear la publicación');
                }
              },
              child: const Text('Publicar'),
            )
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.avatarUrl,
    required this.fullName,
    required this.bio,
    required this.positions,
    required this.storiesCount,
    required this.postsCount,
    required this.highlightsCount,
    required this.onEdit,
  });

  final String? avatarUrl;
  final String fullName;
  final String bio;
  final Set<String> positions;
  final int storiesCount;
  final int postsCount;
  final int highlightsCount;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2140), Color(0xFF2B145E)],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white12,
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null || avatarUrl!.isEmpty ? const Icon(Icons.person, size: 34) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(bio, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit))
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatPill(label: 'Publicaciones', value: postsCount.toString()),
              _StatPill(label: 'Historias', value: storiesCount.toString()),
              _StatPill(label: 'Destacadas', value: highlightsCount.toString()),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: positions.map((p) => Chip(label: Text(p))).toList()),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
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
          SizedBox(width: 80, child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center))
        ],
      ),
    );
  }
}

class _PostsGrid extends StatelessWidget {
  const _PostsGrid({required this.posts});

  final List<dynamic> posts;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (_, index) {
        final post = posts[index] as Map<String, dynamic>;
        final imageUrl = post['imageUrl']?.toString();
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF171E38),
            image: imageUrl != null && imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
          ),
          child: imageUrl == null || imageUrl.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(post['content']?.toString() ?? '', maxLines: 4, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ),
                )
              : null,
        );
      },
    );
  }
}
