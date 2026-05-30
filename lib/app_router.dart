import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/app_user.dart';
// Vos imports de pages (login, home, etc.)
import 'presentation/home/home_page.dart';
import 'presentation/auth/login_page.dart';
// ... tous les autres imports que vous aviez dans nav.dart

/// Page sans transition (indispensable)
class NoTransitionPage<T> extends Page<T> {
  final Widget child;
  const NoTransitionPage({required this.child, super.key});

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute(builder: (context) => child, settings: this);
  }
}

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String thixMedia = '/thix-media';
  static const String adminMedia = '/admin/media';
  // ... toutes vos autres constantes
}

class AppRouter {
  static GoRouter create(AuthController auth, {Listenable? extraRefreshListenable}) {
    final refresh = extraRefreshListenable ?? auth;
    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: refresh,
      redirect: (context, state) {
        // Votre logique de redirection existante (authentification, rôles...)
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomePagePremium()),
        ),
        // ... toutes vos autres routes (login, dashboard, etc.)
        GoRoute(
          path: AppRoutes.thixMedia,
          name: 'thixMedia',
          pageBuilder: (context, state) => const NoTransitionPage(child: ThixMediaPage()),
        ),
        GoRoute(
          path: AppRoutes.adminMedia,
          name: 'adminMedia',
          pageBuilder: (context, state) => const NoTransitionPage(child: AdminMediaPage()),
        ),
      ],
    );
  }
}
