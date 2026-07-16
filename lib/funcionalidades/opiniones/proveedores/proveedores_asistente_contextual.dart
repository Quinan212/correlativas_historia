import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/configuracion/banderas_funcionalidad.dart';
import '../../../compartido/supabase/supabase.dart';
import '../datos/repositorio_asistente_contextual.dart';

final proveedorRepositorioAsistenteContextual =
    Provider<RepositorioAsistenteContextual>(
  (ref) => const RepositorioAsistenteContextual(),
);

final proveedorAsistenteContextualListo = Provider<bool>((ref) {
  if (!BanderasFuncionalidad.asistenteContextualHabilitado) return false;
  return ref.watch(proveedorClienteSupabase) != null;
});
