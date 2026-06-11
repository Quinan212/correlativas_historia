import 'package:supabase_flutter/supabase_flutter.dart';

class RepositorioAnaliticasNavegacionExamenes {
  const RepositorioAnaliticasNavegacionExamenes();

  Future<void> trackView({
    required SupabaseClient? client,
    required String deviceId,
    required String careerId,
    required String matterName,
    required String tabId,
    required String tabLabel,
    String? divisionId,
    String? divisionLabel,
    String surface = 'sheet',
  }) async {
    if (client == null) return;
    await client.from('exam_navigation_events').insert({
      'device_id': deviceId,
      'event_type': 'view',
      'surface': surface,
      'career_id': careerId,
      'matter_name': matterName,
      'tab_id': tabId,
      'tab_label': tabLabel,
      'division_id': divisionId,
      'division_label': divisionLabel,
    });
  }

  Future<void> trackTransition({
    required SupabaseClient? client,
    required String deviceId,
    required String sourceCareerId,
    required String sourceMatterName,
    required String sourceTabId,
    required String sourceTabLabel,
    String? sourceDivisionId,
    String? sourceDivisionLabel,
    required String targetCareerId,
    required String targetMatterName,
    required String targetTabId,
    required String targetTabLabel,
    String? targetDivisionId,
    String? targetDivisionLabel,
    String surface = 'sheet',
  }) async {
    if (client == null) return;
    await client.from('exam_navigation_events').insert({
      'device_id': deviceId,
      'event_type': 'transition',
      'surface': surface,
      'career_id': targetCareerId,
      'matter_name': targetMatterName,
      'tab_id': targetTabId,
      'tab_label': targetTabLabel,
      'division_id': targetDivisionId,
      'division_label': targetDivisionLabel,
      'source_career_id': sourceCareerId,
      'source_tab_id': sourceTabId,
      'source_tab_label': sourceTabLabel,
      'source_division_id': sourceDivisionId,
      'source_division_label': sourceDivisionLabel,
    });
  }
}
