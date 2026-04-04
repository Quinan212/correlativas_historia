import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/supabase/supabase.dart';
import '../../admin_access/providers/admin_access_providers.dart';
import '../data/verification_repository.dart';
import '../models/matter_verification_state.dart';
import '../models/verification_request.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => const VerificationRepository(),
);

final verificationMatterOptionsProvider = Provider<List<VerificationMatterOption>>(
  (ref) {
    final plan = ref.watch(planProvider).valueOrNull;
    if (plan == null) return const <VerificationMatterOption>[];
    final items = plan.materias
        .map(
          (m) => VerificationMatterOption(
            id: m.id,
            name: m.displayNombre,
            year: m.anio,
          ),
        )
        .toList()
      ..sort((a, b) {
        final byYear = a.year.compareTo(b.year);
        if (byYear != 0) return byYear;
        return a.name.compareTo(b.name);
      });
    return items;
  },
);

final ownVerificationRequestsProvider =
    StreamProvider<List<VerificationRequest>>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    yield const <VerificationRequest>[];
    return;
  }

  final repo = ref.watch(verificationRepositoryProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  yield* repo.watchOwnRequests(client: client, deviceId: deviceId);
});

final approvedMatterIdsProvider = StreamProvider<Set<String>>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    yield const <String>{};
    return;
  }

  final repo = ref.watch(verificationRepositoryProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  yield* repo.watchApprovedMatterIds(client: client, deviceId: deviceId);
});

final pendingVerificationRequestsProvider =
    StreamProvider<List<VerificationRequest>>((ref) async* {
  final adminStatus = await ref.watch(adminDeviceStatusProvider.future);
  final client = ref.watch(supabaseClientProvider);
  if (client == null || !adminStatus.isAdmin) {
    yield const <VerificationRequest>[];
    return;
  }

  final repo = ref.watch(verificationRepositoryProvider);
  yield* repo.watchPendingRequests(client: client);
});

final reviewedVerificationRequestsProvider =
    StreamProvider<List<VerificationRequest>>((ref) async* {
  final adminStatus = await ref.watch(adminDeviceStatusProvider.future);
  final client = ref.watch(supabaseClientProvider);
  if (client == null || !adminStatus.isAdmin) {
    yield const <VerificationRequest>[];
    return;
  }

  final repo = ref.watch(verificationRepositoryProvider);
  yield* repo.watchReviewedRequests(client: client);
});

class VerificationMatterOption {
  const VerificationMatterOption({
    required this.id,
    required this.name,
    required this.year,
  });

  final String id;
  final String name;
  final int year;
}

final matterVerificationStateProvider =
    Provider.family<MatterVerificationState, String>((ref, matterId) {
  final requests = ref.watch(ownVerificationRequestsProvider).valueOrNull ??
      const <VerificationRequest>[];
  final approvedMatterIds =
      ref.watch(approvedMatterIdsProvider).valueOrNull ?? const <String>{};

  if (approvedMatterIds.contains(matterId)) {
    final approvedRequest = requests
        .where((item) => item.matterId == matterId)
        .where((item) => item.status == VerificationRequestStatus.approved)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return MatterVerificationState(
      status: MatterVerificationStatus.approved,
      request: approvedRequest.isEmpty ? null : approvedRequest.first,
    );
  }

  final matching = requests.where((item) => item.matterId == matterId).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  VerificationRequest? latest(VerificationRequestStatus status) {
    for (final item in matching) {
      if (item.status == status) return item;
    }
    return null;
  }

  final approved = latest(VerificationRequestStatus.approved);
  if (approved != null) {
    return MatterVerificationState(
      status: MatterVerificationStatus.approved,
      request: approved,
    );
  }

  final pending = latest(VerificationRequestStatus.pending);
  if (pending != null) {
    return MatterVerificationState(
      status: MatterVerificationStatus.pending,
      request: pending,
    );
  }

  final rejected = latest(VerificationRequestStatus.rejected);
  if (rejected != null) {
    return MatterVerificationState(
      status: MatterVerificationStatus.rejected,
      request: rejected,
    );
  }

  return const MatterVerificationState(
    status: MatterVerificationStatus.unverified,
  );
});
