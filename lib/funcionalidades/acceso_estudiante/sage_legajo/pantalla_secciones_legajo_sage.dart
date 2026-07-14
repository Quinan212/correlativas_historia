import 'package:flutter/material.dart';

import 'modelos_legajo_sage.dart';

class PantallaSeccionesLegajoSage extends StatelessWidget {
  const PantallaSeccionesLegajoSage({
    super.key,
    required this.secciones,
    required this.onSelect,
    required this.onBack,
    this.loadingTitle,
  });

  final List<SeccionLegajoSage> secciones;
  final ValueChanged<SeccionLegajoSage> onSelect;
  final VoidCallback onBack;
  final String? loadingTitle;

  @override
  Widget build(BuildContext context) {
    final busy = loadingTitle != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        title: const Text('Mi legajo'),
        leading: IconButton(
          tooltip: 'Volver al acceso estudiantil',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          itemCount: secciones.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const ListTile(
                contentPadding: EdgeInsets.only(bottom: 12),
                title: Text(
                  'Secciones',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Elegí la información que querés consultar.'),
                ),
              );
            }
            final section = secciones[index - 1];
            final isSchool =
                normalizarLegajoSage(section.titulo) == 'escolares';
            return ListTile(
              enabled: !busy,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: Icon(
                isSchool ? Icons.school_outlined : Icons.folder_outlined,
              ),
              title: Text(section.titulo),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: busy ? null : () => onSelect(section),
            );
          },
        ),
      ),
    );
  }
}
