import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_perfiles/ejecutor_perfiles_sage.dart';
import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_perfiles/modelos_perfiles_sage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('abre Mi perfil y agenda el clic oficial sin fabricar un POST', () async {
    final sources = <String>[];
    var call = 0;
    final executor = EjecutorPerfilesSage((source) async {
      sources.add(source);
      call++;
      if (call == 1) {
        return '{"avatarFound":true,"avatarDispatched":true,'
            '"panelOpen":false,"profiles":[]}';
      }
      if (call == 2) {
        return '{"avatarFound":true,"avatarDispatched":false,'
            '"panelOpen":true,"profiles":['
            '{"label":"Agente","active":true},'
            '{"label":"Alumnos","active":false}]}';
      }
      return '{"found":true,"dispatched":true,"activated":true,'
          '"alreadyActive":false,"stage":"click_scheduled"}';
    });

    final result = await executor.cambiar(PerfilSage.alumnos);

    expect(result.dispatchSucceeded, isTrue);
    expect(result.confirmed, isFalse);
    expect(sources.first, contains('button.btn-user'));
    expect(sources.last, contains('setTimeout'));
    expect(sources.join('\n'), isNot(contains('fetch(')));
    expect(sources.join('\n'), isNot(contains('XMLHttpRequest')));
  });

  test('no cambia cuando el perfil solicitado ya está activo', () async {
    final executor = EjecutorPerfilesSage((_) async {
      return '{"avatarFound":true,"panelOpen":true,"profiles":['
          '{"label":"Agente","active":true},'
          '{"label":"Alumnos","active":false}]}';
    });

    final result = await executor.cambiar(PerfilSage.agente);

    expect(result.success, isTrue);
    expect(result.alreadyActive, isTrue);
  });
}
