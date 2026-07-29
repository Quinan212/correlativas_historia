import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class CeldaOoxmlMesas {
  const CeldaOoxmlMesas({
    required this.reference,
    required this.row,
    required this.column,
    required this.value,
    this.hyperlink,
  });

  final String reference;
  final int row;
  final int column;
  final dynamic value;
  final String? hyperlink;

  String get text => value?.toString().trim() ?? '';
}

class HojaOoxmlMesas {
  const HojaOoxmlMesas({
    required this.name,
    required this.cells,
    required this.maxRow,
    required this.maxColumn,
  });

  final String name;
  final Map<String, CeldaOoxmlMesas> cells;
  final int maxRow;
  final int maxColumn;

  CeldaOoxmlMesas? cell(int row, int column) {
    return cells['${columnNameOoxmlMesas(column)}$row'];
  }

  List<CeldaOoxmlMesas> rowCells(int row) {
    final out = <CeldaOoxmlMesas>[];
    for (var column = 1; column <= maxColumn; column++) {
      final value = cell(row, column);
      if (value != null) out.add(value);
    }
    return out;
  }
}

class LibroOoxmlMesas {
  const LibroOoxmlMesas({required this.sheets});

  final List<HojaOoxmlMesas> sheets;
}

enum _KindStyleOoxml { general, date, time }

class LectorOoxmlMesas {
  const LectorOoxmlMesas();

  LibroOoxmlMesas read(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final workbookXml = _readXmlRequired(archive, 'xl/workbook.xml');
    final workbookRels = _readRelationships(
      archive,
      'xl/_rels/workbook.xml.rels',
    );
    final sharedStrings = _readSharedStrings(archive);
    final styles = _readStyles(archive);

    final sheets = <HojaOoxmlMesas>[];
    for (final sheetNode in _elements(workbookXml, 'sheet')) {
      final name = _attribute(sheetNode, 'name')?.trim() ?? '';
      final relationId = _attribute(sheetNode, 'id')?.trim() ?? '';
      if (name.isEmpty || relationId.isEmpty) continue;
      final target = workbookRels[relationId];
      if (target == null || target.isEmpty) continue;
      final sheetPath = _resolveWorkbookTarget(target);
      final sheetFile = archive.findFile(sheetPath);
      final sheetBytes = sheetFile?.readBytes();
      if (sheetBytes == null) continue;
      sheets.add(
        _readSheet(
          archive: archive,
          path: sheetPath,
          name: name,
          xml: XmlDocument.parse(utf8.decode(sheetBytes)),
          sharedStrings: sharedStrings,
          styles: styles,
        ),
      );
    }
    if (sheets.isEmpty) {
      throw const FormatException('El libro no contiene hojas legibles.');
    }
    return LibroOoxmlMesas(sheets: List<HojaOoxmlMesas>.unmodifiable(sheets));
  }

  HojaOoxmlMesas _readSheet({
    required Archive archive,
    required String path,
    required String name,
    required XmlDocument xml,
    required List<String> sharedStrings,
    required List<_KindStyleOoxml> styles,
  }) {
    final relationshipsPath = _sheetRelationshipsPath(path);
    final relationships = _readRelationships(archive, relationshipsPath);
    final hyperlinks = <String, String>{};
    for (final hyperlink in _elements(xml, 'hyperlink')) {
      final reference = _attribute(hyperlink, 'ref')?.trim() ?? '';
      final relationId = _attribute(hyperlink, 'id')?.trim() ?? '';
      final location = _attribute(hyperlink, 'location')?.trim() ?? '';
      final target = relationships[relationId] ?? location;
      if (reference.isEmpty || target.isEmpty) continue;
      for (final cellReference in _expandReference(reference)) {
        hyperlinks[cellReference] = target;
      }
    }

    final cells = <String, CeldaOoxmlMesas>{};
    var maxRow = 0;
    var maxColumn = 0;
    for (final cellNode in _elements(xml, 'c')) {
      final reference = _attribute(cellNode, 'r')?.trim() ?? '';
      if (reference.isEmpty) continue;
      final coordinates = parseCellReferenceOoxmlMesas(reference);
      if (coordinates == null) continue;
      final type = _attribute(cellNode, 't')?.trim() ?? '';
      final styleIndex = int.tryParse(_attribute(cellNode, 's') ?? '') ?? 0;
      final style = styleIndex >= 0 && styleIndex < styles.length
          ? styles[styleIndex]
          : _KindStyleOoxml.general;
      final value = _readCellValue(
        cellNode,
        type: type,
        style: style,
        sharedStrings: sharedStrings,
      );
      final hyperlink = hyperlinks[reference];
      if (value == null && hyperlink == null) continue;
      cells[reference] = CeldaOoxmlMesas(
        reference: reference,
        row: coordinates.$1,
        column: coordinates.$2,
        value: value,
        hyperlink: hyperlink,
      );
      if (coordinates.$1 > maxRow) maxRow = coordinates.$1;
      if (coordinates.$2 > maxColumn) maxColumn = coordinates.$2;
    }
    return HojaOoxmlMesas(
      name: name,
      cells: Map<String, CeldaOoxmlMesas>.unmodifiable(cells),
      maxRow: maxRow,
      maxColumn: maxColumn,
    );
  }

