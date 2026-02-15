import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/venues/presentation/venues_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class VenuesPage extends StatefulWidget {
  const VenuesPage({super.key});

  @override
  State<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> {
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  final _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VenuesController>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<VenuesController>();

    return AppScaffold(
      title: 'Canchas',
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: _query, decoration: const InputDecoration(labelText: 'Buscar cancha'))),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => context.read<VenuesController>().fetch(query: _query.text.trim()),
                child: const Text('Buscar'),
              )
            ],
          ),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre cancha')),
          const SizedBox(height: 8),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Ubicación')),
          const SizedBox(height: 8),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Precio/hora'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              try {
                await context.read<VenuesController>().createVenue(
                      name: _name.text.trim(),
                      location: _location.text.trim(),
                      pricePerHour: double.parse(_price.text.trim()),
                    );
                if (!context.mounted) return;
                showMessage(context, 'Cancha creada');
              } catch (e) {
                if (!context.mounted) return;
                showMessage(context, e.toString(), error: true);
              }
            },
            child: const Text('Crear cancha'),
          ),
          const SizedBox(height: 16),
          const Text('Listado', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (ctrl.loading)
            const Center(child: CircularProgressIndicator())
          else if (ctrl.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ctrl.error!, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => context.read<VenuesController>().fetch(query: _query.text.trim()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          else
            ...ctrl.venues.map(
              (v) => Card(
                child: ListTile(
                  title: Text(v['name']?.toString() ?? '-'),
                  subtitle: Text('${v['location']} · ${v['pricePerHour']} /h'),
                  trailing: Text(v['id']?.toString().substring(0, 6) ?? ''),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
