enum VerificationRequestStatus {
  pending,
  approved,
  rejected;

  static VerificationRequestStatus fromValue(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'approved':
        return VerificationRequestStatus.approved;
      case 'rejected':
        return VerificationRequestStatus.rejected;
      default:
        return VerificationRequestStatus.pending;
    }
  }

  String get value => switch (this) {
        VerificationRequestStatus.pending => 'pending',
        VerificationRequestStatus.approved => 'approved',
        VerificationRequestStatus.rejected => 'rejected',
      };
}

class VerificationRequest {
  const VerificationRequest({
    required this.id,
    required this.deviceId,
    required this.matterId,
    required this.matterName,
    required this.careerId,
    required this.imagePath,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
    this.reviewNote,
    this.reviewedAt,
    this.reviewedByDeviceId,
  });

  final String id;
  final String deviceId;
  final String matterId;
  final String matterName;
  final String careerId;
  final String imagePath;
  final String imageUrl;
  final VerificationRequestStatus status;
  final DateTime createdAt;
  final String? reviewNote;
  final DateTime? reviewedAt;
  final String? reviewedByDeviceId;

  factory VerificationRequest.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(String key) {
      final raw = map[key]?.toString();
      if (raw == null || raw.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.tryParse(raw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    DateTime? parseOptDate(String key) {
      final raw = map[key]?.toString();
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw)?.toLocal();
    }

    return VerificationRequest(
      id: (map['id'] ?? '').toString(),
      deviceId: (map['device_id'] ?? '').toString(),
      matterId: (map['matter_id'] ?? '').toString(),
      matterName: (map['matter_name'] ?? '').toString(),
      careerId: (map['career_id'] ?? '').toString(),
      imagePath: (map['image_path'] ?? '').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
      status: VerificationRequestStatus.fromValue(
        (map['status'] ?? 'pending').toString(),
      ),
      createdAt: parseDate('created_at'),
      reviewNote: map['review_note']?.toString(),
      reviewedAt: parseOptDate('reviewed_at'),
      reviewedByDeviceId: map['reviewed_by_device_id']?.toString(),
    );
  }
}
