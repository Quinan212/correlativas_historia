import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_perfiles/detector_perfiles_sage.dart';
import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_perfiles/modelos_perfiles_sage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza las etiquetas oficiales y evita duplicados', () {
    final result = const DetectorPerfilesSage().detectar({
      'panelOpen': true,
      'avatarFound': true,
      'profiles': [
        {'label': 'Agente', 'active': true},
        {'label': 'Alumnos', 'active': false},
        {'label': 'Agente', 'active': false},
      ],
    });

    expect(result.perfiles.map((item) => item.perfil), [
      PerfilSage.agente,
      PerfilSage.alumnos,
    ]);
    expect(result.activo, PerfilSage.agente);
  });

  test('ignora etiquetas ambiguas o parciales', () {
    final result = const DetectorPerfilesSage().detectar({
      'profiles': [
        {'label': 'Agentes habilitados'},
        {'label': 'Alumno histórico'},
      ],
    });

    expect(result.perfiles, isEmpty);
  });
}
