import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/supabase/supabase.dart';
import '../data/admin_exam_events_repository.dart';
import '../models/admin_exam_event.dart';

final adminExamEventsRepositoryProvider =
    Provider<AdminExamEventsRepository>((ref) {
  return const AdminExamEventsRepository();
});

final adminExamEventsProvider =
    FutureProvider<List<AdminExamEvent>>((ref) async {
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  final client = ref.watch(supabaseClientProvider);

  if (!bootstrap.isReady || client == null) {
    return const <AdminExamEvent>[];
  }

  try {
    final repo = ref.read(adminExamEventsRepositoryProvider);
    return await repo.fetchAll(client: client);
  } on PostgrestException {
    rethrow;
  }
});
