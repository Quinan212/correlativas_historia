import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/notifications/push_notifications.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/supabase/supabase.dart';
import '../../../shared/widgets/whats_new_sheet.dart';
import '../../verification/models/verification_upload_image.dart';
import '../../verification/models/verification_request.dart';
import '../../verification/providers/verification_providers.dart';
import '../../verification/screens/verification_image_editor_screen.dart';
import '../../verification/widgets/verification_request_card.dart';
import '../providers/admin_access_providers.dart';
import 'admin_panel_screen.dart';

class AdminAccessScreen extends ConsumerStatefulWidget {
  const AdminAccessScreen({
    super.key,
    this.initialCareerId,
    this.initialMatterId,
    this.lockMatterSelection = false,
  });

  final String? initialCareerId;
  final String? initialMatterId;
  final bool lockMatterSelection;

  @override
  ConsumerState<AdminAccessScreen> createState() => _AdminAccessScreenState();
}

class _AdminAccessScreenState extends ConsumerState<AdminAccessScreen> {
  final Set<String> _notifiedReviewedRequestIds = <String>{};
  bool _reviewedRequestsSeeded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminAsync = ref.watch(adminDeviceStatusProvider);
    final bootstrap = ref.watch(supabaseBootstrapProvider);
    final ownRequestsAsync = ref.watch(ownVerificationRequestsProvider);
    final ownProfileAsync = ref.watch(ownDeviceProfileProvider);
    final deviceLabelAsync = ref.watch(deviceLabelProvider);

