// lib/features/examenes/sheet/route_sheet_examenes.dart
import 'package:flutter/material.dart';

import '../../models/examen_event.dart';
import '../logica_examenes.dart';
import 'pagina_sheet_examenes.dart';

class RouteSheetExamenes extends PageRoute<void> {
  RouteSheetExamenes({
    required this.materia,
    required this.llamado1,
    required this.llamado2,
    required this.detalleInicial,
  });

  final String materia;
  final ExamenEvent? llamado1;
  final ExamenEvent? llamado2;
  final DetalleArgs? detalleInicial;

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
      materia: materia,
      llamado1: llamado1,
      llamado2: llamado2,
      detalleInicial: detalleInicial,
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