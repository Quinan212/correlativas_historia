import 'package:correlativas_historia/funcionalidades/laboratorio_biblioteca_drive/modelos/modelos_biblioteca_drive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('oculta prefijos de orden sin alterar el nombre real', () {
    const item = ElementoBibliotecaDrive(
      id: 'folder-id',
      name: '04 - Clases del campus virtual',
      mimeType: mimeCarpetaGoogleDrive,
      canDownload: true,
    );

    expect(item.name, '04 - Clases del campus virtual');
    expect(item.visibleName, 'Clases del campus virtual');
    expect(item.isFolder, isTrue);
  });

  test('ordena carpetas antes que archivos y usa orden natural', () {
    const source = <ElementoBibliotecaDrive>[
      ElementoBibliotecaDrive(
        id: 'file',
        name: 'Apunte.pdf',
        mimeType: 'application/pdf',
        canDownload: true,
      ),
      ElementoBibliotecaDrive(
        id: '12',
        name: '12 - Otros',
        mimeType: mimeCarpetaGoogleDrive,
        canDownload: true,
      ),
      ElementoBibliotecaDrive(
        id: '2',
        name: '02 - Bibliografía',
        mimeType: mimeCarpetaGoogleDrive,
        canDownload: true,
      ),
    ];

    final ordered = ordenarElementosBibliotecaDrive(source);

    expect(ordered.map((item) => item.id), <String>['2', '12', 'file']);
  });
}
