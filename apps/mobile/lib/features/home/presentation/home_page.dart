import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/features/auth/presentation/auth_controller.dart';
import 'package:proyecto_fut_app/features/bookings/presentation/bookings_page.dart';
import 'package:proyecto_fut_app/features/teams/presentation/teams_page.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_page.dart';
import 'package:proyecto_fut_app/features/venues/presentation/venues_page.dart';
import 'package:proyecto_fut_app/features/wallet/presentation/wallet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  late final pages = [
    const VenuesPage(),
    TeamsPage(),
    BookingsPage(),
    const WalletPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Canchas'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Equipos'),
          NavigationDestination(icon: Icon(Icons.event_available), label: 'Reservas'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<AuthController>().logout(),
        icon: const Icon(Icons.logout),
        label: const Text('Salir'),
      ),
    );
  }
}
