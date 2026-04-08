import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../../verification/providers/verification_providers.dart';
import '../data/opiniones_reviews_repository.dart';
import '../models/matter_photo_post.dart';
import '../models/opiniones_rating.dart';
import '../models/opiniones_review_models.dart';

final opinionesReviewsRepositoryProvider = Provider<OpinionesReviewsRepository>(
  (ref) => const OpinionesReviewsRepository(),
);

final matterReviewsProvider = StreamProvider.autoDispose
    .family<List<MatterReview>, String>((ref, matterId) async* {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    yield const <MatterReview>[];
    return;
  }

  final repo = ref.watch(opinionesReviewsRepositoryProvider);
  yield* repo.watchMatterReviews(client: client, matterId: matterId);
});

final ownMatterReviewProvider = FutureProvider.autoDispose
    .family<MatterReview?, String>((ref, matterId) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return null;
  }

  final repo = ref.watch(opinionesReviewsRepositoryProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  return repo.fetchOwnMatterReview(
    client: client,
    deviceId: deviceId,
    matterId: matterId,
  );
});

final matterReviewSummaryProvider =
    Provider.autoDispose.family<MatterReviewSummary, String>((ref, matterId) {
  final repo = ref.watch(opinionesReviewsRepositoryProvider);
  final reviews = ref.watch(matterReviewsProvider(matterId)).valueOrNull ??
      const <MatterReview>[];
  return repo.summarizeMatter(reviews);
});

final matterPhotoPostsProvider = StreamProvider.autoDispose
    .family<List<MatterPhotoPost>, String>((ref, matterId) async* {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    yield const <MatterPhotoPost>[];
    return;
  }

  final repo = ref.watch(opinionesReviewsRepositoryProvider);
  yield* repo.watchMatterPhotoPosts(client: client, matterId: matterId);
});

final teacherReviewsProvider = StreamProvider.autoDispose
    .family<List<TeacherReview>, String>((ref, teacherId) async* {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    yield const <TeacherReview>[];
    return;
  }

  final repo = ref.watch(opinionesReviewsRepositoryProvider);
  yield* repo.watchTeacherReviews(client: client, teacherId: teacherId);
});

final ownTeacherReviewsForMatterProvider =
    FutureProvider.autoDispose.family<Map<String, TeacherReview>, String>((
  ref,
  matterId,
) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return const <String, TeacherReview>{};
  }

  final repo = ref.watch(opinionesReviewsRepositoryProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  return repo.fetchOwnTeacherReviewsForMatter(
    client: client,
    deviceId: deviceId,
    matterId: matterId,
  );
});

final ownTeacherReviewProvider =
    Provider.family<AsyncValue<TeacherReview?>, TeacherReviewScope>(
        (ref, scope) {
  final reviewsAsync =
      ref.watch(ownTeacherReviewsForMatterProvider(scope.matterId));
  return reviewsAsync.whenData((reviews) => reviews[scope.teacherId]);
});

final teacherReviewSummaryProvider =
    Provider.autoDispose.family<DocenteRatingResumen, String>((ref, teacherId) {
  final repo = ref.watch(opinionesReviewsRepositoryProvider);
  final reviews = ref.watch(teacherReviewsProvider(teacherId)).valueOrNull ??
      const <TeacherReview>[];
  return repo.summarizeTeacher(reviews);
});

final matterCanReviewProvider = Provider.family<bool, String>((ref, matterId) {
  return ref.watch(matterVerificationStateProvider(matterId)).canReview;
});
