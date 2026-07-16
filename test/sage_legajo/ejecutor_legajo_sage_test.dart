import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_legajo/ejecutor_legajo_sage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'el localizador de pestañas recorre todos los documentos accesibles',
    () async {
      String? capturedSource;
      final executor = EjecutorLegajoSage((source) async {
        capturedSource = source;
        return '{"found":false,"dispatched":false,"activated":false}';
      });

      await executor.activarPestanaEscolares();

      expect(capturedSource, contains('docs.forEach'));
      expect(capturedSource, isNot(contains('const target = docs.find')));
      expect(capturedSource, contains('candidateCount'));
      expect(capturedSource, contains('matchedBy'));
    },
  );
}
