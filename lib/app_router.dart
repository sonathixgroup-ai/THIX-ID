import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/app_user.dart';

// Pages principales
import 'presentation/home/home_page.dart';          // contient HomePagePremium ?
import 'presentation/auth/login_page.dart';

// Pages Events
import 'package:thix_id/presentation/events/events_page.dart';
import 'package:thix_id/presentation/events/event_details_page.dart';
import 'package:thix_id/presentation/events/event_register_page.dart';
import 'package:thix_id/presentation/events/event_ticket_page.dart';
import 'package:thix_id/presentation/events/event_checkout_page.dart';
import 'package:thix_id/presentation/events/user_event_dashboard_page.dart';

// Pages Media (chemins corrigés)
import 'package:thix_id/presentation/thix_media/thix_media_page.dart';
import 'package:thix_id/presentation/admin/pages/admin_media_page.dart';

// ============================================================================
// Page avec transition Material (selon votre demande)
// ============================================================================
class NoTransitionPage<T> extends Page<T> {
  final Widget child;

  const NoTransitionPage({
    required this.child,
    super.key,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute<T>(
      builder: (_) => child,
      settings: this,
    );
  }
}

// ============================================================================
// Constantes de routes
// ============================================================================
class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String thixMedia = '/thix-media';
  static const String adminMedia = '/admin/media';
  static const String events = '/events';
  static const String userEventsDashboard = '/events/me';

  static String eventDetails(String eventId) => '/events/$eventId';
  static String eventRegister(String eventId) => '/events/$eventId/register';
  static String eventCheckout(String eventId) => '/events/$eventId/checkout';
  static String eventTicket(String eventId, String registrationId) =>
      '/events/$eventId/ticket/$registrationId';
}

// ============================================================================
// Routeur principal
// ============================================================================
class AppRouter {
  static GoRouter create(AuthController auth, {Listenable? extraRefreshListenable}) {
    final refresh = extraRefreshListenable ?? auth;

    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: refresh,
      redirect: (context, state) {
        // Exemple de logique de redirection (à adapter)
        // final isLogged = auth.currentUser != null;
        // final isLoginRoute = state.matchedLocation == AppRoutes.login;
        //
        // if (!isLogged && !isLoginRoute) return AppRoutes.login;
        // if (isLogged && isLoginRoute) return AppRoutes.home;

        return null; // Pas de redirection par défaut
      },
      routes: [
        // ---------- Accueil (avec HomePagePremium) ----------
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePagePremium()),
        ),

        // ---------- Authentification ----------
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LoginPage()),
        ),

        // ---------- Événements ----------
        GoRoute(
          path: AppRoutes.events,
          name: 'events',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: EventsPage()),
        ),

        // ⚠️ Route fixe AVANT la route dynamique
        GoRoute(
          path: AppRoutes.userEventsDashboard,
          name: 'userEventsDashboard',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: UserEventDashboardPage()),
        ),

        // Route dynamique : /events/:eventId
        GoRoute(
          path: '/events/:eventId',
          name: 'eventDetails',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            final registered = (state.uri.queryParameters['registered'] ?? '') == '1';
            return NoTransitionPage(
              child: EventDetailsPage(
                eventId: eventId,
                registered: registered,
              ),
            );
          },
        ),

        // /events/:eventId/register
        GoRoute(
          path: '/events/:eventId/register',
          name: 'eventRegister',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            return NoTransitionPage(
              child: EventRegisterPage(eventId: eventId),
            );
          },
        ),

        // /events/:eventId/checkout
        GoRoute(
          path: '/events/:eventId/checkout',
          name: 'eventCheckout',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            return NoTransitionPage(
              child: EventCheckoutPage(eventId: eventId), // constructeur vérifié
            );
          },
        ),

        // /events/:eventId/ticket/:registrationId
        GoRoute(
          path: '/events/:eventId/ticket/:registrationId',
          name: 'eventTicket',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            final registrationId = state.pathParameters['registrationId'] ?? '';
            return NoTransitionPage(
              child: EventTicketPage(
                eventId: eventId,
                registrationId: registrationId,
              ),
            );
          },
        ),

        // ---------- Médias ----------
        GoRoute(
          path: AppRoutes.thixMedia,
          name: 'thixMedia',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ThixMediaPage()),
        ),
        GoRoute(
          path: AppRoutes.adminMedia,
          name: 'adminMedia',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AdminMediaPage()),
        ),
      ],
    );
  }
}

// ============================================================================
// Extension utilitaire pour la navigation (pop ou go)
// ============================================================================
extension GoRouterBackHelpers on BuildContext {
  void popOrGo(String fallbackLocation) {
    final router = GoRouter.of(this);

    if (router.canPop()) {
      pop();
      return;
    }

    go(fallbackLocation);
  }
}
