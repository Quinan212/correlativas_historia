import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBulkCleanupResult {
  const AdminBulkCleanupResult({
    required this.summary,
  });

  final Map<String, dynamic> summary;
}

class AdminBulkCleanupRepository {
  const AdminBulkCleanupRepository();

  Future<AdminBulkCleanupResult> runAction({
    required SupabaseClient client,
    required String adminDeviceId,
    required String action,
  }) async {
    final response = await client.functions.invoke(
      'admin-bulk-cleanup',
      body: {
        'device_id': adminDeviceId,
        'action': action,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('La limpieza no devolvio un resumen valido.');
    }

    if (data['ok'] != true) {
      throw Exception(
          (data['error'] ?? 'No se pudo completar la limpieza').toString());
    }

    final summary = data['summary'];
    if (summary is! Map<String, dynamic>) {
      throw Exception('La limpieza termino sin un resumen interpretable.');
    }

    return AdminBulkCleanupResult(summary: summary);
  }
}
