import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thix_id/presentation/thix_media/thix_media_page.dart';
import 'package:thix_id/presentation/admin/pages/admin_media_page.dart';

/// Page sans transition (identique à celle utilisée ailleurs)
class NoTransitionPage<T> extends Page<T> {
  final Widget child;
  const NoTransitionPage({required this.child, super.key});

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute(builder: (context) => child, settings: this);
  }
}

/// Routes spécifiques à THIX MEDIA
class MediaRoutes {
  static const String thixMedia = '/thix-media';
  static const String adminMedia = '/admin/media';
}

/// Routeur partiel (à intégrer dans le routeur principal)
List<GoRoute> mediaRoutes = [
  GoRoute(
    path: MediaRoutes.thixMedia,
    name: 'thixMedia',
    pageBuilder: (context, state) => const NoTransitionPage(child: ThixMediaPage()),
  ),
  GoRoute(
    path: MediaRoutes.adminMedia,
    name: 'adminMedia',
    pageBuilder: (context, state) => const NoTransitionPage(child: AdminMediaPage()),
  ),
];
