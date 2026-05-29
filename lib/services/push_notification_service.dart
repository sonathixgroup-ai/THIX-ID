import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static final PushNotificationService instance =
      PushNotificationService._();

  PushNotificationService._();

  bool _initialized = false;

  Future<void> initIfNeeded() async {
    if (_initialized) return;

    _initialized = true;

    debugPrint(
      'PushNotificationService initialized',
    );
  }

  Future<void> onSignedIn({
    required String userId,
  }) async {
    debugPrint(
      'PushNotificationService user signed in: $userId',
    );
  }

  Future<void> onSignedOut() async {
    debugPrint(
      'PushNotificationService user signed out',
    );
  }

  Future<void> showLocalMessage({
    required BuildContext context,
    required String title,
    required String body,
  }) async {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
