import 'package:correlativas_historia/funcionalidades/laboratorio_biblioteca_drive/configuracion/configuracion_biblioteca_drive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('usa la carpeta pública Biblioteca como raíz', () {
    const configuration = ConfiguracionBibliotecaDrive.current;

    expect(
      configuration.rootFolderId,
      '14qLLT7wkazGeNaJrbBSHwRk4bVI2g-Hz',
    );
    expect(configuration.rootFolderUrl, contains(configuration.rootFolderId));
  });

  test('construye una consulta acotada a los hijos de una carpeta', () {
    const configuration = ConfiguracionBibliotecaDrive.current;
    final uri = configuration.listChildrenUri(folderId: 'folder-test');

    expect(uri.host, 'www.googleapis.com');
    expect(uri.path, '/drive/v3/files');
    expect(uri.queryParameters['q'], contains("'folder-test' in parents"));
    expect(uri.queryParameters['pageSize'], '1000');
  });
}
