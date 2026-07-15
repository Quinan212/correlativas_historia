import 'package:flutter/material.dart';

import 'lista_opciones_sage.dart';

class PantallaModulosSage extends StatelessWidget {
  const PantallaModulosSage({
    super.key,
    required this.onOpenLegajo,
    required this.onRefresh,
    required this.onBack,
    this.loadingTitle,
  });

  final VoidCallback onOpenLegajo;
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  final String? loadingTitle;

  @override
  Widget build(BuildContext context) {
    final busy = loadingTitle != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        title: const Text('Estudiante'),
        leading: IconButton(
          tooltip: 'Cambiar perfil',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.manage_accounts_outlined),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: busy ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListaOpcionesSage(
          titulo: 'Servicios académicos',
          descripcion: 'Accedé a tus servicios académicos.',
          opciones: [
            ItemListaOpcionSage(
              titulo: 'Legajo Único Alumno',
              subtitulo: 'Acceso al historial académico',
              icono: Icons.school_outlined,
              enabled: !busy,
              available: true,
              highlighted: true,
              onTap: onOpenLegajo,
            ),
          ],
        ),
      ),
    );
  }
}
