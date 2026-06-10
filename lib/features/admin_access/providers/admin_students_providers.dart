import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/html_source_loader.dart';
import '../../../models/materia.dart';
import '../../../shared/supabase/supabase.dart';
import '../data/admin_students_repository.dart';
import '../models/admin_student.dart';
import '../models/admin_student_history_entry.dart';
import '../models/admin_subject_roster_item.dart';
import '../models/admin_student_subject.dart';

final adminStudentsRepositoryProvider =
    Provider<AdminStudentsRepository>((ref) {
  return const AdminStudentsRepository();
});

final adminStudentsCareerFilterProvider =
    StateProvider<String>((_) => 'artes_visuales');

final adminStudentsProvider = FutureProvider.family<List<AdminStudent>, String>(
    (ref, adminDeviceId) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const <AdminStudent>[];
  final careerId = ref.watch(adminStudentsCareerFilterProvider);
  final repo = ref.watch(adminStudentsRepositoryProvider);
  return repo.list(
    client: client,
    adminDeviceId: adminDeviceId,
    careerId: careerId,
  );
});

final adminStudentSubjectsProvider = FutureProvider.family<
    List<AdminStudentSubject>,
    ({String adminDeviceId, String studentId})>((ref, args) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const <AdminStudentSubject>[];
  final repo = ref.watch(adminStudentsRepositoryProvider);
  return repo.listSubjects(
    client: client,
    adminDeviceId: args.adminDeviceId,
    studentId: args.studentId,
  );
});

final adminCareerPlanProvider =
    FutureProvider.family<List<Materia>, String>((ref, careerId) async {
  final asset = switch (careerId) {
    'musica' => 'assets/Musica.html',
    _ => 'assets/data/artes_visuales.json',
  };
  final plan = await loadPlanFromHtmlAsset(asset);
  final materias = [...plan.materias]..sort((a, b) {
      final year = a.anio.compareTo(b.anio);
      if (year != 0) return year;
      return a.displayNombre.compareTo(b.displayNombre);
    });
  return materias;
});

final adminSubjectRosterProvider = FutureProvider.family<
    List<AdminSubjectRosterItem>,
    ({
      String adminDeviceId,
      String careerId,
      String subjectId
    })>((ref, args) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null || args.subjectId.isEmpty) {
    return const <AdminSubjectRosterItem>[];
  }
  final repo = ref.watch(adminStudentsRepositoryProvider);
  return repo.listSubjectRoster(
    client: client,
    adminDeviceId: args.adminDeviceId,
    careerId: args.careerId,
    subjectId: args.subjectId,
  );
});

final adminStudentHistoryProvider = FutureProvider.family<
    List<AdminStudentHistoryEntry>,
    ({String adminDeviceId, String studentId})>((ref, args) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null || args.studentId.isEmpty) {
    return const <AdminStudentHistoryEntry>[];
  }
  final repo = ref.watch(adminStudentsRepositoryProvider);
  return repo.listHistory(
    client: client,
    adminDeviceId: args.adminDeviceId,
    studentId: args.studentId,
  );
});
