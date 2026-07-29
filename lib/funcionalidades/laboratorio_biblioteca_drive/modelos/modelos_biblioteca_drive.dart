import 'dart:math' as math;

const mimeCarpetaGoogleDrive = 'application/vnd.google-apps.folder';
const prefijoMimeGoogleWorkspace = 'application/vnd.google-apps.';

class ElementoBibliotecaDrive {
  const ElementoBibliotecaDrive({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.canDownload,
    this.size,
    this.modifiedTime,
    this.webViewLink,
    this.webContentLink,
    this.resourceKey,
  });

  factory ElementoBibliotecaDrive.fromJson(Map<String, dynamic> json) {
    final capabilities = json['capabilities'];
    return ElementoBibliotecaDrive(
      id: json['id']?.toString().trim() ?? '',
      name: json['name']?.toString().trim() ?? 'Sin nombre',
      mimeType:
          json['mimeType']?.toString().trim() ?? 'application/octet-stream',
      size: _parseSize(json['size']),
      modifiedTime: DateTime.tryParse(
        json['modifiedTime']?.toString().trim() ?? '',
      ),
      webViewLink: _nullableText(json['webViewLink']),
      webContentLink: _nullableText(json['webContentLink']),
      resourceKey: _nullableText(json['resourceKey']),
      canDownload: capabilities is Map
          ? capabilities['canDownload'] != false
          : true,
    );
  }

  final String id;
  final String name;
  final String mimeType;
  final int? size;
  final DateTime? modifiedTime;
  final String? webViewLink;
  final String? webContentLink;
  final String? resourceKey;
  final bool canDownload;

  bool get isFolder => mimeType == mimeCarpetaGoogleDrive;

  bool get isGoogleWorkspaceFile =>
      !isFolder && mimeType.startsWith(prefijoMimeGoogleWorkspace);

  String get visibleName {
    final withoutPrefix = name.replaceFirst(RegExp(r'^\s*\d{2}\s*-\s*'), '');
    return withoutPrefix.trim().isEmpty ? name : withoutPrefix.trim();
  }

  String get extension {
    final index = name.lastIndexOf('.');
    if (index <= 0 || index == name.length - 1) return '';
    return name.substring(index + 1).toLowerCase();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'mimeType': mimeType,
    'size': size,
    'modifiedTime': modifiedTime?.toIso8601String(),
    'webViewLink': webViewLink,
    'webContentLink': webContentLink,
    'resourceKey': resourceKey,
    'capabilities': <String, dynamic>{'canDownload': canDownload},
  };

  static int? _parseSize(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _nullableText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

class CopiaCarpetaBibliotecaDrive {
  const CopiaCarpetaBibliotecaDrive({
    required this.folderId,
    required this.items,
    required this.fetchedAt,
  });

  factory CopiaCarpetaBibliotecaDrive.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map(
          (value) => ElementoBibliotecaDrive.fromJson(
            Map<String, dynamic>.from(value),
          ),
        )
        .where((value) => value.id.isNotEmpty)
        .toList(growable: false);
    return CopiaCarpetaBibliotecaDrive(
      folderId: json['folderId']?.toString().trim() ?? '',
      items: items,
      fetchedAt:
          DateTime.tryParse(json['fetchedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  final String folderId;
  final List<ElementoBibliotecaDrive> items;
  final DateTime fetchedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'folderId': folderId,
    'items': items.map((value) => value.toJson()).toList(growable: false),
    'fetchedAt': fetchedAt.toIso8601String(),
  };
}

class SegmentoRutaBibliotecaDrive {
  const SegmentoRutaBibliotecaDrive({required this.id, required this.name});

  final String id;
  final String name;
}

List<ElementoBibliotecaDrive> ordenarElementosBibliotecaDrive(
  Iterable<ElementoBibliotecaDrive> source,
) {
  final items = source.toList(growable: false);
  items.sort((left, right) {
    if (left.isFolder != right.isFolder) return left.isFolder ? -1 : 1;
    return _naturalCompare(left.visibleName, right.visibleName);
  });
  return items;
}

int _naturalCompare(String left, String right) {
  final leftParts = _splitNatural(left.toLowerCase());
  final rightParts = _splitNatural(right.toLowerCase());
  final count = math.min(leftParts.length, rightParts.length);
  for (var index = 0; index < count; index++) {
    final leftPart = leftParts[index];
    final rightPart = rightParts[index];
    final leftNumber = int.tryParse(leftPart);
    final rightNumber = int.tryParse(rightPart);
    final comparison = leftNumber != null && rightNumber != null
        ? leftNumber.compareTo(rightNumber)
        : leftPart.compareTo(rightPart);
    if (comparison != 0) return comparison;
  }
  return leftParts.length.compareTo(rightParts.length);
}

List<String> _splitNatural(String value) {
  return RegExp(r'\d+|\D+')
      .allMatches(value)
      .map((match) => match.group(0) ?? '')
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
}
