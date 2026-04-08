import 'package:flutter/material.dart';

import '../../features/admin_access/screens/admin_access_screen.dart';
import 'smooth_route.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void openVerificationScreen() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      smoothRoute<void>(const AdminAccessScreen()),
    );
  });
}
