import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

enum SupabaseBootstrapStatus {
  ready,
  missingAnonKey,
  failed,
}

class SupabaseBootstrapResult {
  const SupabaseBootstrapResult({
    required this.status,
    required this.message,
    this.error,
  });

  final SupabaseBootstrapStatus status;
  final String message;
  final Object? error;

  bool get isReady => status == SupabaseBootstrapStatus.ready;
}

Future<SupabaseBootstrapResult> initializeSupabase() async {
  if (!SupabaseConfig.hasClientKey) {
    return const SupabaseBootstrapResult(
      status: SupabaseBootstrapStatus.missingAnonKey,
      message: 'Supabase no se inicializo porque falta una client key valida. '
          'La app puede abrir, pero las funciones online quedan desactivadas.',
    );
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.clientKey,
    );

    return const SupabaseBootstrapResult(
      status: SupabaseBootstrapStatus.ready,
      message: 'Supabase inicializado correctamente.',
    );
  } catch (error, stackTrace) {
    debugPrint('Error inicializando Supabase: $error');
    debugPrintStack(stackTrace: stackTrace);

    return SupabaseBootstrapResult(
      status: SupabaseBootstrapStatus.failed,
      message:
          'Supabase no pudo inicializarse. Revisa la URL, la anon key y la red.',
      error: error,
    );
  }
}
