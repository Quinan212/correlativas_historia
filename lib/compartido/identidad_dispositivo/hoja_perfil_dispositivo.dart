import 'package:flutter/material.dart';

import 'perfil_dispositivo.dart';

class BorradorPerfilDispositivo {
  const BorradorPerfilDispositivo({
    required this.referenceName,
    required this.publicMode,
    this.publicAlias,
  });

  final String referenceName;
  final ModoPublicoPerfilDispositivo publicMode;
  final String? publicAlias;
}

Future<BorradorPerfilDispositivo?> mostrarHojaPerfilDispositivo({
  required BuildContext context,
  required String deviceLabel,
  PerfilDispositivo? initialProfile,
  bool forceReferenceName = false,
}) {
  return showModalBottomSheet<BorradorPerfilDispositivo>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PerfilDispositivoSheet(
      deviceLabel: deviceLabel,
      initialProfile: initialProfile,
      forceReferenceName: forceReferenceName,
    ),
  );
}

class _PerfilDispositivoSheet extends StatefulWidget {
  const _PerfilDispositivoSheet({
    required this.deviceLabel,
    required this.forceReferenceName,
    this.initialProfile,
  });

  final String deviceLabel;
  final PerfilDispositivo? initialProfile;
  final bool forceReferenceName;

  @override
  State<_PerfilDispositivoSheet> createState() =>
      _PerfilDispositivoSheetState();
}

class _PerfilDispositivoSheetState extends State<_PerfilDispositivoSheet> {
  late final TextEditingController _referenceNameCtrl;
  late final TextEditingController _aliasCtrl;
  late ModoPublicoPerfilDispositivo _publicMode;

  @override
  void initState() {
    super.initState();
    _referenceNameCtrl = TextEditingController(
      text: widget.initialProfile?.referenceName ?? '',
    );
    _aliasCtrl = TextEditingController(
      text: widget.initialProfile?.publicAlias ?? '',
    );
    _publicMode = widget.initialProfile?.publicMode ??
        ModoPublicoPerfilDispositivo.anonymous;
  }

  @override
  void dispose() {
    _referenceNameCtrl.dispose();
    _aliasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + insets.bottom),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.forceReferenceName
                        ? 'Configura tu referencia'
                        : 'Perfil del dispositivo',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu nombre de referencia solo se usa para verificar solicitudes. Las referencias publicas se muestran como anonimas por defecto.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _referenceNameCtrl,
                    maxLength: 40,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de referencia',
                      hintText: 'Ej: Alan',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Dispositivo detectado',
                    ),
                    child: Text(widget.deviceLabel),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Visibilidad publica',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<ModoPublicoPerfilDispositivo>(
                    segments: const [
                      ButtonSegment<ModoPublicoPerfilDispositivo>(
                        value: ModoPublicoPerfilDispositivo.anonymous,
                        label: Text('Anonima'),
                      ),
                      ButtonSegment<ModoPublicoPerfilDispositivo>(
                        value: ModoPublicoPerfilDispositivo.alias,
                        label: Text('Alias'),
                      ),
                    ],
                    selected: {_publicMode},
                    onSelectionChanged: (selection) {
                      setState(() => _publicMode = selection.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_publicMode == ModoPublicoPerfilDispositivo.alias)
                    TextField(
                      controller: _aliasCtrl,
                      maxLength: 40,
                      decoration: const InputDecoration(
                        labelText: 'Alias publico',
                        hintText: 'Ej: Alan M.',
                      ),
                    ),
                  if (_publicMode == ModoPublicoPerfilDispositivo.anonymous)
                    Text(
                      'Tus referencias publicas se veran como "Referencia anonima".',
                      style: theme.textTheme.bodySmall,
                    ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar perfil'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    final referenceName = _referenceNameCtrl.text.trim();
    if (referenceName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un nombre de referencia para continuar.'),
        ),
      );
      return;
    }

    if (_publicMode == ModoPublicoPerfilDispositivo.alias &&
        _aliasCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Si eliges alias, completa el alias publico.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      BorradorPerfilDispositivo(
        referenceName: referenceName,
        publicMode: _publicMode,
        publicAlias: _publicMode == ModoPublicoPerfilDispositivo.alias
            ? _aliasCtrl.text.trim()
            : null,
      ),
    );
  }
}