  dynamic _readCellValue(
    XmlElement cellNode, {
    required String type,
    required _KindStyleOoxml style,
    required List<String> sharedStrings,
  }) {
    if (type == 'inlineStr') {
      final inline = _firstElement(cellNode, 'is');
      return inline?.innerText.trim();
    }
    final valueNode = _firstElement(cellNode, 'v');
    final raw = valueNode?.innerText.trim() ?? '';
    if (type == 's') {
      final index = int.tryParse(raw);
      if (index == null || index < 0 || index >= sharedStrings.length) {
        return raw;
      }
      return sharedStrings[index];
    }
    if (type == 'str' || type == 'e') return raw;
    if (type == 'b') return raw == '1';
    if (raw.isEmpty) return null;
    final numeric = double.tryParse(raw);
    if (numeric == null) return raw;
    if (style == _KindStyleOoxml.date) {
      final base = DateTime(1899, 12, 30);
      final wholeDays = numeric.floor();
      final fraction = numeric - wholeDays;
      return base.add(
        Duration(
          days: wholeDays,
          milliseconds: (fraction * Duration.millisecondsPerDay).round(),
        ),
      );
    }
    if (style == _KindStyleOoxml.time) {
      final totalMinutes = (numeric * 24 * 60).round();
      return Duration(minutes: totalMinutes);
    }
    if (numeric == numeric.roundToDouble()) return numeric.toInt();
    return numeric;
  }

  List<String> _readSharedStrings(Archive archive) {
    final file = archive.findFile('xl/sharedStrings.xml');
    final bytes = file?.readBytes();
    if (bytes == null) return const <String>[];
    final xml = XmlDocument.parse(utf8.decode(bytes));
    return _elements(xml, 'si')
        .map((element) => element.innerText)
        .toList(growable: false);
  }

  List<_KindStyleOoxml> _readStyles(Archive archive) {
    final file = archive.findFile('xl/styles.xml');
    final bytes = file?.readBytes();
    if (bytes == null) return const <_KindStyleOoxml>[_KindStyleOoxml.general];
    final xml = XmlDocument.parse(utf8.decode(bytes));
    final customFormats = <int, String>{};
    for (final numFmt in _elements(xml, 'numFmt')) {
      final id = int.tryParse(_attribute(numFmt, 'numFmtId') ?? '');
      final code = _attribute(numFmt, 'formatCode');
      if (id != null && code != null) customFormats[id] = code;
    }
    final cellXfs = _elements(xml, 'cellXfs').firstOrNull;
    if (cellXfs == null) {
      return const <_KindStyleOoxml>[_KindStyleOoxml.general];
    }
    final out = <_KindStyleOoxml>[];
    for (final xf in cellXfs.children.whereType<XmlElement>()) {
      if (xf.name.local != 'xf') continue;
      final id = int.tryParse(_attribute(xf, 'numFmtId') ?? '') ?? 0;
      out.add(_classifyFormat(id, customFormats[id]));
    }
    if (out.isEmpty) out.add(_KindStyleOoxml.general);
    return List<_KindStyleOoxml>.unmodifiable(out);
  }

