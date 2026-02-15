import 'package:flutter/material.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> _positions = const [
    'Arquero',
    'Defensa',
    'Lateral',
    'Volante',
    'Delantero',
  ];

  final Set<String> _selectedPositions = {'Delantero'};

  final List<Map<String, String>> _stories = [
    {'title': 'Entreno', 'emoji': '🔥'},
    {'title': 'Partido', 'emoji': '⚽'},
    {'title': 'Skills', 'emoji': '🎯'},
    {'title': 'Locker', 'emoji': '🧤'},
  ];

  final List<Map<String, String>> _posts = const [
    {
      'title': 'Golazo de volea',
      'meta': 'Hace 2 horas · Cancha Norte',
      'body': 'Hoy cerramos 5-3 y metí doblete. ¿Quién se suma a la revancha del jueves?'
    },
    {
      'title': 'Busco equipo mixto',
      'meta': 'Ayer · Zona Centro',
      'body': 'Juego de delantero o volante. Disponible martes y viernes después de las 7pm.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mi Perfil',
      body: ListView(
        children: [
          _ProfileHeader(selectedPositions: _selectedPositions),
          const SizedBox(height: 20),
          _SectionTitle(
            title: 'Historias',
            actionLabel: 'Subir',
            onAction: () => _showSoon('Subida de historias'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 102,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _stories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _StoryBubble(
                    title: 'Nueva',
                    emoji: '+',
                    highlighted: false,
                    onTap: () => _showSoon('Nueva historia'),
                  );
                }
                final story = _stories[index - 1];
                return _StoryBubble(
                  title: story['title']!,
                  emoji: story['emoji']!,
                  onTap: () => _showSoon('Vista de historia'),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(
            title: 'Historias destacadas',
            actionLabel: 'Editar',
            onAction: () => _showSoon('Historias destacadas'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _stories
                .map((story) => Chip(
                      avatar: Text(story['emoji']!),
                      label: Text(story['title']!),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Preferencias de juego'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _positions.map((position) {
              final isSelected = _selectedPositions.contains(position);
              return FilterChip(
                selected: isSelected,
                label: Text(position),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedPositions.add(position);
                    } else {
                      _selectedPositions.remove(position);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => _showSoon('Guardado de preferencias en backend'),
              icon: const Icon(Icons.save),
              label: const Text('Guardar preferencias'),
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(
            title: 'Mi muro',
            actionLabel: 'Publicar',
            onAction: () => _showSoon('Crear publicación'),
          ),
          const SizedBox(height: 12),
          ..._posts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PostCard(post: post),
            ),
          ),
        ],
      ),
    );
  }

  void _showSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature disponible en la próxima iteración.')),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.selectedPositions});

  final Set<String> selectedPositions;

  @override
  Widget build(BuildContext context) {
    final subtitle = selectedPositions.isEmpty ? 'Sin posiciones elegidas' : selectedPositions.join(' · ');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF161B2F), Color(0xFF1F2547)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1521412644187-c49fa049e84d?w=200&q=80'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Carlos Gómez', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('@carlo9fut', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF8FE3B1))),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subir foto de perfil próximamente'))),
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Seguidores', value: '2.3k'),
              _StatItem(label: 'Siguiendo', value: '512'),
              _StatItem(label: 'Partidos', value: '86'),
            ],
          )
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.title,
    required this.emoji,
    required this.onTap,
    this.highlighted = true,
  });

  final String title;
  final String emoji;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: highlighted
                  ? const LinearGradient(colors: [Color(0xFFFF4D67), Color(0xFF8A3FFC)])
                  : null,
              border: highlighted ? null : Border.all(color: const Color(0xFF2D335B)),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF131727)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final Map<String, String> post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(post['meta'] ?? '', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Text(post['body'] ?? ''),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.favorite_border, size: 18),
                SizedBox(width: 8),
                Text('132'),
                SizedBox(width: 16),
                Icon(Icons.mode_comment_outlined, size: 18),
                SizedBox(width: 8),
                Text('28'),
                Spacer(),
                Icon(Icons.ios_share_outlined, size: 18),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
