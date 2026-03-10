import 'dart:convert';

bool _looksMojibake(String input) {
  return input.contains('\u00c3') ||
      input.contains('\u00c2') ||
      input.contains('\u00e2');
}

String _repairLatin1Utf8(String input) {
  try {
    return utf8.decode(latin1.encode(input), allowMalformed: true);
  } catch (_) {
    return input;
  }
}

String sanitizeText(String input) {
  if (input.isEmpty) return input;

  var value = input.replaceAll('\u00a0', ' ').replaceAll('\u200b', '');

  for (var i = 0; i < 3; i++) {
    if (!_looksMojibake(value)) break;
    final repaired = _repairLatin1Utf8(value);
    if (repaired == value) break;
    value = repaired;
  }

  const replacements = <String, String>{
    '\u00c2\u00ba': '\u00ba',
    '\u00c2\u00b0': '\u00b0',
    '\u00c2\u00b7': '\u00b7',
    '\u00e2\u20ac\u201d': '\u2014',
    '\u00e2\u20ac\u201c': '\u2013',
    '\u00ef\u00bf\u00bd': '',
  };

  replacements.forEach((from, to) {
    value = value.replaceAll(from, to);
  });

  return value.trim();
}

String sanitizeLowerNoAccents(String input) {
  return sanitizeText(input)
      .toLowerCase()
      .replaceAll('\u00e1', 'a')
      .replaceAll('\u00e9', 'e')
      .replaceAll('\u00ed', 'i')
      .replaceAll('\u00f3', 'o')
      .replaceAll('\u00fa', 'u')
      .replaceAll('\u00fc', 'u')
      .replaceAll('\u00f1', 'n');
}
