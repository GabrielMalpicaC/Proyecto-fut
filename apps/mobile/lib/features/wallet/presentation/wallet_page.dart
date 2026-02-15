import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/widgets/app_scaffold.dart';
import 'package:proyecto_fut_app/features/wallet/presentation/wallet_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _amount = TextEditingController(text: '100');
  final _holdId = TextEditingController();
  final _ownerUserId = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WalletController>().fetchBalance());
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WalletController>();

    return AppScaffold(
      title: 'Wallet & Ledger',
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: const Text('Saldo actual'),
              subtitle: Text('\$${ctrl.balance.toStringAsFixed(2)}'),
              trailing: IconButton(
                onPressed: () => context.read<WalletController>().fetchBalance(),
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(controller: _amount, decoration: const InputDecoration(labelText: 'Monto'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              try {
                await context.read<WalletController>().topUp(double.parse(_amount.text.trim()));
                if (!context.mounted) return;
                showMessage(context, 'Recarga aplicada');
              } catch (e) {
                if (!context.mounted) return;
                showMessage(context, e.toString(), error: true);
              }
            },
            child: const Text('Top-up (admin endpoint)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              try {
                await context.read<WalletController>().createHold(
                      amount: double.parse(_amount.text.trim()),
                      reason: 'Manual hold from app',
                      referenceId: 'manual-hold-${DateTime.now().millisecondsSinceEpoch}',
                    );
                if (!context.mounted) return;
                showMessage(context, 'Hold creado');
              } catch (e) {
                if (!context.mounted) return;
                showMessage(context, e.toString(), error: true);
              }
            },
            child: const Text('Crear hold'),
          ),
          const Divider(height: 28),
          TextField(controller: _holdId, decoration: const InputDecoration(labelText: 'Hold ID')),
          const SizedBox(height: 8),
          TextField(controller: _ownerUserId, decoration: const InputDecoration(labelText: 'Owner User ID (settle)')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await context.read<WalletController>().releaseHold(_holdId.text.trim());
                      if (!context.mounted) return;
                      showMessage(context, 'Hold liberado');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, e.toString(), error: true);
                    }
                  },
                  child: const Text('Release'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await context.read<WalletController>().settleHold(
                            holdId: _holdId.text.trim(),
                            ownerUserId: _ownerUserId.text.trim(),
                          );
                      if (!context.mounted) return;
                      showMessage(context, 'Hold liquidado');
                    } catch (e) {
                      if (!context.mounted) return;
                      showMessage(context, e.toString(), error: true);
                    }
                  },
                  child: const Text('Settle'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
