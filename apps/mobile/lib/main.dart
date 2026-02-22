import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_fut_app/core/network/api_client.dart';
import 'package:proyecto_fut_app/core/storage/token_storage.dart';
import 'package:proyecto_fut_app/core/theme/app_theme.dart';
import 'package:proyecto_fut_app/features/auth/data/auth_repository.dart';
import 'package:proyecto_fut_app/features/auth/presentation/auth_controller.dart';
import 'package:proyecto_fut_app/features/auth/presentation/auth_page.dart';
import 'package:proyecto_fut_app/features/bookings/data/bookings_repository.dart';
import 'package:proyecto_fut_app/features/bookings/presentation/bookings_controller.dart';
import 'package:proyecto_fut_app/features/home/presentation/home_page.dart';
import 'package:proyecto_fut_app/features/matches/data/matches_repository.dart';
import 'package:proyecto_fut_app/features/matches/presentation/matches_controller.dart';
import 'package:proyecto_fut_app/features/profile/data/profile_repository.dart';
import 'package:proyecto_fut_app/features/profile/presentation/profile_controller.dart';
import 'package:proyecto_fut_app/features/teams/data/teams_repository.dart';
import 'package:proyecto_fut_app/features/teams/presentation/teams_controller.dart';
import 'package:proyecto_fut_app/features/venues/data/venues_repository.dart';
import 'package:proyecto_fut_app/features/venues/presentation/venues_controller.dart';
import 'package:proyecto_fut_app/features/wallet/data/wallet_repository.dart';
import 'package:proyecto_fut_app/features/wallet/presentation/wallet_controller.dart';

void main() {
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: tokenStorage),
        Provider.value(value: apiClient),
        Provider(create: (_) => AuthRepository(apiClient, tokenStorage)),
        Provider(create: (_) => TeamsRepository(apiClient)),
        Provider(create: (_) => VenuesRepository(apiClient)),
        Provider(create: (_) => BookingsRepository(apiClient)),
        Provider(create: (_) => WalletRepository(apiClient)),
        Provider(create: (_) => ProfileRepository(apiClient)),
        Provider(create: (_) => MatchesRepository(apiClient)),
        ChangeNotifierProvider(create: (ctx) => AuthController(ctx.read<AuthRepository>())..bootstrap()),
        ChangeNotifierProvider(create: (ctx) => TeamsController(ctx.read<TeamsRepository>())),
        ChangeNotifierProvider(create: (ctx) => VenuesController(ctx.read<VenuesRepository>())),
        ChangeNotifierProvider(create: (ctx) => BookingsController(ctx.read<BookingsRepository>())),
        ChangeNotifierProvider(create: (ctx) => WalletController(ctx.read<WalletRepository>())),
        ChangeNotifierProvider(create: (ctx) => ProfileController(ctx.read<ProfileRepository>())),
        ChangeNotifierProvider(create: (ctx) => MatchesController(ctx.read<MatchesRepository>())),
      ],
      child: const ProyectoFutApp(),
    ),
  );
}

class ProyectoFutApp extends StatelessWidget {
  const ProyectoFutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return MaterialApp(
      title: 'Proyecto Fut',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: auth.isAuthenticated ? const HomePage() : const AuthPage(),
    );
  }
}
