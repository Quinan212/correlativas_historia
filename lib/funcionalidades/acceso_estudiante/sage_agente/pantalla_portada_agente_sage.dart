import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';
import '../sage_navegacion/lista_opciones_sage.dart';
import 'modelos_agente_sage.dart';

class PantallaPortadaAgenteSage extends StatefulWidget {
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

  @override
  State<PantallaPortadaAgenteSage> createState() =>
      _PantallaPortadaAgenteSageState();
}

class _PantallaPortadaAgenteSageState extends State<PantallaPortadaAgenteSage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isImplemented(OpcionAgenteSage option) =>
      option.claveCanonica == 'legajo_unico_alumno_superior';

  List<_GrupoAgente> get _groups {
    final query = _normalize(_query);
    final all = <_GrupoAgente>[
      _GrupoAgente('Accesos principales', widget.portada.accesosSuperiores),
      _GrupoAgente('Módulos', widget.portada.modulos),
      _GrupoAgente('Submódulos', widget.portada.submodulos),
      _GrupoAgente('Informes', widget.portada.informes),
    ];
    return all
        .map(
          (group) => _GrupoAgente(
            group.title,
            query.isEmpty
                ? group.options
                : group.options
                      .where((option) {
                        return _normalize(
                          '${option.etiqueta} ${option.sigla ?? ''}',
                        ).contains(query);
                      })
                      .toList(growable: false),
          ),
        )
        .where((group) => group.options.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    return Scaffold(
      appBar: construirAppBarSage(
        context,
        title: 'Docente',
        leading: IconButton(
          tooltip: 'Cambiar perfil',
          onPressed: widget.busy ? null : widget.onBack,
          icon: const Icon(Icons.manage_accounts_outlined),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            Text(
              'Servicios docentes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Seleccioná una opción para continuar en SAGE.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: decoracionBusquedaSage(
                context,
                hintText: 'Buscar servicios de SAGE',
                showClear: _query.isNotEmpty,
                onClear: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: decoracionPanelSage(context),
                  child: const Text(
                    'No hay servicios que coincidan con la búsqueda.',
                  ),
                ),
              ),
            for (final group in groups) ...[
              const SizedBox(height: 22),
              Text(
                group.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ListaOpcionesSage(
                titulo: '',
                descripcion: '',
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mostrarBusqueda: false,
                opciones: [
                  for (final option in group.options)
                    ItemListaOpcionSage(
                      titulo: option.etiqueta,
                      subtitulo: option.sigla,
                      icono: iconoMaterialSage(option.icono),
                      enabled: !widget.busy,
                      available: _isImplemented(option),
                      highlighted: _isImplemented(option),
                      onTap: () => widget.onSelect(option),
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

String _normalize(String value) {
  const replacements = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  var output = value.toLowerCase();
  replacements.forEach((key, replacement) {
    output = output.replaceAll(key, replacement);
  });
  return output.replaceAll(RegExp(r'\s+'), ' ').trim();
}
