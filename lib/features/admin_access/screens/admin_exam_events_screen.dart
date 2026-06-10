import 'package:flutter/material.dart';

import '../widgets/admin_exam_events_desktop.dart';
import '../widgets/admin_exam_events_section.dart';

class AdminExamEventsScreen extends StatelessWidget {
  const AdminExamEventsScreen({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Gestion de mesas y coloquios'),
              backgroundColor: const Color(0xFF0E5E86),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: AdminExamEventsDesktop(adminDeviceId: adminDeviceId),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Mesas y coloquios')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                AdminExamEventsSection(
                  adminDeviceId: adminDeviceId,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
