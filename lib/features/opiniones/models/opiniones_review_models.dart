import 'opiniones_rating.dart';
import '../utils/referencias_labels.dart';

class MatterReview {
  const MatterReview({
    required this.id,
    required this.deviceId,
    required this.matterId,
    required this.careerId,
    required this.rating,
    required this.dimensions,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
  });

  final String id;
  final String deviceId;
  final String matterId;
  final String careerId;
  final int rating;
  final Map<String, int> dimensions;
  final List<String> tags;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MatterReview.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(String key) {
      final raw = map[key]?.toString();
      if (raw == null || raw.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.tryParse(raw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    final rawTags = map['tags'];
    final tags = rawTags is List
        ? rawTags.map((item) => item.toString()).toList(growable: false)
        : const <String>[];
    final rawDimensions = map['dimensions'];
    final dimensions = rawDimensions is Map
        ? (rawDimensions.map(
            (key, value) => MapEntry(
              key.toString(),
              (value as num?)?.toInt() ?? 0,
            ),
          )..removeWhere((_, value) => value <= 0))
        : matterDimensionsFromLegacyTags(tags);

    return MatterReview(
      id: (map['id'] ?? '').toString(),
      deviceId: (map['device_id'] ?? '').toString(),
      matterId: (map['matter_id'] ?? '').toString(),
      careerId: (map['career_id'] ?? '').toString(),
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      dimensions: Map<String, int>.unmodifiable(dimensions),
      tags: tags,
      comment: map['comment']?.toString(),
      createdAt: parseDate('created_at'),
      updatedAt: parseDate('updated_at'),
    );
  }
}

class TeacherReview {
  const TeacherReview({
    required this.id,
    required this.deviceId,
    required this.teacherId,
    required this.matterId,
    required this.careerId,
    required this.general,
    required this.dimensions,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
  });

  final String id;
  final String deviceId;
  final String teacherId;
  final String matterId;
  final String careerId;
  final int general;
  final Map<String, int> dimensions;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TeacherReview.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(String key) {
      final raw = map[key]?.toString();
      if (raw == null || raw.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.tryParse(raw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    int intField(String key) => (map[key] as num?)?.toInt() ?? 0;
    final legacyAspectos = <String, int>{
      'explica': intField('explica_rating'),
      'claridad': intField('claridad_rating'),
      'exigencia': intField('exigencia_rating'),
      'trato': intField('trato_rating'),
      'organizacion': intField('organizacion_rating'),
      'recomendacion': intField('recomendacion_rating'),
    }..removeWhere((_, value) => value <= 0);
    final rawDimensions = map['dimensions'];
    final dimensions = rawDimensions is Map
        ? (rawDimensions.map(
            (key, value) => MapEntry(
              key.toString(),
              (value as num?)?.toInt() ?? 0,
            ),
          )..removeWhere((_, value) => value <= 0))
        : teacherDimensionsFromLegacyAspectos(legacyAspectos);

    return TeacherReview(
      id: (map['id'] ?? '').toString(),
      deviceId: (map['device_id'] ?? '').toString(),
      teacherId: (map['teacher_id'] ?? '').toString(),
      matterId: (map['matter_id'] ?? '').toString(),
      careerId: (map['career_id'] ?? '').toString(),
      general: intField('general_rating'),
      dimensions: Map<String, int>.unmodifiable(dimensions),
      comment: map['comment']?.toString(),
      createdAt: parseDate('created_at'),
      updatedAt: parseDate('updated_at'),
    );
  }
}

class TeacherReviewScope {
  const TeacherReviewScope({
    required this.teacherId,
    required this.matterId,
    required this.careerId,
  });

  final String teacherId;
  final String matterId;
  final String careerId;
}

class MatterReviewSummary {
  const MatterReviewSummary({
    required this.rating,
    required this.dimensions,
    required this.highlights,
    required this.comments,
  });

  final RatingResumen rating;
  final Map<String, RatingResumen> dimensions;
  final List<String> highlights;
  final List<ReviewCommentSnippet> comments;
}

class ReviewCommentSnippet {
  const ReviewCommentSnippet({
    required this.deviceId,
    required this.comment,
    required this.updatedAt,
  });

  final String deviceId;
  final String comment;
  final DateTime updatedAt;
}
