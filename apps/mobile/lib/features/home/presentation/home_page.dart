import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/features/auth/presentation/auth_controller.dart';
import 'package:proyecto_fut_app/features/bookings/presentation/bookings_page.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/features/matches/presentation/matches_page.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_page.dart';
import 'package:proyecto_fut_app/features/profile/presentation/referee_dashboard_page.dart';
import 'package:proyecto_fut_app/features/profile/presentation/venue_owner_dashboard_page.dart';
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
    final roles = ((profile['roles'] as List<dynamic>?) ?? []).map((e) => e.toString()).toList();
    final hasTeam = profile['currentTeam'] != null;
    final isVenueOwner = roles.contains('VENUE_OWNER');
    final isReferee = roles.contains('REFEREE');

    final pages = [
      const VenuesPage(),
      if (!isVenueOwner) const TeamsPage(),
      if (!isVenueOwner && hasTeam) const MyTeamPage(),
      if (!isVenueOwner) const MatchesPage(),
      if (isVenueOwner) const VenueOwnerDashboardPage(),
      if (isReferee) const RefereeDashboardPage(),
      BookingsPage(),
      const WalletPage(),
      const ProfilePage(),
    ];

    final destinations = [
      const NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'Canchas'),
      if (!isVenueOwner) const NavigationDestination(icon: Icon(Icons.groups), label: 'Equipos'),
      if (!isVenueOwner && hasTeam) const NavigationDestination(icon: Icon(Icons.shield), label: 'Mi equipo'),
      if (!isVenueOwner) const NavigationDestination(icon: Icon(Icons.sports), label: 'Partidos'),
      if (isVenueOwner) const NavigationDestination(icon: Icon(Icons.storefront), label: 'Mi lugar'),
      if (isReferee) const NavigationDestination(icon: Icon(Icons.rule), label: 'Arbitraje'),
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
