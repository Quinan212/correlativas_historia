import 'package:flutter/material.dart';

class HojaRegistroInvitado extends StatefulWidget {
  const HojaRegistroInvitado({super.key, required this.onStart});

  final void Function(String name, String dni, String careerId) onStart;

  @override
  State<HojaRegistroInvitado> createState() => _HojaRegistroInvitadoState();
}

class _HojaRegistroInvitadoState extends State<HojaRegistroInvitado> {
  final _nameCtrl = TextEditingController(text: 'Invitado');
  final _dniCtrl = TextEditingController();
  String _selectedCareer = 'historia';

  final _careers = const {
    'artes_visuales': 'Artes Visuales',
    'historia': 'Historia',
    'geografia': 'Geografía',
    'politica': 'Ciencias Políticas',
  };

  void _submit() {
    final name = _nameCtrl.text.trim().isEmpty
        ? 'Invitado'
        : _nameCtrl.text.trim();
    final dni = _dniCtrl.text.replaceAll(RegExp(r'\D'), '').trim();
    widget.onStart(name, dni, _selectedCareer);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dniCtrl.dispose();
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
          TextField(
            controller: _dniCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'DNI (opcional)',
              prefixIcon: Icon(Icons.badge_rounded),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedCareer,
            decoration: const InputDecoration(
              labelText: 'Carrera que cursás',
              prefixIcon: Icon(Icons.school_rounded),
            ),
            items: _careers.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCareer = value);
              }
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
    );
  }
}
