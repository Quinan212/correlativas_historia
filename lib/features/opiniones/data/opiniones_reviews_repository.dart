import 'dart:math' as math;

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../verification/models/verification_upload_image.dart';
import '../models/opiniones_rating.dart';
import '../models/matter_photo_post.dart';
import '../models/opiniones_review_models.dart';
import '../utils/referencias_labels.dart';

class OpinionesReviewsRepository {
  const OpinionesReviewsRepository();

  static const String matterPhotosBucketName = 'matter-community-photos';
  static const int _maxPhotoWidth = 1600;
  static const int _photoQuality = 70;

  Future<XFile?> pickMatterPhoto() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxPhotoWidth.toDouble(),
      imageQuality: _photoQuality,
    );
  }

  Future<MatterPhotoPost> createMatterPhotoPost({
    required SupabaseClient client,
    required String deviceId,
    required String matterId,
    required String careerId,
    required VerificationUploadImage image,
    String? caption,
  }) async {
    final bytes = image.bytes;
    final ext = _fileExtension(image.fileName);
    final now = DateTime.now().toUtc().toIso8601String();
    final path =
        '$matterId/$deviceId/${DateTime.now().millisecondsSinceEpoch}_${_randHex(6)}.$ext';

    await client.storage.from(matterPhotosBucketName).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentTypeFor(ext),
            upsert: false,
          ),
        );

    final publicUrl = client.storage.from(matterPhotosBucketName).getPublicUrl(
          path,
        );

    late final Map<String, dynamic> inserted;
    try {
      inserted = await client
          .from('matter_photo_posts')
          .insert({
            'device_id': deviceId,
            'matter_id': matterId,
            'career_id': careerId,
            'image_path': path,
            'image_url': publicUrl,
            'caption': _nullIfBlank(caption),
            'enabled': true,
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();
    } catch (error) {
      try {
        await client.storage.from(matterPhotosBucketName).remove([path]);
      } catch (_) {
        // Ignore cleanup failure, the row insert error is the primary failure.
      }
      rethrow;
    }

    return MatterPhotoPost.fromMap(inserted);
  }

  Future<void> deleteMatterPhotoPost({
    required SupabaseClient client,
    required String adminDeviceId,
    required String photoId,
  }) async {
    await client.functions.invoke(
      'delete-matter-photo-post',
      body: {
        'device_id': adminDeviceId,
        'photo_id': photoId,
      },
    );
  }

  Stream<List<MatterPhotoPost>> watchMatterPhotoPosts({
    required SupabaseClient client,
    required String matterId,
  }) {
    return client
        .from('matter_photo_posts')
        .stream(primaryKey: ['id'])
        .eq('matter_id', matterId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .cast<Map<String, dynamic>>()
              .map(MatterPhotoPost.fromMap)
              .where((post) => post.enabled)
              .toList(growable: false),
        );
  }

  Stream<List<MatterReview>> watchMatterReviews({
    required SupabaseClient client,
    required String matterId,
  }) {
    return client
        .from('matter_reviews')
        .stream(primaryKey: ['id'])
        .eq('matter_id', matterId)
        .order('updated_at', ascending: false)
        .map(
          (rows) => rows
              .cast<Map<String, dynamic>>()
              .map(MatterReview.fromMap)
              .toList(growable: false),
        );
  }

  Stream<MatterReview?> watchOwnMatterReview({
    required SupabaseClient client,
    required String deviceId,
    required String matterId,
  }) {
    return client
        .from('matter_reviews')
        .stream(primaryKey: ['id'])
        .eq('device_id', deviceId)
        .map(
          (rows) {
            final filtered = rows
                .cast<Map<String, dynamic>>()
                .map(MatterReview.fromMap)
                .where((row) => row.matterId == matterId);
            return filtered.isEmpty ? null : filtered.first;
          },
        );
  }

  Future<MatterReview?> fetchOwnMatterReview({
    required SupabaseClient client,
    required String deviceId,
    required String matterId,
  }) async {
    final row = await client
        .from('matter_reviews')
        .select()
        .eq('device_id', deviceId)
        .eq('matter_id', matterId)
        .maybeSingle();
    if (row == null) return null;
    return MatterReview.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> upsertMatterReview({
    required SupabaseClient client,
    required String deviceId,
    required String matterId,
    required String careerId,
    required int rating,
    required Map<String, int> dimensions,
    String? comment,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final tags = dimensions.entries
        .where((entry) => entry.value >= 4)
        .map((entry) => entry.key)
        .toList(growable: false);
    await client.from('matter_reviews').upsert({
      'device_id': deviceId,
      'matter_id': matterId,
      'career_id': careerId,
      'rating': rating,
      'dimensions': dimensions,
      'tags': tags,
      'comment': _nullIfBlank(comment),
      'created_at': now,
      'updated_at': now,
    }, onConflict: 'device_id,matter_id').select();
  }

  Stream<List<TeacherReview>> watchTeacherReviews({
    required SupabaseClient client,
    required String teacherId,
  }) {
    return client
        .from('teacher_reviews')
        .stream(primaryKey: ['id'])
        .eq('teacher_id', teacherId)
        .order('updated_at', ascending: false)
        .map(
          (rows) => rows
              .cast<Map<String, dynamic>>()
              .map(TeacherReview.fromMap)
              .toList(growable: false),
        );
  }

  Stream<TeacherReview?> watchOwnTeacherReview({
    required SupabaseClient client,
    required String deviceId,
    required TeacherReviewScope scope,
  }) {
    return client
        .from('teacher_reviews')
        .stream(primaryKey: ['id'])
        .eq('device_id', deviceId)
        .map(
          (rows) {
            final filtered = rows
                .cast<Map<String, dynamic>>()
                .map(TeacherReview.fromMap)
                .where(
                  (row) =>
                      row.teacherId == scope.teacherId &&
                      row.matterId == scope.matterId,
                );
            return filtered.isEmpty ? null : filtered.first;
          },
        );
  }

  Future<TeacherReview?> fetchOwnTeacherReview({
    required SupabaseClient client,
    required String deviceId,
    required TeacherReviewScope scope,
  }) async {
    final row = await client
        .from('teacher_reviews')
        .select()
        .eq('device_id', deviceId)
        .eq('teacher_id', scope.teacherId)
        .eq('matter_id', scope.matterId)
        .maybeSingle();
    if (row == null) return null;
    return TeacherReview.fromMap(Map<String, dynamic>.from(row));
  }

  Future<Map<String, TeacherReview>> fetchOwnTeacherReviewsForMatter({
    required SupabaseClient client,
    required String deviceId,
    required String matterId,
  }) async {
    final rows = await client
        .from('teacher_reviews')
        .select()
        .eq('device_id', deviceId)
        .eq('matter_id', matterId);

    final reviews = rows
        .cast<Map<String, dynamic>>()
        .map(TeacherReview.fromMap)
        .toList(growable: false);

    return {
      for (final review in reviews) review.teacherId: review,
    };
  }

  Future<void> upsertTeacherReview({
    required SupabaseClient client,
    required String deviceId,
    required TeacherReviewScope scope,
    required int general,
    required Map<String, int> dimensions,
    String? comment,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final legacyAspectos = _legacyTeacherAspectosFromDimensions(dimensions);
    await client.from('teacher_reviews').upsert({
      'device_id': deviceId,
      'teacher_id': scope.teacherId,
      'matter_id': scope.matterId,
      'career_id': scope.careerId,
      'general_rating': general,
      'dimensions': dimensions,
      'explica_rating': legacyAspectos['explica'] ?? 0,
      'claridad_rating': legacyAspectos['claridad'] ?? 0,
      'exigencia_rating': legacyAspectos['exigencia'] ?? 0,
      'trato_rating': legacyAspectos['trato'] ?? 0,
      'organizacion_rating': legacyAspectos['organizacion'] ?? 0,
      'recomendacion_rating': legacyAspectos['recomendacion'] ?? 0,
      'comment': _nullIfBlank(comment),
      'created_at': now,
      'updated_at': now,
    }, onConflict: 'device_id,teacher_id,matter_id').select();
  }

  MatterReviewSummary summarizeMatter(List<MatterReview> reviews) {
    final rating = RatingResumen(
      promedio: _average(reviews.map((e) => e.rating)),
      votos: reviews.length,
    );

    final dimensions = <String, RatingResumen>{};
    for (final key in kMatterDimensionKeys) {
      final values = reviews
          .map((e) => e.dimensions[key] ?? 0)
          .where((value) => value > 0)
          .toList(growable: false);
      dimensions[key] = _summarizeAxis(values);
    }

    final sortedDimensions =
        dimensions.entries.where((entry) => entry.value.votos > 0).toList()
          ..sort((a, b) {
            final byAverage = b.value.promedio.compareTo(a.value.promedio);
            if (byAverage != 0) return byAverage;
            return b.value.votos.compareTo(a.value.votos);
          });

    final comments = reviews
        .where((e) => (e.comment ?? '').trim().isNotEmpty)
        .take(3)
        .map(
          (review) => ReviewCommentSnippet(
            deviceId: review.deviceId,
            comment: review.comment!.trim(),
            updatedAt: review.updatedAt,
          ),
        )
        .toList(growable: false);

    return MatterReviewSummary(
      rating: rating,
      dimensions: dimensions,
      highlights: sortedDimensions
          .take(4)
          .map((entry) => entry.key)
          .toList(growable: false),
      comments: comments,
    );
  }

  DocenteRatingResumen summarizeTeacher(List<TeacherReview> reviews) {
    final aspectos = <String, RatingResumen>{};
    for (final key in kTeacherDimensionKeys) {
      final values = reviews
          .map((e) => e.dimensions[key] ?? 0)
          .where((e) => e > 0)
          .toList(growable: false);
      aspectos[key] = _summarizeAxis(values);
    }

    return DocenteRatingResumen(
      general: RatingResumen(
        promedio: _average(reviews.map((e) => e.general).where((e) => e > 0)),
        votos: reviews.length,
      ),
      aspectos: aspectos,
    );
  }

  double _average(Iterable<int> values) {
    final list = values.toList(growable: false);
    if (list.isEmpty) return 0;
    final total = list.fold<int>(0, (sum, item) => sum + item);
    return total / list.length;
  }

  RatingResumen _summarizeAxis(List<int> values) {
    if (values.isEmpty) {
      return const RatingResumen(promedio: 0, votos: 0);
    }

    final average = _average(values);
    final dispersion = _stdDev(values, average);
    final state = _classifyAxis(
      average: average,
      votes: values.length,
      dispersion: dispersion,
    );

    return RatingResumen(
      promedio: average,
      votos: values.length,
      dispersion: dispersion,
      readingState: state,
    );
  }

  double _stdDev(List<int> values, double average) {
    if (values.length <= 1) return 0;
    final variance = values
            .map((value) => (value - average) * (value - average))
            .fold<double>(0, (sum, item) => sum + item) /
        values.length;
    return math.sqrt(variance);
  }

  ReferenceReadingState _classifyAxis({
    required double average,
    required int votes,
    required double dispersion,
  }) {
    if (votes < 2) return ReferenceReadingState.insufficientData;
    if (dispersion <= 0.75) return ReferenceReadingState.consensus;
    if (dispersion >= 1.15) return ReferenceReadingState.divided;
    if (average >= 2.6 && average <= 3.4) return ReferenceReadingState.mixed;
    return ReferenceReadingState.mixed;
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Map<String, int> _legacyTeacherAspectosFromDimensions(
    Map<String, int> dimensions,
  ) {
    return <String, int>{
      'explica': dimensions['clarity_exposition'] ?? 0,
      'claridad': dimensions['question_space'] ?? 0,
      'exigencia': 0,
      'trato': dimensions['classroom_climate'] ?? 0,
      'organizacion': dimensions['evaluation_clarity'] ?? 0,
      'recomendacion': dimensions['support'] ?? 0,
    };
  }

  String _fileExtension(String name) {
    final parts = name.toLowerCase().split('.');
    if (parts.length < 2) return 'jpg';
    final ext = parts.last.trim();
    if (ext.isEmpty) return 'jpg';
    return ext;
  }

  String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String _randHex(int length) {
    final random = math.Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
