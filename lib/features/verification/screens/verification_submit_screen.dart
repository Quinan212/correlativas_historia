import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/notifications/push_notifications.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/supabase/supabase.dart';
import '../models/verification_upload_image.dart';
import '../providers/verification_providers.dart';
import 'verification_image_editor_screen.dart';

class VerificationSubmitScreen extends StatelessWidget {
  const VerificationSubmitScreen({
    super.key,
    this.initialCareerId,
    this.initialMatterId,
    this.lockMatterSelection = false,
  });

  final String? initialCareerId;
  final String? initialMatterId;
  final bool lockMatterSelection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar verificación')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const _HeroCard(
              title: 'Subí tu captura',
              subtitle:
                  'Elegí la materia, subí una imagen del campus o del aula virtual, y enviá la verificación.',
              icon: Icons.verified_user_rounded,
            ),
            const SizedBox(height: 14),
            _VerificationComposerCard(
              initialCareerId: initialCareerId,
              initialMatterId: initialMatterId,
              lockMatterSelection: lockMatterSelection,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationComposerCard extends ConsumerStatefulWidget {
  const _VerificationComposerCard({
    this.initialCareerId,
    this.initialMatterId,
    this.lockMatterSelection = false,
  });

  final String? initialCareerId;
  final String? initialMatterId;
  final bool lockMatterSelection;

  @override
  ConsumerState<_VerificationComposerCard> createState() =>
      _VerificationComposerCardState();
}

class _VerificationComposerCardState
    extends ConsumerState<_VerificationComposerCard> {
  String? _selectedMatterId;
  int? _selectedYear;
  VerificationUploadImage? _selectedImage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedMatterId = widget.initialMatterId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentCareer = ref.read(selectedCareerInfoOrNullProvider);
      final targetCareer = widget.initialCareerId ?? 'historia';
      if (currentCareer?.id == targetCareer) return;
      ref.read(selectedCareerIdProvider.notifier).state = targetCareer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planAsync = ref.watch(planProvider);
    final selectedCareer = ref.watch(selectedCareerInfoProvider);
    final careers = ref
        .watch(careersProvider)
        .where((career) => career.id == 'historia')
        .toList(growable: false);
    final selectedCareerOrNull = ref.watch(selectedCareerInfoOrNullProvider);

    return _SectionCard(
      title: 'Enviar verificación',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (careers.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: selectedCareer.id,
              decoration: const InputDecoration(
                labelText: 'Carrera',
              ),
              items: careers
                  .map(
                    (career) => DropdownMenuItem<String>(
                      value: career.id,
                      child: Text(
                        career.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              selectedItemBuilder: (context) => careers
                  .map(
                    (career) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        career.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (_submitting || widget.lockMatterSelection)
                  ? null
                  : (value) {
                      if (value == null) return;
                      ref.read(selectedCareerIdProvider.notifier).state = value;
                      setState(() {
                        _selectedMatterId = null;
                      });
                    },
            ),
            const SizedBox(height: 14),
          ],
          planAsync.when(
            data: (plan) {
              final options = plan.materias.toList()
                ..sort((a, b) {
                  final byYear = a.anio.compareTo(b.anio);
                  if (byYear != 0) return byYear;
                  return a.displayNombre.compareTo(b.displayNombre);
                });

              if (options.isEmpty) {
                return Text(
                  selectedCareerOrNull == null
                      ? 'Elige una carrera para ver sus materias.'
                      : 'No hay materias disponibles para la carrera seleccionada.',
                  style: theme.textTheme.bodyLarge,
                );
              }

              _selectedMatterId ??= widget.initialMatterId ?? options.first.id;
              final selectedFromAll = options.firstWhere(
                (m) => m.id == _selectedMatterId,
                orElse: () => options.first,
              );
              _selectedYear ??= selectedFromAll.anio;

              final availableYears = options
                  .map((m) => m.anio)
                  .toSet()
                  .toList(growable: false)
                ..sort();
              if (!availableYears.contains(_selectedYear)) {
                _selectedYear = availableYears.first;
              }

              final yearOptions = options
                  .where((m) => m.anio == _selectedYear)
                  .toList(growable: false);
              if (yearOptions.isEmpty) {
                return Text(
                  'No hay materias cargadas para el año seleccionado.',
                  style: theme.textTheme.bodyLarge,
                );
              }

              if (!yearOptions.any((m) => m.id == _selectedMatterId)) {
                _selectedMatterId = yearOptions.first.id;
              }

              final selected = yearOptions.firstWhere(
                (m) => m.id == _selectedMatterId,
                orElse: () => yearOptions.first,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elegí la materia y subí una captura donde se vea claramente el aula virtual o la inscripción en el campus.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _selectedYear,
                    menuMaxHeight: 420,
                    decoration: const InputDecoration(
                      labelText: 'Año',
                    ),
                    items: availableYears
                        .map(
                          (year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year° año'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (_submitting || widget.lockMatterSelection)
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedYear = value;
                              _selectedMatterId = options
                                  .firstWhere(
                                    (m) => m.anio == value,
                                    orElse: () => options.first,
                                  )
                                  .id;
                            });
                          },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selected.id,
                    menuMaxHeight: 420,
                    decoration: const InputDecoration(
                      labelText: 'Materia',
                    ),
                    items: yearOptions
                        .map(
                          (m) => DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(
                              _verificationMatterLabel(matter: m),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    selectedItemBuilder: (context) => yearOptions
                        .map(
                          (m) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _verificationMatterLabel(matter: m),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (_submitting || widget.lockMatterSelection)
                        ? null
                        : (value) {
                            setState(() => _selectedMatterId = value);
                          },
                  ),
                  const SizedBox(height: 14),
                  if (_selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _selectedImage!.bytes,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_selectedImage != null) const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _submitting ? null : _pickImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _selectedImage == null
                              ? 'Elegir imagen'
                              : 'Cambiar imagen',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: (_submitting || _selectedImage == null)
                            ? null
                            : () => _submit(
                                  matterId: selected.id,
                                  matterName: selected.displayNombre,
                                  careerId: selectedCareer.id,
                                ),
                        icon: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_upload_rounded),
                        label: Text(_submitting ? 'Enviando...' : 'Enviar'),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(minHeight: 3),
            ),
            error: (error, _) => Text(
              'No se pudieron cargar las materias: $error',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final repo = ref.read(verificationRepositoryProvider);
    final sourceImage = await repo.pickImage();
    if (!mounted || sourceImage == null) return;

    final editedImage =
        await Navigator.of(context).push<VerificationUploadImage>(
      MaterialPageRoute<VerificationUploadImage>(
        builder: (_) => VerificationImageEditorScreen(sourceImage: sourceImage),
      ),
    );
    if (!mounted || editedImage == null) return;

    setState(() => _selectedImage = editedImage);
  }

  Future<void> _submit({
    required String matterId,
    required String matterName,
    required String careerId,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supabase no esta listo todavia.'),
          ),
        );
      }
      return;
    }

    final image = _selectedImage;
    if (image == null) return;

    setState(() => _submitting = true);
    try {
      final repo = ref.read(verificationRepositoryProvider);
      final deviceId = await ref.read(deviceIdProvider.future);
      final profileReady = await _ensureDeviceProfile(deviceId: deviceId);
      if (!profileReady) return;
      if (!mounted) return;
      await PushNotificationsService.instance.ensurePermissionForVerification(
        context: context,
      );
      if (!mounted) return;
      await repo.submitRequest(
        client: client,
        deviceId: deviceId,
        matterId: matterId,
        matterName: matterName,
        careerId: careerId,
        image: image,
      );

      if (mounted) {
        setState(() => _selectedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La verificación se envió correctamente.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo enviar la verificación: $error'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<bool> _ensureDeviceProfile({required String deviceId}) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return false;

    final profileRepo = ref.read(deviceProfileRepositoryProvider);
    final currentLabel = await ref.read(deviceLabelProvider.future);
    final existingProfile = await ref.read(ownDeviceProfileProvider.future);
    final needsProfile = existingProfile == null ||
        existingProfile.needsReferenceName ||
        existingProfile.deviceLabel.trim().isEmpty;
    if (!needsProfile) {
      return true;
    }

    if (!mounted) return false;

    final draft = await showDeviceProfileSheet(
      context: context,
      deviceLabel: existingProfile?.deviceLabel.isNotEmpty == true
          ? existingProfile!.deviceLabel
          : currentLabel,
      initialProfile: existingProfile,
      forceReferenceName: true,
    );
    if (draft == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Necesitas configurar tu nombre de referencia.'),
          ),
        );
      }
      return false;
    }

    await profileRepo.upsertProfile(
      client: client,
      deviceId: deviceId,
      deviceLabel: currentLabel,
      referenceName: draft.referenceName,
      publicMode: draft.publicMode,
      publicAlias: draft.publicAlias,
    );
    ref.invalidate(ownDeviceProfileProvider);
    return true;
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

String _verificationMatterLabel({required Materia matter}) {
  final code = matter.codigo.trim();
  final name = matter.displayNombre.trim();
  if (code.isEmpty) return name;
  return '$code · $name';
}
