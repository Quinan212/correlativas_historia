class SituatedAssistantSource {
  const SituatedAssistantSource({
    required this.title,
    required this.reference,
  });

  final String title;
  final String reference;

  factory SituatedAssistantSource.fromMap(Map<String, dynamic> map) {
    return SituatedAssistantSource(
      title: (map['title'] ?? '').toString().trim(),
      reference: (map['reference'] ?? '').toString().trim(),
    );
  }
}

class SituatedAssistantResponse {
  const SituatedAssistantResponse({
    required this.status,
    required this.answer,
    required this.sources,
  });

  final String status;
  final String answer;
  final List<SituatedAssistantSource> sources;

  bool get isNoEvidence => status == 'no_evidence';
  bool get isOk => status == 'ok';

  factory SituatedAssistantResponse.fromMap(Map<String, dynamic> map) {
    final rawSources = map['sources'];
    final sources = rawSources is List
        ? rawSources
            .whereType<Map>()
            .map((item) => SituatedAssistantSource.fromMap(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false)
        : const <SituatedAssistantSource>[];

    return SituatedAssistantResponse(
      status: (map['status'] ?? 'error').toString().trim().toLowerCase(),
      answer: (map['answer'] ?? '').toString().trim(),
      sources: sources,
    );
  }
}
