import 'package:flutter/material.dart';

import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../configuracion/configuracion_biblioteca_drive.dart';
import '../datos/repositorio_biblioteca_drive.dart';
import '../modelos/modelos_biblioteca_drive.dart';
import 'pantalla_carpeta_biblioteca_drive_atlassian.dart';

class PantallaBibliotecaDriveAtlassian extends StatefulWidget {
  const PantallaBibliotecaDriveAtlassian({super.key});

  @override
  State<PantallaBibliotecaDriveAtlassian> createState() =>
      _PantallaBibliotecaDriveAtlassianState();
}

class _PantallaBibliotecaDriveAtlassianState
    extends State<PantallaBibliotecaDriveAtlassian> {
  late final RepositorioBibliotecaDrive _repository;

  @override
  void initState() {
    super.initState();
    _repository = RepositorioBibliotecaDrive();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configuration = ConfiguracionBibliotecaDrive.current;
    return Theme(
      data: temaLaboratorioAtlassian(context),
      child: PantallaCarpetaBibliotecaDriveAtlassian(
        repository: _repository,
        folderId: configuration.rootFolderId,
        resourceKey: configuration.rootResourceKey,
        title: 'Biblioteca',
        routeSegments: const <SegmentoRutaBibliotecaDrive>[],
      ),
    );
  }
}
