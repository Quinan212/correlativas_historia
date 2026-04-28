import 'package:flutter/material.dart';

import '../widgets/admin_exam_events_section.dart';

class AdminExamEventsScreen extends StatelessWidget {
  const AdminExamEventsScreen({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  Widget build(BuildContext context) {
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
  }
}
