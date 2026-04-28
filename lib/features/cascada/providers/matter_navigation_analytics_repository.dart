import 'package:supabase_flutter/supabase_flutter.dart';

class MatterNavigationAnalyticsRepository {
  const MatterNavigationAnalyticsRepository();

  Future<void> trackDetailView({
    required SupabaseClient? client,
    required String deviceId,
    required String careerId,
    required String matterId,
    required String matterName,
    String surface = 'detail_modal',
  }) async {
    if (client == null) return;
    await client.from('matter_navigation_events').insert({
      'device_id': deviceId,
      'event_type': 'view',
      'surface': surface,
      'career_id': careerId,
      'matter_id': matterId,
      'matter_name': matterName,
    });
  }

  Future<void> trackTransition({
    required SupabaseClient? client,
    required String deviceId,
    required String sourceCareerId,
    required String sourceMatterId,
    required String sourceMatterName,
    required String targetCareerId,
    required String targetMatterId,
    required String targetMatterName,
    String surface = 'detail_modal',
  }) async {
    if (client == null) return;
    await client.from('matter_navigation_events').insert({
      'device_id': deviceId,
      'event_type': 'transition',
      'surface': surface,
      'source_career_id': sourceCareerId,
      'source_matter_id': sourceMatterId,
      'source_matter_name': sourceMatterName,
      'career_id': targetCareerId,
      'matter_id': targetMatterId,
      'matter_name': targetMatterName,
    });
  }
}
