part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _HojaRegistroInvitado extends StatefulWidget {
  const _HojaRegistroInvitado({required this.onStart});

  final void Function(String name, String careerId) onStart;

  @override
  State<_HojaRegistroInvitado> createState() => _HojaRegistroInvitadoState();
}

class _HojaRegistroInvitadoState extends State<_HojaRegistroInvitado> {
  final _nameCtrl = TextEditingController(text: 'Invitado');
  String _selectedCareer = 'historia';

  List<CareerInfo> get _sheetCareers => kCareers
      .where((c) => [
            'artes_visuales',
            'historia',
            'geografia',
            'politica',
            'musica',
          ].contains(c.id))
      .toList();

  Widget _buildCareerRow(CareerInfo c, ColorScheme scheme) {
    final hasIcon = c.iconAsset != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIcon) ...[
          Container(
            width: 22,
            height: 22,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.asset(
              c.iconAsset!,
              fit: BoxFit.cover,
              cacheWidth: 64,
              cacheHeight: 64,
              filterQuality: FilterQuality.low,
              errorBuilder: (_, _, _) => Icon(
                Icons.school_rounded,
                size: 18,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            c.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    final name =
        _nameCtrl.text.trim().isEmpty ? 'Invitado' : _nameCtrl.text.trim();
    widget.onStart(name, _selectedCareer);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        32 + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Perfil de Invitado',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Completá estos datos para armar tu plan de estudios personalizado.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.outlineVariant,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCareer,
                      isExpanded: true,
                      menuWidth: constraints.maxWidth,
                      menuMaxHeight: 400,
                      dropdownColor: scheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                      selectedItemBuilder: (context) {
                        return _sheetCareers.map((c) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: _buildCareerRow(c, scheme),
                          );
                        }).toList(growable: false);
                      },
                      items: _sheetCareers
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildCareerRow(c, scheme),
                                  ),
                                  if (c.id == _selectedCareer) ...[
                                    Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: scheme.primary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedCareer = v);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Comenzar'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
