// ============================================================================
// FICHIER: lib/nav.dart
// Routes et navigation pour THIX ID
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/app_user.dart';

// ============================================================================
// IMPORTS DES PAGES
// ============================================================================
import 'presentation/home/home_page.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/auth/personal_registration_page.dart';
import 'presentation/auth/enterprise_registration_page.dart';
import 'presentation/dashboard/user_dashboard_page.dart';
import 'presentation/enterprise/enterprise_dashboard_page.dart';
import 'presentation/events/events_page.dart';
import 'presentation/events/event_details_page.dart';
import 'presentation/events/event_register_page.dart';
import 'presentation/events/event_ticket_page.dart';
import 'presentation/events/user_event_dashboard_page.dart';
import 'presentation/profile/public_profile_page.dart';
import 'presentation/payment/payment_gateway_page.dart';
import 'presentation/payment/activation_receipt_page.dart';
import 'presentation/chat/thix_chat_page.dart';
import 'presentation/vault/document_vault_page.dart';
import 'presentation/settings/settings_page.dart';
import 'presentation/network/network_page.dart';
import 'presentation/jobs/jobs_page.dart';
import 'presentation/opportunities/opportunities_page.dart';
import 'presentation/education/education_page.dart';
import 'presentation/training/training_home_page.dart';
import 'presentation/training/training_details_page.dart';
import 'presentation/training/learning_dashboard_page.dart';
import 'presentation/training/lesson_player_page.dart';
import 'presentation/thix_market/thix_market_page.dart';
import 'presentation/thix_sante/thix_sante_page.dart';
import 'presentation/thix_reservation/thix_reservation_page.dart';
import 'presentation/thix_money/thix_money_page.dart';
import 'presentation/thix_incubator/incubator_page.dart';

// ============================================================================
// CONSTANTES DES ROUTES
// ============================================================================
class AppRoutes {
  // Routes principales
  static const String home = '/';
  static const String login = '/login';
  static const String personalReg = '/personal-reg';
  static const String enterpriseReg = '/enterprise-reg';
  static const String enterprise = '/enterprise';
  
  // Paiement & Activation
  static const String payment = '/payment';
  static const String activationReceipt = '/activation-receipt';
  
  // Profil & Dashboard
  static const String publicProfile = '/public-profile';
  static const String userDashboard = '/user-dashboard';
  static const String enterpriseDashboard = '/enterprise-dashboard';
  
  // Enterprise Portal
  static const String enterprisePortalBasePath = '/company';
  static String enterprisePortalBase(String slug) => '${enterprisePortalBasePath}/$slug';
  static String enterprisePortalDashboard(String slug, String section) => '/company/$slug/dashboard/$section';
  
  // Services THIX
  static const String chat = '/chat';
  static const String vault = '/vault';
  static const String settings = '/settings';
  static const String network = '/network';
  
  // Emplois & Opportunités
  static const String jobs = '/jobs';
  static const String jobDashboard = '/jobs/dashboard';
  static const String recruiter = '/recruiter';
  static const String opportunities = '/opportunities';
  
  // Événements
  static const String events = '/events';
  static const String userEventsDashboard = '/events/me';
  
  // Éducation & Formation
  static const String education = '/education';
  static const String trainingHome = '/training';
  static const String trainingDetailsBasePath = '/training-details';
  static const String learningDashboard = '/learn';
  static const String lessonPlayer = '/learn/player';
  
  // Admin
  static const String admin = '/admin';
  
  // Services THIX (supplémentaires)
  static const String thixMarket = '/market';
  static const String thixSante = '/sante';
  static const String reservation = '/reservation';
  static const String thixMoney = '/thix-money';
  static const String incubator = '/incubator';
}

// ============================================================================
// EXTENSION DE NAVIGATION
// ============================================================================
extension GoRouterNavigation on BuildContext {
  void go(String location, {Object? extra}) {
    GoRouter.of(this).go(location, extra: extra);
  }

  void goNamed(String name, {Map<String, String>? pathParameters, Object? extra}) {
    GoRouter.of(this).goNamed(name, pathParameters: pathParameters, extra: extra);
  }

  void push(String location, {Object? extra}) {
    GoRouter.of(this).push(location, extra: extra);
  }

  void pushNamed(String name, {Map<String, String>? pathParameters, Object? extra}) {
    GoRouter.of(this).pushNamed(name, pathParameters: pathParameters, extra: extra);
  }

  void pop() {
    GoRouter.of(this).pop();
  }

  void popOrGo(String fallbackLocation) {
    final router = GoRouter.of(this);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(fallbackLocation);
    }
  }
}

// ============================================================================
// HELPER POUR LES ROUTES AVEC PARAMÈTRES
// ============================================================================
class RouteHelper {
  // Événements
  static String eventDetails(String eventId, {bool registered = false}) {
    return '/events/$eventId${registered ? '?registered=1' : ''}';
  }

  static String eventRegister(String eventId) {
    return '/events/$eventId/register';
  }

  static String eventTicket(String eventId, String registrationId) {
    return '/events/$eventId/ticket/$registrationId';
  }

  // Emplois
  static String jobDetails(String jobId, {bool applied = false}) {
    return '/jobs/$jobId${applied ? '?applied=1' : ''}';
  }

  static String jobApply(String jobId) {
    return '/jobs/$jobId/apply';
  }

  // Opportunités
  static String opportunityDetails(String opportunityId, {bool applied = false}) {
    return '/opportunities/$opportunityId${applied ? '?applied=1' : ''}';
  }

  static String opportunityApply(String opportunityId) {
    return '/opportunities/$opportunityId/apply';
  }

  // Formations
  static String trainingDetails(String trainingId) {
    return '/training-details/$trainingId';
  }

