import 'dart:async';

import 'package:flutter/material.dart';

import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../controladores/controlador_mesas_excel.dart';
import 'pantalla_inicio_mesas_excel_atlassian.dart';

class PantallaSistemaMesasExcelAtlassian extends StatefulWidget {
  const PantallaSistemaMesasExcelAtlassian({super.key});

  @override
  State<PantallaSistemaMesasExcelAtlassian> createState() =>
      _PantallaSistemaMesasExcelAtlassianState();
}

class _PantallaSistemaMesasExcelAtlassianState
    extends State<PantallaSistemaMesasExcelAtlassian> {
  late final ControladorMesasExcel _controller;

  @override
  void initState() {
    super.initState();
    _controller = ControladorMesasExcel();
    unawaited(_controller.inicializar());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = temaLaboratorioAtlassian(context);
    return Theme(
      data: theme,
      child: PantallaInicioMesasExcelAtlassian(controller: _controller),
    );
  }
}