  _KindStyleOoxml _classifyFormat(int id, String? customCode) {
    if ((id >= 14 && id <= 22) || (id >= 27 && id <= 36) ||
        (id >= 50 && id <= 58)) {
      return _KindStyleOoxml.date;
    }
    if (id >= 45 && id <= 47) return _KindStyleOoxml.time;
    final code = (customCode ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'"[^"]*"'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '');
    final hasDate = code.contains('yy') || code.contains('dd');
    final hasTime = code.contains('hh') || code.contains('h:') ||
        code.contains(':mm') || code.contains('ss');
    if (hasDate) return _KindStyleOoxml.date;
    if (hasTime) return _KindStyleOoxml.time;
    return _KindStyleOoxml.general;
  }

  Map<String, String> _readRelationships(Archive archive, String path) {
    final file = archive.findFile(path);
    final bytes = file?.readBytes();
    if (bytes == null) return const <String, String>{};
    final xml = XmlDocument.parse(utf8.decode(bytes));
    final out = <String, String>{};
    for (final relation in _elements(xml, 'Relationship')) {
      final id = _attribute(relation, 'Id')?.trim() ?? '';
      final target = _attribute(relation, 'Target')?.trim() ?? '';
      if (id.isNotEmpty && target.isNotEmpty) out[id] = target;
    }
    return Map<String, String>.unmodifiable(out);
  }

  XmlDocument _readXmlRequired(Archive archive, String path) {
    final bytes = archive.findFile(path)?.readBytes();
    if (bytes == null) throw FormatException('Falta $path dentro del XLSX.');
    return XmlDocument.parse(utf8.decode(bytes));
  }

  String _resolveWorkbookTarget(String target) {
    final clean = target.replaceAll('\\', '/');
    if (clean.startsWith('/')) return clean.substring(1);
    if (clean.startsWith('xl/')) return clean;
    return 'xl/$clean';
  }

  String _sheetRelationshipsPath(String path) {
    final slash = path.lastIndexOf('/');
    final directory = slash < 0 ? '' : path.substring(0, slash);
    final file = slash < 0 ? path : path.substring(slash + 1);
    return '$directory/_rels/$file.rels';
  }

  Iterable<String> _expandReference(String reference) sync* {
    final parts = reference.split(':');
    if (parts.length != 2) {
      yield reference;
      return;
    }
    final start = parseCellReferenceOoxmlMesas(parts[0]);
    final end = parseCellReferenceOoxmlMesas(parts[1]);
    if (start == null || end == null) {
      yield reference;
      return;
    }
    for (var row = start.$1; row <= end.$1; row++) {
      for (var column = start.$2; column <= end.$2; column++) {
        yield '${columnNameOoxmlMesas(column)}$row';
      }
    }
  }

  Iterable<XmlElement> _elements(XmlNode node, String localName) {
    return node.descendants
        .whereType<XmlElement>()
        .where((element) => element.name.local == localName);
  }

  XmlElement? _firstElement(XmlNode node, String localName) {
    for (final element in _elements(node, localName)) {
      return element;
    }
    return null;
  }

  String? _attribute(XmlElement element, String localName) {
    for (final attribute in element.attributes) {
      if (attribute.name.local == localName) return attribute.value;
    }
    return null;
  }
}

(int, int)? parseCellReferenceOoxmlMesas(String reference) {
  final match = RegExp(r'^([A-Za-z]+)(\d+)$').firstMatch(reference.trim());
  if (match == null) return null;
  final letters = match.group(1)!.toUpperCase();
  final row = int.tryParse(match.group(2)!);
  if (row == null) return null;
  var column = 0;
  for (final code in letters.codeUnits) {
    column = column * 26 + (code - 64);
  }
  return (row, column);
}

String columnNameOoxmlMesas(int column) {
  if (column <= 0) return '';
  var value = column;
  final chars = <int>[];
  while (value > 0) {
    value--;
    chars.add(65 + (value % 26));
    value ~/= 26;
  }
  return String.fromCharCodes(chars.reversed);
}

extension _FirstOrNullXml<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