  static String lessonPlayer(String enrollmentId) {
    return '/learn/player/$enrollmentId';
  }

  // Enterprise Portal
  static String enterprisePortal(String slug) {
    return '/company/$slug/dashboard/overview';
  }

  static String enterprisePortalSection(String slug, String section) {
    return '/company/$slug/dashboard/$section';
  }

  // Paiement
  static String payment({String? returnTo}) {
    return returnTo != null ? '/payment?returnTo=$returnTo' : '/payment';
  }

  // Profil public
  static String publicProfile({String? thixId}) {
    return thixId != null ? '/public-profile?thixId=$thixId' : '/public-profile';
  }
}

// ============================================================================
// ROUTER PRINCIPAL
// ============================================================================
class AppRouter {
  static GoRouter create(AuthController auth, {Listenable? extraRefreshListenable}) {
    final refresh = extraRefreshListenable == null ? auth : Listenable.merge([auth, extraRefreshListenable]);
    
    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: refresh,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isLoggedIn = auth.isAuthenticated;
        final isAuthPage = location == AppRoutes.login || 
                           location == AppRoutes.personalReg || 
                           location == AppRoutes.enterpriseReg;
        final isPublic = location == AppRoutes.home ||
                         location == AppRoutes.publicProfile ||
                         location == AppRoutes.jobs ||
                         location == AppRoutes.opportunities ||
                         location == AppRoutes.events ||
                         location == AppRoutes.education ||
                         location == AppRoutes.trainingHome;

        final isProtected = !isPublic && !isAuthPage;
        
        if (!isLoggedIn && isProtected) return AppRoutes.login;
        if (isLoggedIn && isAuthPage) {
          final t = auth.currentUser?.accountType;
          return t == AccountType.enterprise ? AppRoutes.enterpriseDashboard : AppRoutes.userDashboard;
        }
        
        return null;
      },
      routes: [
        // Page d'accueil
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePagePremium(),
          ),
        ),
        
        // Authentification
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoginPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.personalReg,
          name: 'personalReg',
          pageBuilder: (context, state) => NoTransitionPage(
            child: PersonalRegistrationPage(initialStep: 1),
          ),
        ),
        GoRoute(
          path: AppRoutes.enterpriseReg,
          name: 'enterpriseReg',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EnterpriseRegistrationPage(),
          ),
        ),
        
        // Dashboards
        GoRoute(
          path: AppRoutes.userDashboard,
          name: 'userDashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: UserDashboardPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.enterpriseDashboard,
          name: 'enterpriseDashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EnterpriseDashboardPage(),
          ),
        ),
        
        // Événements
        GoRoute(
          path: AppRoutes.events,
          name: 'events',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EventsPage(),
          ),
        ),
        GoRoute(
          path: '/events/:eventId',
          name: 'eventDetails',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            return NoTransitionPage(child: EventDetailsPage(eventId: eventId));
          },
        ),
        GoRoute(
          path: '/events/:eventId/register',
          name: 'eventRegister',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            return NoTransitionPage(child: EventRegisterPage(eventId: eventId));
          },
        ),
        GoRoute(
          path: '/events/:eventId/ticket/:registrationId',
          name: 'eventTicket',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '';
            final registrationId = state.pathParameters['registrationId'] ?? '';
            return NoTransitionPage(child: EventTicketPage(eventId: eventId, registrationId: registrationId));
          },
        ),
        GoRoute(
          path: AppRoutes.userEventsDashboard,
          name: 'userEventsDashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: UserEventDashboardPage(),
          ),
        ),
        
        // Profil public
        GoRoute(
          path: AppRoutes.publicProfile,
          name: 'publicProfile',
          pageBuilder: (context, state) => NoTransitionPage(
            child: PublicProfilePage(initialThixId: state.uri.queryParameters['thixId']),
          ),
        ),
        
        // Services
        GoRoute(
          path: AppRoutes.chat,
          name: 'chat',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ThixChatPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.vault,
          name: 'vault',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DocumentVaultPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.network,
          name: 'network',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: NetworkPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.jobs,
          name: 'jobs',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: JobsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.opportunities,
          name: 'opportunities',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: OpportunitiesPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.education,
          name: 'education',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EducationPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.trainingHome,
          name: 'trainingHome',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TrainingHomePage(),
          ),
        ),
        GoRoute(
          path: '${AppRoutes.trainingDetailsBasePath}/:trainingId',
          name: 'trainingDetails',
          pageBuilder: (context, state) {
            final id = state.pathParameters['trainingId'] ?? '';
            return NoTransitionPage(child: TrainingDetailsPage(trainingId: id));
          },
        ),
        GoRoute(
          path: AppRoutes.learningDashboard,
          name: 'learningDashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LearningDashboardPage(),
          ),
        ),
        GoRoute(
          path: '${AppRoutes.lessonPlayer}/:enrollmentId',
          name: 'lessonPlayer',
          pageBuilder: (context, state) {
            final id = state.pathParameters['enrollmentId'] ?? '';
            return NoTransitionPage(child: LessonPlayerPage(enrollmentId: id));
          },
        ),
        GoRoute(
          path: AppRoutes.thixMarket,
          name: 'thixMarket',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ThixMarketPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.thixSante,
          name: 'thixSante',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ThixSantePage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.reservation,
          name: 'reservation',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ThixReservationPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.thixMoney,
          name: 'thixMoney',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ThixMoneyPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.incubator,
          name: 'incubator',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: IncubatorPage(),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TRANSITION SANS ANIMATION
// ============================================================================
class NoTransitionPage extends Page {
  final Widget child;
  
  const NoTransitionPage({required this.child, super.key});

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      transitionDuration: Duration.zero,
    );
  }
}
