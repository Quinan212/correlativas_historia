// lib/features/examenes/sheet/route_sheet_examenes.dart
import 'package:flutter/material.dart';

import '../../models/examen_event.dart';
import '../../../../models/materia.dart';
import '../logica_examenes.dart';
import 'pagina_sheet_examenes.dart';

class RouteSheetExamenes extends PageRoute<void> {
  RouteSheetExamenes({
    required this.careerId,
    required this.materia,
    required this.llamado1Eventos,
    required this.llamado2Eventos,
    required this.coloquioEventos,
    required this.detalleInicial,
    required this.mapaPlan,
  });

  final String careerId;
  final String materia;
  final List<ExamenEvent> llamado1Eventos;
  final List<ExamenEvent> llamado2Eventos;
  final List<ExamenEvent> coloquioEventos;
  final DetalleArgs? detalleInicial;
  final Map<String, Materia> mapaPlan;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => 'Exámenes';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 260);

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return PaginaSheetExamenes(
      careerId: careerId,
      materia: materia,
      llamado1Eventos: llamado1Eventos,
      llamado2Eventos: llamado2Eventos,
      coloquioEventos: coloquioEventos,
      detalleInicial: detalleInicial,
      mapaPlan: mapaPlan,
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child;
  }
}
