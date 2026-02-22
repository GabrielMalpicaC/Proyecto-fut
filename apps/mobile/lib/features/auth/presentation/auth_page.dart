import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/features/auth/presentation/auth_controller.dart';
import 'package:proyecto_fut_app/shared/utils/snackbar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  bool registerMode = false;
  String selectedRole = 'PLAYER';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF16A34A), Color(0xFF22C55E), Color(0xFF86EFAC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚽ Proyecto Fut', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (registerMode) ...[
                      TextField(controller: _fullName, decoration: const InputDecoration(labelText: 'Nombre completo')),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: '¿Qué vas a ser?'),
                        items: const [
                          DropdownMenuItem(value: 'PLAYER', child: Text('Jugador')),
                          DropdownMenuItem(value: 'VENUE_OWNER', child: Text('Propietario de cancha')),
                          DropdownMenuItem(value: 'REFEREE', child: Text('Árbitro')),
                        ],
                        onChanged: (value) => setState(() => selectedRole = value ?? 'PLAYER'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(controller: _email, decoration: const InputDecoration(labelText: 'Correo')),
                    const SizedBox(height: 12),
                    TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              try {
                                if (registerMode) {
                                  await context.read<AuthController>().register(_email.text.trim(), _fullName.text.trim(), _password.text.trim(), selectedRole);
                                } else {
                                  await context.read<AuthController>().login(_email.text.trim(), _password.text.trim());
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                showMessage(context, e.toString(), error: true);
                              }
                            },
                      child: Text(registerMode ? 'Crear cuenta' : 'Ingresar'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => registerMode = !registerMode),
                      child: Text(registerMode ? 'Ya tengo cuenta' : 'No tengo cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
