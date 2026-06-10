import 'package:flutter/material.dart';

import 'admin_access_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({
    super.key,
    required this.deviceId,
    this.adminLabel,
  });

  final String deviceId;
  final String? adminLabel;

  @override
  Widget build(BuildContext context) {
    return const AdminAccessScreen();
  }
}
