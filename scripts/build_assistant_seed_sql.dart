import 'dart:io';

void main(List<String> args) {
  final projectRoot = Directory.current.path;
  final steimanPath =
      '$projectRoot/docs/referencias/steiman_mas_didactica_nivel_superior.txt';
  final libRoot = Directory('$projectRoot/lib');

  final steimanText = File(steimanPath).readAsStringSync();
  final appText = _collectAppText(libRoot);

  final chunks = <_Chunk>[];
  chunks.addAll(_chunkDocument(
    documentId: 'steiman_mas_didactica_nivel_superior',
    title: 'Steiman - Mas didactica en nivel superior',
    sourceType: 'steiman',
    sourcePath: 'docs/referencias/steiman_mas_didactica_nivel_superior.txt',
    text: steimanText,
    chunkSize: 1200,
    maxChunks: 280,
  ));
  chunks.addAll(_chunkDocument(
    documentId: 'app_textos_sin_faq',
    title: 'Textos de la app (sin FAQ)',
    sourceType: 'app_text',
    sourcePath: 'lib curated text (excluding lib/features/faq)',
    text: appText,
    chunkSize: 900,
    maxChunks: 160,
  ));

  final out = StringBuffer()
    ..writeln(
        "delete from public.assistant_chunks where document_id in ('steiman_mas_didactica_nivel_superior','app_textos_sin_faq');")
    ..writeln(
        "delete from public.assistant_documents where id in ('steiman_mas_didactica_nivel_superior','app_textos_sin_faq');")
    ..writeln(
      "insert into public.assistant_documents (id, title, source_type, source_path, active) values "
      "('steiman_mas_didactica_nivel_superior','Steiman - Mas didactica en nivel superior','steiman','docs/referencias/steiman_mas_didactica_nivel_superior.txt', true),"
      "('app_textos_sin_faq','Textos de la app (sin FAQ)','app_text','lib curated text (excluding lib/features/faq)', true);",
    );

  for (final chunk in chunks) {
    out.writeln(
      "insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values "
      "('${chunk.documentId}', ${chunk.index}, '${_sql(chunk.text)}', '${_sql(chunk.sourceRef)}');",
    );
  }

  final outputPath = '$projectRoot/RUIDO/assistant_seed.sql';
  File(outputPath).writeAsStringSync(out.toString());
  stdout.writeln('Seed SQL generated: $outputPath');
  stdout.writeln('Chunks generated: ${chunks.length}');
}

String _collectAppText(Directory libRoot) {
  final buffer = StringBuffer();
  final allowedSegments = <String>[
    '/lib/features/calculadora/',
    '/lib/features/cascada/',
    '/lib/features/examenes/',
    '/lib/features/experimental/',
    '/lib/shared/providers/app_state.dart',
    '/lib/models/materia.dart',
    '/lib/data/html_source_loader.dart',
  ];

  final files = libRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) {
    final normalized = '/${file.path.replaceAll('\\', '/')}';
    if (normalized.contains('/features/faq/')) return false;
    return allowedSegments.any((segment) => normalized.contains(segment));
  }).toList(growable: false);

  final regex = RegExp(
    r'''\'([^'\\]*(?:\\.[^'\\]*)*)\'|\"([^\"\\]*(?:\\.[^\"\\]*)*)\"''',
  );

  for (final file in files) {
    final normalizedPath = file.path.replaceAll('\\', '/');
    final content = file.readAsStringSync();
    final matches = regex.allMatches(content);
    for (final match in matches) {
      final candidate = (match.group(1) ?? match.group(2) ?? '').trim();
      if (candidate.length < 28) continue;
      if (!RegExp(r'[A-Za-z]').hasMatch(candidate)) continue;
      if (_looksTechnical(candidate)) continue;

      final cleaned = candidate
          .replaceAll(r'\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (cleaned.length < 28) continue;
      buffer.writeln('[$normalizedPath] $cleaned');
    }
  }
  return buffer.toString();
}

bool _looksTechnical(String text) {
  final lower = text.toLowerCase();
  if (lower.startsWith('package:') || lower.contains(' import ')) return true;
  if (lower.contains('http://') || lower.contains('https://')) return true;
  if (lower.contains('assets/')) return true;
  if (lower.contains('../') || lower.contains('./')) return true;
  if (lower.contains(' class ') || lower.startsWith('class ')) return true;
  if (lower.contains(' final ') || lower.startsWith('final ')) return true;
  if (lower.contains('=>') || lower.contains('regexp(')) return true;
  if (lower.contains(r'${')) return true;
  if (lower.contains('provider') && lower.length < 140) return true;
  return false;
}

List<_Chunk> _chunkDocument({
  required String documentId,
  required String title,
  required String sourceType,
  required String sourcePath,
  required String text,
  required int chunkSize,
  required int maxChunks,
}) {
  final sanitized = text
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  final chunks = <_Chunk>[];
  var start = 0;
  var index = 0;
  while (start < sanitized.length) {
    var end = start + chunkSize;
    if (end > sanitized.length) end = sanitized.length;

    if (end < sanitized.length) {
      final nextBreak = sanitized.lastIndexOf('\n', end);
      if (nextBreak > start + (chunkSize * 0.6)) {
        end = nextBreak;
      }
    }

    final piece = sanitized.substring(start, end).trim();
    if (piece.isNotEmpty) {
      index += 1;
      if (index > maxChunks) break;
      chunks.add(
        _Chunk(
          documentId: documentId,
          index: index,
          text: piece,
          sourceRef: sourceType == 'steiman'
              ? 'chunk $index'
              : 'texto app chunk $index',
        ),
      );
    }
    start = end;
  }
  return chunks;
}

String _sql(String input) {
  return input.replaceAll("'", "''");
}

class _Chunk {
  const _Chunk({
    required this.documentId,
    required this.index,
    required this.text,
    required this.sourceRef,
  });

  final String documentId;
  final int index;
  final String text;
  final String sourceRef;
}
