import 'package:flutter_test/flutter_test.dart';

import '../../lib/funcionalidades/acceso_estudiante/sage_historial/sage_report_function_transformer.dart';

void main() {
  test('preserva la expresión oficial y los parámetros', () {
    const source = '''function f(a) {
  location.href = '/reporte.php?id=' + a;
}''';
    final result = SageReportFunctionTransformer.transform(
      source,
      'estado_alumno',
    );

    expect(result.isSafe, isTrue);
    expect(result.assignmentCount, 1);
    expect(result.assignmentTarget, 'location.href');
    expect(
      result.source,
      contains(
        "return window.__flutterCaptureSageReportV3(\"estado_alumno\", '/reporte.php?id=' + a)",
      ),
    );
  });

  test('conserva ternarios, paréntesis y strings con punto y coma', () {
    const source = '''function f(a, b) {
  const valor = 'texto;con;puntos';
  window.location.href = condicion
      ? '/uno.php?a=' + a
      : '/dos.php?b=' + b;
}''';
    final result = SageReportFunctionTransformer.transform(source, 'analitico');

    expect(result.isSafe, isTrue);
    expect(result.source, contains("? '/uno.php?a=' + a"));
    expect(result.source, contains(": '/dos.php?b=' + b"));
    expect(result.source, contains("'texto;con;puntos'"));
  });

  test('rechaza cero o más de una asignación compatible', () {
    const none = 'function f() { location.assign("/r.php"); }';
    const many = 'function f() { location.href = "/a"; location.href = "/b"; }';

    expect(
      SageReportFunctionTransformer.transform(none, 'analitico').status,
      SageReportTransformStatus.structureChanged,
    );
    expect(
      SageReportFunctionTransformer.transform(many, 'analitico').status,
      SageReportTransformStatus.unsafe,
    );
  });

  test(
    'rechaza mecanismos inesperados e instalación estructural no equivalente',
    () {
      const open =
          'function f() { window.open("/r.php"); location.href = "/r.php"; }';
      const submit =
          'function f() { form.submit(); location.href = "/r.php"; }';

      expect(
        SageReportFunctionTransformer.transform(open, 'analitico').status,
        SageReportTransformStatus.unsafe,
      );
      expect(
        SageReportFunctionTransformer.transform(submit, 'analitico').status,
        SageReportTransformStatus.unsafe,
      );
    },
  );

  test('calcula hash estable para diagnóstico', () {
    final first = SageReportFunctionTransformer.transform(
      'function f() { location.href = "/r.php"; }',
      'analitico',
    );
    final second = SageReportFunctionTransformer.transform(
      'function f() { location.href = "/r.php"; }',
      'analitico',
    );

    expect(first.hash, isNotEmpty);
    expect(first.hash, second.hash);
  });
}
