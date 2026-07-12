import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_bootstrap.dart';

final proveedorArranqueSupabase = Provider<ResultadoArranqueSupabase>(
  (ref) => throw UnimplementedError(
    'proveedorArranqueSupabase debe overridearse en ProviderScope.',
  ),
);

final proveedorClienteSupabase = Provider<SupabaseClient?>((ref) {
  final bootstrap = ref.watch(proveedorArranqueSupabase);
  if (!bootstrap.isReady) return null;
  return Supabase.instance.client;
});

final proveedorEstadoAutenticacionSupabase = StreamProvider<AuthState>((ref) {
  final client = ref.watch(proveedorClienteSupabase);

  if (client == null) {
    return const Stream<AuthState>.empty();
  }

  return client.auth.onAuthStateChange;
});

final proveedorSesionActivaSupabase = Provider<bool>((ref) {
  final client = ref.watch(proveedorClienteSupabase);
  final authState = ref.watch(proveedorEstadoAutenticacionSupabase);

  return authState.maybeWhen(
    data: (state) => state.session != null,
    orElse: () => client?.auth.currentSession != null,
  );
});
