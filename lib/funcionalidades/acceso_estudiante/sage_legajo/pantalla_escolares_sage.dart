import 'package:flutter/material.dart';

import 'modelos_legajo_sage.dart';

class PantallaEscolaresSage extends StatelessWidget {
  const PantallaEscolaresSage({
    super.key,
    required this.opciones,
    required this.onSelect,
    required this.onBack,
    this.loadingTitle,
  });

  final List<OpcionEscolarSage> opciones;
  final ValueChanged<OpcionEscolarSage> onSelect;
  final VoidCallback onBack;
  final String? loadingTitle;

  @override
  Widget build(BuildContext context) {
    final busy = loadingTitle != null;
    final unique = <String, OpcionEscolarSage>{
      for (final option in opciones)
        if (option.clave.isNotEmpty) option.clave: option,
    };
    unique.putIfAbsent(
      'nivel_superior_historial',
      () => const OpcionEscolarSage(
        clave: 'nivel_superior_historial',
        titulo: 'Nivel Superior - Historial',
        firmaTecnica: 'contract:nivel_superior_historial',
        frameId: 'frm_alumnos',
        pathname: '/dic/tabs.php',
        controlEncontrado: false,
      ),
    );
    final orderedOptions = [
      unique.remove('nivel_superior_historial')!,
      ...unique.values,
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        title: const Text('Escolares'),
        leading: IconButton(
          tooltip: 'Volver al acceso estudiantil',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          itemCount: orderedOptions.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const ListTile(
                contentPadding: EdgeInsets.only(bottom: 12),
                title: Text(
                  'Información académica',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Seleccioná una opción para continuar.'),
                ),
              );
            }
            final option = orderedOptions[index - 1];
            final isHistory = normalizarLegajoSage(
              option.titulo,
            ).contains('nivel superior - historial');
            return ListTile(
              enabled: !busy,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: Icon(
                isHistory ? Icons.history_edu_outlined : Icons.school_outlined,
              ),
              title: Text(option.titulo),
              subtitle: isHistory
                  ? const Text(
                      'Consultá carreras, materias, estados y documentos académicos.',
                    )
                  : null,
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: busy ? null : () => onSelect(option),
            );
          },
        ),
      ),
    );
  }
}
