import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/verification_request.dart';
import '../providers/verification_providers.dart';
import '../widgets/verification_request_card.dart';

class VerificationRequestsScreen extends ConsumerWidget {
  const VerificationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ownRequestsAsync = ref.watch(ownVerificationRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus solicitudes'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(ownVerificationRequestsProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SectionCard(
              title: 'Tus verificaciones',
              child: ownRequestsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      'Todavía no enviaste ninguna verificación.',
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
                        (item) => VerificationRequestCard(request: item),
                      ),
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
          ],
        ),
      ),
    );
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
  const _VerificationReadyBanner({required this.request});

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
        border: Border.all(color: foreground.withValues(alpha: 0.22)),
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
