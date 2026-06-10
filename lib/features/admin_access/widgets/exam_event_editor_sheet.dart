import 'package:flutter/material.dart';

import '../models/admin_exam_event.dart';
import 'exam_event_editor.dart';

Future<AdminExamEventDraft?> showExamEventEditorSheet({
  required BuildContext context,
  required String title,
  required bool coloquioMode,
  AdminExamEvent? initialEvent,
}) {
  return showModalBottomSheet<AdminExamEventDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _MobileSheetWrapper(
      title: title,
      coloquioMode: coloquioMode,
      initialEvent: initialEvent,
    ),
  );
}

class _MobileSheetWrapper extends StatelessWidget {
  const _MobileSheetWrapper({
    required this.title,
    required this.coloquioMode,
    this.initialEvent,
  });

  final String title;
  final bool coloquioMode;
  final AdminExamEvent? initialEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom;

    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
          child: AdminExamEventEditor(
            title: title,
            coloquioMode: coloquioMode,
            initialEvent: initialEvent,
            onCancel: () => Navigator.of(context).pop(),
            onSave: (draft) => Navigator.of(context).pop(draft),
          ),
        ),
      ),
    );
  }
}
