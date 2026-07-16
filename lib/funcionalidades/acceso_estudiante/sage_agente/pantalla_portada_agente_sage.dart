import 'package:flutter/material.dart';

import '../sage_navegacion/lista_opciones_sage.dart';
import 'modelos_agente_sage.dart';

class PantallaPortadaAgenteSage extends StatelessWidget {
  const PantallaPortadaAgenteSage({
    super.key,
    required this.onSelect,
    required this.onBack,
    required this.portada,
    this.busy = false,
  });

  final ValueChanged<OpcionAgenteSage> onSelect;
  final VoidCallback onBack;
  final bool busy;
  final PortadaAgenteSage portada;

  bool _isImplemented(OpcionAgenteSage option) =>
      option.claveCanonica == 'legajo_unico_alumno_superior';

  @override
  Widget build(BuildContext context) {
    final groups = <_GrupoAgente>[
      _GrupoAgente('Accesos principales', portada.accesosSuperiores),
      _GrupoAgente('Módulos', portada.modulos),
      _GrupoAgente('Submódulos', portada.submodulos),
      _GrupoAgente('Informes', portada.informes),
    ].where((group) => group.options.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        title: const Text('Docente'),
        leading: IconButton(
          tooltip: 'Cambiar perfil',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.manage_accounts_outlined),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
          children: [
            Text(
              'Servicios docentes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seleccioná una opción para continuar en SAGE.',
              style: TextStyle(height: 1.45),
            ),
            if (groups.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 28),
                child: Text('No se encontraron servicios disponibles.'),
              ),
            for (final group in groups) ...[
              const SizedBox(height: 26),
              Text(
                group.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              ListaOpcionesSage(
                titulo: '',
                descripcion: '',
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                opciones: [
                  for (final option in group.options)
                    ItemListaOpcionSage(
                      titulo: option.etiqueta,
                      subtitulo: option.sigla,
                      icono: IconData(
                        option.icono,
                        fontFamily: 'MaterialIcons',
                      ),
                      enabled: !busy,
                      available: _isImplemented(option),
                      highlighted: _isImplemented(option),
                      onTap: () => onSelect(option),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GrupoAgente {
  const _GrupoAgente(this.title, this.options);

  final String title;
  final List<OpcionAgenteSage> options;
}
