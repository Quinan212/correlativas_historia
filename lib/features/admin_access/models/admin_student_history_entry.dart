class AdminStudentHistoryEntry {
  const AdminStudentHistoryEntry({
    required this.id,
    required this.eventType,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime? createdAt;

  factory AdminStudentHistoryEntry.fromRow(Map<String, dynamic> row) {
    DateTime? parseDate(dynamic value) {
      final text = value?.toString().trim() ?? '';
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    return AdminStudentHistoryEntry(
      id: (row['id'] ?? '').toString(),
      eventType: (row['event_type'] ?? '').toString(),
      payload: (row['payload'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
      createdAt: parseDate(row['created_at']),
    );
  }
}
