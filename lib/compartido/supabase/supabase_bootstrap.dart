import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

enum EstadoArranqueSupabase {
  ready,
  missingAnonKey,
  failed,
}

class ResultadoArranqueSupabase {
  const ResultadoArranqueSupabase({
    required this.status,
    required this.message,
    this.error,
  });

  final EstadoArranqueSupabase status;
  final String message;
  final Object? error;

  bool get isReady => status == EstadoArranqueSupabase.ready;
}

Future<ResultadoArranqueSupabase> initializeSupabase() async {
  if (!SupabaseConfig.hasClientKey) {
    return const ResultadoArranqueSupabase(
      status: EstadoArranqueSupabase.missingAnonKey,
      message: 'Supabase no se inicializo porque falta una client key valida. '
          'La app puede abrir, pero las funciones online quedan desactivadas.',
    );
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.clientKey,
    );

    return const ResultadoArranqueSupabase(
      status: EstadoArranqueSupabase.ready,
      message: 'Supabase inicializado correctamente.',
    );
  } catch (error, stackTrace) {
    debugPrint('Error inicializando Supabase: $error');
    debugPrintStack(stackTrace: stackTrace);

    return ResultadoArranqueSupabase(
      status: EstadoArranqueSupabase.failed,
      message:
          'Supabase no pudo inicializarse. Revisa la URL, la anon key y la red.',
      error: error,
    );
  }
}
