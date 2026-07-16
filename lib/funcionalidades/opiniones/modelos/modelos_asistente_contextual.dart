class FuenteAsistenteContextual {
  const FuenteAsistenteContextual({
    required this.title,
    required this.reference,
  });

  final String title;
  final String reference;

  factory FuenteAsistenteContextual.fromMap(Map<String, dynamic> map) {
    return FuenteAsistenteContextual(
      title: (map['title'] ?? '').toString().trim(),
      reference: (map['reference'] ?? '').toString().trim(),
    );
  }
}

class RespuestaAsistenteContextual {
  const RespuestaAsistenteContextual({
    required this.status,
    required this.answer,
    required this.sources,
  });

  final String status;
  final String answer;
  final List<FuenteAsistenteContextual> sources;

  bool get isNoEvidence => status == 'no_evidence';
  bool get isOk => status == 'ok';

  factory RespuestaAsistenteContextual.fromMap(Map<String, dynamic> map) {
    final rawSources = map['sources'];
    final sources = rawSources is List
        ? rawSources
            .whereType<Map>()
            .map((item) => FuenteAsistenteContextual.fromMap(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false)
        : const <FuenteAsistenteContextual>[];

    return RespuestaAsistenteContextual(
      status: (map['status'] ?? 'error').toString().trim().toLowerCase(),
      answer: (map['answer'] ?? '').toString().trim(),
      sources: sources,
    );
  }
}
