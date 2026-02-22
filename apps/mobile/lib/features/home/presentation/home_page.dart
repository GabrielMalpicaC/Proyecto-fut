import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/features/auth/presentation/auth_controller.dart';
import 'package:proyecto_fut_app/features/bookings/presentation/bookings_page.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_page.dart';
import 'package:proyecto_fut_app/features/teams/presentation/my_team_page.dart';
import 'package:proyecto_fut_app/features/teams/presentation/teams_page.dart';
import 'package:proyecto_fut_app/features/venues/presentation/venues_page.dart';
import 'package:proyecto_fut_app/features/wallet/presentation/wallet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProfileController>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;
    final hasTeam = profile['currentTeam'] != null;

    final pages = [
      const VenuesPage(),
      const TeamsPage(),
      if (hasTeam) const MyTeamPage(),
      BookingsPage(),
      const WalletPage(),
      const ProfilePage(),
    ];

    final destinations = [
      const NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Canchas'),
      const NavigationDestination(icon: Icon(Icons.groups), label: 'Equipos'),
      if (hasTeam) const NavigationDestination(icon: Icon(Icons.shield), label: 'Mi equipo'),
      const NavigationDestination(icon: Icon(Icons.event_available), label: 'Reservas'),
      const NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
      const NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Perfil'),
    ];

    if (index >= pages.length) {
      index = pages.length - 1;
    }

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: destinations,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<AuthController>().logout(),
        icon: const Icon(Icons.logout),
        label: const Text('Salir'),
      ),
    );
  }
}
