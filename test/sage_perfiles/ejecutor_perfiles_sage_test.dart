import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_perfiles/ejecutor_perfiles_sage.dart';
import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_perfiles/modelos_perfiles_sage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('usa el control oficial del perfil y no fabrica un POST', () async {
    String? source;
    final executor = EjecutorPerfilesSage((value) async {
      source = value;
      return '{"found":true,"dispatched":true,"activated":true,"confirmed":true}';
    });

    final result = await executor.cambiar(PerfilSage.alumnos);

    expect(result.success, isTrue);
    expect(source, contains('input[type="radio"]'));
    expect(source, contains('candidate.click'));
    expect(source, isNot(contains('fetch(')));
    expect(source, isNot(contains('XMLHttpRequest')));
  });
}
