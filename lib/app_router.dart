import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/presentation/home/home_page.dart';
import 'package:thix_id/presentation/auth/login_page.dart';
import 'package:thix_id/presentation/auth/personal_registration_page.dart';
import 'package:thix_id/presentation/auth/enterprise_registration_page.dart';
import 'package:thix_id/presentation/payment/payment_gateway_page.dart';
import 'package:thix_id/presentation/payment/activation_receipt_page.dart';
import 'package:thix_id/presentation/profile/public_profile_page.dart';
import 'package:thix_id/presentation/dashboard/user_dashboard_page.dart';
import 'package:thix_id/presentation/enterprise/enterprise_dashboard_page.dart';
import 'package:thix_id/presentation/enterprise/enterprise_portal_page.dart';
import 'package:thix_id/presentation/enterprise/enterprise_dashboard_shell_page.dart';
import 'package:thix_id/presentation/chat/thix_chat_page.dart';
import 'package:thix_id/presentation/vault/document_vault_page.dart';
import 'package:thix_id/presentation/settings/settings_page.dart';
import 'package:thix_id/presentation/network/network_page.dart';
import 'package:thix_id/presentation/jobs/jobs_page.dart';
import 'package:thix_id/presentation/jobs/job_apply_page.dart';
import 'package:thix_id/presentation/jobs/job_details_page.dart';
import 'package:thix_id/presentation/jobs/job_dashboard_page.dart';
import 'package:thix_id/presentation/recruiter/recruiter_portal_page.dart';
import 'package:thix_id/presentation/opportunities/opportunities_page.dart';
import 'package:thix_id/presentation/opportunities/opportunity_apply_page.dart';
import 'package:thix_id/presentation/opportunities/opportunity_details_page.dart';
import 'package:thix_id/presentation/events/events_page.dart';
import 'package:thix_id/presentation/events/event_details_page.dart';
import 'package:thix_id/presentation/events/event_register_page.dart';
import 'package:thix_id/presentation/events/event_ticket_page.dart';
import 'package:thix_id/presentation/events/user_event_dashboard_page.dart';
import 'package:thix_id/presentation/education/education_page.dart';
import 'package:thix_id/presentation/training/training_home_page.dart';
import 'package:thix_id/presentation/training/training_details_page.dart';
import 'package:thix_id/presentation/training/learning_dashboard_page.dart';
import 'package:thix_id/presentation/training/lesson_player_page.dart';
import 'package:thix_id/presentation/admin/admin_page.dart';
import 'package:thix_id/presentation/admin/admin_routes.dart';
import 'package:thix_id/presentation/thix_market/thix_market_page.dart';
import 'package:thix_id/presentation/thix_sante/thix_sante_page.dart';
import 'package:thix_id/presentation/thix_reservation/thix_reservation_page.dart';
import 'package:thix_id/presentation/thix_money/thix_money_page.dart';
import 'package:thix_id/presentation/thix_media/thix_media_page.dart';
import 'package:thix_id/presentation/admin/pages/admin_media_page.dart'; // import admin media

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String personalReg = '/personal-reg';
  static const String enterpriseReg = '/enterprise-reg';
  static const String enterprise = '/enterprise';
  static const String payment = '/payment';
  static const String activationReceipt = '/activation-receipt';
  static const String publicProfile = '/public-profile';
  static const String userDashboard = '/user-dashboard';
  static const String enterpriseDashboard = '/enterprise-dashboard';
  static const String enterprisePortalBasePath = '/company';
  static const String chat = '/chat';
  static const String vault = '/vault';
  static const String settings = '/settings';
  static const String network = '/network';
  static const String jobs = '/jobs';
  static const String jobDashboard = '/jobs/dashboard';
  static const String recruiter = '/recruiter';
  static const String opportunities = '/opportunities';
  static const String events = '/events';
  static const String education = '/education';
  static const String trainingHome = '/training';
  static const String trainingDetailsBasePath = '/training-details';
  static const String learningDashboard = '/learn';
  static const String lessonPlayer = '/learn/player';
  static const String admin = '/admin';
  static const String thixMarket = '/market';
  static const String thixSante = '/sante';
  static const String reservation = '/reservation';
  static const String thixMoney = '/thix-money';
  static const String thixMedia = '/thix-media';
  static const String adminMedia = '/admin/media'; // nouvelle route

  static String enterprisePortalBase(String slug) => '${enterprisePortalBasePath}/$slug';
  static String enterprisePortalDashboard(String slug, String section) => '/company/$slug/dashboard/$section';
}

class AppRouter {
  static GoRouter create(AuthController auth, {Listenable? extraRefreshListenable}) {
    final refresh = extraRefreshListenable == null ? auth : Listenable.merge([auth, extraRefreshListenable]);
    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: refresh,
      redirect: (context, state) {
        // ... votre logique de redirection existante ...
        // (gardez votre code actuel, je ne le modifie pas)
        return null;
      },
      routes: [
        // ... toutes vos routes existantes ...
        // Ajoutez la route admin media :
        GoRoute(
          path: AppRoutes.adminMedia,
          name: 'adminMedia',
          pageBuilder: (context, state) => const NoTransitionPage(child: AdminMediaPage()),
        ),
        // N'oubliez pas de conserver toutes vos autres routes (home, login, etc.)
      ],
    );
  }
}
