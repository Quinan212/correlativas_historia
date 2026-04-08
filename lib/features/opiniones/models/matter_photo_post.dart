class MatterPhotoPost {
  const MatterPhotoPost({
    required this.id,
    required this.deviceId,
    required this.matterId,
    required this.careerId,
    required this.imagePath,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    required this.updatedAt,
    required this.enabled,
  });

  final String id;
  final String deviceId;
  final String matterId;
  final String careerId;
  final String imagePath;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool enabled;

  factory MatterPhotoPost.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(String key) {
      final raw = map[key]?.toString();
      if (raw == null || raw.isEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.tryParse(raw)?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    return MatterPhotoPost(
      id: (map['id'] ?? '').toString(),
      deviceId: (map['device_id'] ?? '').toString(),
      matterId: (map['matter_id'] ?? '').toString(),
      careerId: (map['career_id'] ?? '').toString(),
      imagePath: (map['image_path'] ?? '').toString(),
      imageUrl: (map['image_url'] ?? '').toString(),
      caption: map['caption']?.toString(),
      createdAt: parseDate('created_at'),
      updatedAt: parseDate('updated_at'),
      enabled: map['enabled'] as bool? ?? true,
    );
  }
}
