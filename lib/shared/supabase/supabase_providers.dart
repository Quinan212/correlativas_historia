import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_bootstrap.dart';

final supabaseBootstrapProvider = Provider<SupabaseBootstrapResult>(
  (ref) => throw UnimplementedError(
    'supabaseBootstrapProvider debe overridearse en ProviderScope.',
  ),
);

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final bootstrap = ref.watch(supabaseBootstrapProvider);
  if (!bootstrap.isReady) return null;
  return Supabase.instance.client;
});