    ref.listen<AsyncValue<List<VerificationRequest>>>(
      ownVerificationRequestsProvider,
      _handleOwnRequestsUpdate,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _HeroCard(
              title: 'Verifica una materia',
              subtitle:
                  'Sube una captura del campus donde se vea esta materia. Cuando la aprobemos, desde este dispositivo vas a poder opinar sobre la materia y sus docentes.',
              icon: Icons.verified_user_rounded,
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Novedades',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta versión suma Opiniones, comunidad de la materia, referencias sobre docentes y notificaciones de seguimiento.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => WhatsNewSheet.show(context),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Ver novedades de esta versión'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!bootstrap.isReady)
              _SectionCard(
                title: 'Estado de Supabase',
                child: Text(
                  bootstrap.message,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            if (!bootstrap.isReady) const SizedBox(height: 14),
            _VerificationComposerCard(
              initialCareerId: widget.initialCareerId,
              initialMatterId: widget.initialMatterId,
              lockMatterSelection: widget.lockMatterSelection,
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Tus solicitudes',
              child: ownRequestsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      'Todavia no enviaste ninguna verificacion.',
                      style: theme.textTheme.bodyLarge,
                    );
                  }
                  final latestReviewed = _latestReviewedRequest(items);
                  return Column(
                    children: [
                      if (latestReviewed != null) ...[
                        _VerificationReadyBanner(request: latestReviewed),
                        const SizedBox(height: 12),
                      ],
                      ...items.map(
                          (item) => VerificationRequestCard(request: item)),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
                error: (error, _) => Text(
                  'No se pudieron cargar tus solicitudes: $error',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 14),
            adminAsync.when(
              data: (status) => _SectionCard(
                title: status.isAdmin ? 'Acceso admin' : 'Este dispositivo',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ownProfileAsync.when(
                      data: (profile) {
                        final detectedDeviceLabel =
                            deviceLabelAsync.valueOrNull ?? 'Dispositivo';
                        final effectiveDeviceLabel = _resolveDeviceLabel(
                          profile?.deviceLabel,
                          detectedDeviceLabel,
                        );
                        final referenceName =
                            (profile?.referenceName ?? '').trim();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (referenceName.isNotEmpty) ...[
                              Text(
                                'Nombre de referencia',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                referenceName,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 10),
                            ],
                            Text(
                              'Dispositivo detectado',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              effectiveDeviceLabel,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              profile == null
                                  ? 'Tus referencias publicas se muestran de forma anonima.'
                                  : profile.publicDisplayLabel ==
                                          'Referencia anonima'
                                      ? 'Tus referencias publicas se muestran de forma anonima.'
                                      : 'Tus referencias publicas usan el alias "${profile.publicDisplayLabel}".',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 14),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    Text(
                      _adminAccessCopy(status.isAdmin),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.invalidate(adminDeviceStatusProvider);
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refrescar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final client = ref.read(supabaseClientProvider);
                            if (client == null) return;

                            final deviceId = status.deviceId;
                            final deviceLabel =
                                await ref.read(deviceLabelProvider.future);
                            final currentProfile =
                                await ref.read(ownDeviceProfileProvider.future);
                            if (!context.mounted) return;
                            final draft = await showDeviceProfileSheet(
                              context: context,
                              deviceLabel: _resolveDeviceLabel(
                                currentProfile?.deviceLabel,
                                deviceLabel,
                              ),
                              initialProfile: currentProfile,
                            );
                            if (draft == null || !context.mounted) return;

                            final repo =
                                ref.read(deviceProfileRepositoryProvider);
                            await repo.upsertProfile(
                              client: client,
                              deviceId: deviceId,
                              deviceLabel: _resolveDeviceLabel(
                                currentProfile?.deviceLabel,
                                deviceLabel,
                              ),
                              referenceName: draft.referenceName,
                              publicMode: draft.publicMode,
                              publicAlias: draft.publicAlias,
                            );
                            ref.invalidate(ownDeviceProfileProvider);
                            ref.invalidate(deviceProfilesByIdsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil actualizado'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.badge_outlined),
                          label: const Text('Editar perfil'),
                        ),
                        if (status.isAdmin)
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => AdminPanelScreen(
                                    deviceId: status.deviceId,
                                    adminLabel: status.adminLabel,
                                  ),
                                ),
                              );
                            },
                            icon:
                                const Icon(Icons.admin_panel_settings_rounded),
                            label: const Text('Panel admin'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const _SectionCard(
                title: 'Este dispositivo',
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ),
              error: (error, _) => _SectionCard(
                title: 'Este dispositivo',
                child: Text(
                  'No se pudo resolver el acceso admin: $error',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOwnRequestsUpdate(
    AsyncValue<List<VerificationRequest>>? previous,
    AsyncValue<List<VerificationRequest>> next,
  ) {
    final items = next.valueOrNull;
    if (items == null || !mounted) return;

    final reviewed = items
        .where((item) => item.status != VerificationRequestStatus.pending)
        .toList(growable: false);

    if (!_reviewedRequestsSeeded) {
      _notifiedReviewedRequestIds.addAll(reviewed.map((item) => item.id));
      _reviewedRequestsSeeded = true;
      return;
    }

    for (final item in reviewed) {
      if (_notifiedReviewedRequestIds.add(item.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger == null) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(_verificationReadyMessage(item)),
              duration: const Duration(seconds: 5),
            ),
          );
        });
      }
    }
  }
}

VerificationRequest? _latestReviewedRequest(List<VerificationRequest> items) {
  final reviewed = items
      .where((item) => item.status != VerificationRequestStatus.pending)
      .toList(growable: false);
  if (reviewed.isEmpty) return null;

  reviewed.sort((a, b) {
    final aTime = a.reviewedAt ?? a.createdAt;
    final bTime = b.reviewedAt ?? b.createdAt;
    return bTime.compareTo(aTime);
  });
  return reviewed.first;
}

String _verificationReadyMessage(VerificationRequest request) {
  switch (request.status) {
    case VerificationRequestStatus.approved:
      return 'La verificación de ${request.matterName} ya quedó lista. Desde ahora podés compartir referencias sobre esta materia y sus docentes.';
    case VerificationRequestStatus.rejected:
      final note = (request.reviewNote ?? '').trim();
      final suffix = note.isEmpty
          ? ' Revisá la observación en la solicitud y, si hace falta, volvé a enviarla.'
          : ' Revisá la observación que quedó cargada y, si hace falta, volvé a enviarla.';
      return 'La revisión de ${request.matterName} ya quedó lista. Esta captura no alcanzó para habilitar la referencia.$suffix';
    case VerificationRequestStatus.pending:
      return 'Tu solicitud sigue en revisión.';
  }
}

class _VerificationReadyBanner extends StatelessWidget {
  const _VerificationReadyBanner({
    required this.request,
  });

  final VerificationRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = request.status == VerificationRequestStatus.approved;
    final background =
        approved ? const Color(0xFFE6F5F1) : const Color(0xFFF7ECE6);
    final foreground =
        approved ? const Color(0xFF195F56) : const Color(0xFF8A4D3A);
    final icon =
        approved ? Icons.mark_email_read_rounded : Icons.info_outline_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: foreground.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _verificationReadyMessage(request),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

      ref.invalidate(ownVerificationRequestsProvider);
      ref.invalidate(pendingVerificationRequestsProvider);

      if (mounted) {
        setState(() => _selectedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La verificacion se envio correctamente.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo enviar la verificacion: $error'),
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
    final currentProfile = await profileRepo.fetchProfile(
      client: client,
      deviceId: deviceId,
    );
    final existingLabel = currentProfile?.deviceLabel.trim();
    final effectiveLabel = _resolveDeviceLabel(existingLabel, currentLabel);

    if (currentProfile != null && !currentProfile.needsReferenceName) {
      if (currentProfile.deviceLabel.trim() != effectiveLabel) {
        await profileRepo.upsertProfile(
          client: client,
          deviceId: deviceId,
          deviceLabel: effectiveLabel,
          referenceName: currentProfile.referenceName ?? '',
          publicMode: currentProfile.publicMode,
          publicAlias: currentProfile.publicAlias,
        );
        ref.invalidate(ownDeviceProfileProvider);
      }
      return true;
    }

    if (!mounted) return false;
    final draft = await showDeviceProfileSheet(
      context: context,
      deviceLabel: effectiveLabel,
      initialProfile: currentProfile,
      forceReferenceName: true,
    );
    if (!mounted || draft == null) return false;

    await profileRepo.upsertProfile(
      client: client,
      deviceId: deviceId,
      deviceLabel: effectiveLabel,
      referenceName: draft.referenceName,
      publicMode: draft.publicMode,
      publicAlias: draft.publicAlias,
    );
    ref.invalidate(ownDeviceProfileProvider);
    ref.invalidate(deviceProfilesByIdsProvider);
    return true;
  }
}

String _resolveDeviceLabel(String? storedLabel, String detectedLabel) {
  final stored = (storedLabel ?? '').trim();
  final detected = detectedLabel.trim();
  if (stored.isEmpty) return detected;
  if (stored == 'Dispositivo Android') return detected;
  return stored;
}

String _adminAccessCopy(bool isAdmin) {
  if (isAdmin) {
    return 'Desde este dispositivo también puedes acompañar las solicitudes que llegan, revisar la evidencia y dejar una devolución cuando haga falta.';
  }
  return 'Desde aquí puedes enviar tu verificación y seguir la devolución cuando esté lista. Si hace falta volver a enviar una captura o ampliar alguna evidencia, también lo vas a ver en esta pantalla.';
}

String _verificationMatterLabel({required Materia matter}) {
  final raw = matter.displayNombre;
  switch (matter.id) {
    case 'procesos-antiguedad':
      return 'Antigüedad';
    case 'pueblos-originarios':
      return 'Pueblos originarios de América';
    case 'procesos-feudalismo-modernidad':
      return 'Feudalismo y modernidad';
    case 'procesos-americanos-1':
      return 'Americanos I';
    case 'procesos-contemporaneos-1':
      return 'Contemporáneos I';
    case 'procesos-americanos-2':
      return 'Americanos II';
    case 'procesos-argentina-1':
      return 'Argentina I';
    case 'procesos-contemporaneos-2':
      return 'Contemporáneos II';
    case 'procesos-americanos-3':
      return 'Americanos III';
    case 'procesos-argentina-2':
      return 'Argentina II';
    default:
      return raw;
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF005B7F).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF005B7F),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ],
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
