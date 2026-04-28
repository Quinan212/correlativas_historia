import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/html_source_loader.dart';
import '../../../models/materia.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/supabase/supabase.dart';
import '../../opiniones/models/matter_photo_post.dart';

class AdminMatterPhotoMatterStats {
  const AdminMatterPhotoMatterStats({
    required this.matter,
    required this.photoCount,
  });

  final Materia matter;
  final int photoCount;
}

class AdminMatterPhotoYearStats {
  const AdminMatterPhotoYearStats({
    required this.year,
    required this.photoCount,
    required this.matters,
  });

  final int year;
  final int photoCount;
  final List<AdminMatterPhotoMatterStats> matters;
}

class AdminMatterPhotoCareerStats {
  const AdminMatterPhotoCareerStats({
    required this.career,
    required this.photoCount,
    required this.years,
  });

  final CareerInfo career;
  final int photoCount;
  final List<AdminMatterPhotoYearStats> years;
}

final adminMatterPhotosOverviewProvider =
    FutureProvider.autoDispose<List<AdminMatterPhotoCareerStats>>((ref) async {
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  final client = ref.watch(supabaseClientProvider);

  if (!bootstrap.isReady || client == null) {
    return const <AdminMatterPhotoCareerStats>[];
  }

  final rows = await client
      .from('matter_photo_posts')
      .select(
        'id, device_id, matter_id, career_id, image_path, image_url, caption, created_at, updated_at, enabled',
      );

  final posts = rows
      .cast<Map<String, dynamic>>()
      .map(MatterPhotoPost.fromMap)
      .where((post) => post.enabled)
      .toList(growable: false);

  if (posts.isEmpty) {
    return const <AdminMatterPhotoCareerStats>[];
  }

  final photoCountByCareer = <String, int>{};
  final photoCountByMatter = <String, int>{};
  for (final post in posts) {
    photoCountByCareer[post.careerId] =
        (photoCountByCareer[post.careerId] ?? 0) + 1;
    photoCountByMatter[post.matterId] =
        (photoCountByMatter[post.matterId] ?? 0) + 1;
  }

  final careers = kCareers.where((career) => !career.hidden).toList(growable: false);
  final plans = await Future.wait(
    careers.map(
      (career) async {
        final basePlan = await loadPlanFromHtmlAsset(career.assetHtml);
        final institution = kInstitutions.where((i) => i.careerId == career.id);
        final overrides = institution.isEmpty
            ? const <MateriaOverride>[]
            : institution.first.overrides;
        return (
          career: career,
          materias: _applyInstitutionOverrides(basePlan.materias, overrides),
        );
      },
    ),
  );

  final result = <AdminMatterPhotoCareerStats>[];
  for (final plan in plans) {
    final careerPhotoCount = photoCountByCareer[plan.career.id] ?? 0;
    if (careerPhotoCount <= 0) continue;

    final byYear = <int, List<AdminMatterPhotoMatterStats>>{};
    for (final matter in plan.materias) {
      final count = photoCountByMatter[matter.id] ?? 0;
      if (count <= 0) continue;
      byYear.putIfAbsent(matter.anio, () => <AdminMatterPhotoMatterStats>[]).add(
            AdminMatterPhotoMatterStats(
              matter: matter,
              photoCount: count,
            ),
          );
    }

    final years = byYear.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));

    final yearStats = <AdminMatterPhotoYearStats>[];
    for (final entry in years) {
      final maters = entry.value.toList(growable: false)
        ..sort((a, b) => a.matter.displayNombre.compareTo(b.matter.displayNombre));
      final yearCount = maters.fold<int>(0, (sum, item) => sum + item.photoCount);
      if (yearCount <= 0) continue;
      yearStats.add(
        AdminMatterPhotoYearStats(
          year: entry.key,
          photoCount: yearCount,
          matters: maters,
        ),
      );
    }

    if (yearStats.isEmpty) continue;

    result.add(
      AdminMatterPhotoCareerStats(
        career: plan.career,
        photoCount: careerPhotoCount,
        years: yearStats,
      ),
    );
  }

  result.sort((a, b) {
    final byCount = b.photoCount.compareTo(a.photoCount);
    if (byCount != 0) return byCount;
    return a.career.nombre.compareTo(b.career.nombre);
  });
  return result;
});

List<Materia> _applyInstitutionOverrides(
  List<Materia> materias,
  List<MateriaOverride> overrides,
) {
  if (overrides.isEmpty) return materias;

  final byId = <String, MateriaOverride>{
    for (final override in overrides) override.materiaId: override,
  };

  return materias.map((m) {
    final override = byId[m.id];
    if (override == null) return m;
    return Materia(
      id: m.id,
      codigo: override.codigo ?? m.codigo,
      nombre: override.nombre ?? m.nombre,
      anio: override.anio ?? m.anio,
      cuatri: override.cuatri ?? m.cuatri,
      tipo: override.tipo ?? m.tipo,
      formato: override.formato ?? m.formato,
      correlativas: m.correlativas,
      horas: override.horas ?? m.horas,
      correlativasDetalladas: m.correlativasDetalladas,
    );
  }).toList(growable: false);
}
