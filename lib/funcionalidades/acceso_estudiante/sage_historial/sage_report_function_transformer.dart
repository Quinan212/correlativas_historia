import 'dart:convert';

class SageReportFunctionTransformResult {
  const SageReportFunctionTransformResult({
    required this.source,
    required this.assignmentCount,
    required this.assignmentTarget,
    required this.hash,
    required this.status,
  });

  final String? source;
  final int assignmentCount;
  final String? assignmentTarget;
  final String hash;
  final SageReportTransformStatus status;

  bool get isSafe => status == SageReportTransformStatus.safe;
}

enum SageReportTransformStatus { safe, structureChanged, unsafe }

class SageReportFunctionTransformer {
  SageReportFunctionTransformer._();

  static const _targets = <String>[
    'window.location.href',
    'document.location.href',
    'parent.location.href',
    'top.location.href',
    'self.location.href',
    'location.href',
  ];

  static SageReportFunctionTransformResult transform(
    String source,
    String reportType,
  ) {
    final hash = _hash(source);
    final assignments = _findAssignments(source);
    if (assignments.length != 1) {
      return SageReportFunctionTransformResult(
        source: null,
        assignmentCount: assignments.length,
        assignmentTarget: assignments.length == 1
            ? assignments.single.target
            : null,
        hash: hash,
        status: assignments.isEmpty
            ? SageReportTransformStatus.structureChanged
            : SageReportTransformStatus.unsafe,
      );
    }

    final assignment = assignments.single;
    final lower = source.toLowerCase();
    final unexpected = <String>[
      'window.open',
      'form.submit',
      'requestsubmit',
      'fetch(',
      'xmlhttprequest',
      'location.assign',
      'location.replace',
    ];
    if (unexpected.any(lower.contains)) {
      return SageReportFunctionTransformResult(
        source: null,
        assignmentCount: 1,
        assignmentTarget: assignment.target,
        hash: hash,
        status: SageReportTransformStatus.unsafe,
      );
    }

    final replacement =
        'return window.__flutterCaptureSageReportV3(${jsonEncode(reportType)}, '
        '${source.substring(assignment.expressionStart, assignment.expressionEnd)})';
    final transformed = source.replaceRange(
      assignment.targetStart,
      assignment.expressionEnd,
      replacement,
    );
    return SageReportFunctionTransformResult(
      source: transformed,
      assignmentCount: 1,
      assignmentTarget: assignment.target,
      hash: hash,
      status: SageReportTransformStatus.safe,
    );
  }

  static List<_Assignment> _findAssignments(String source) {
    final result = <_Assignment>[];
    var index = 0;
    while (index < source.length) {
      final next = _skipStringOrComment(source, index);
      if (next != index) {
        index = next;
        continue;
      }
      String? target;
      for (final candidate in _targets) {
        if (!source.startsWith(candidate, index)) continue;
        final previous = index == 0 ? '' : source[index - 1];
        if (_isIdentifierChar(previous)) continue;
        target = candidate;
        break;
      }
      if (target == null) {
        index++;
        continue;
      }
      var equals = index + target.length;
      equals = _skipWhitespace(source, equals);
      if (equals >= source.length || source[equals] != '=') {
        index += target.length;
        continue;
      }
      if (equals + 1 < source.length && source[equals + 1] == '=') {
        index += target.length;
        continue;
      }
      final expressionStart = _skipWhitespace(source, equals + 1);
      final expressionEnd = _expressionEnd(source, expressionStart);
      result.add(
        _Assignment(
          target: target,
          targetStart: index,
          expressionStart: expressionStart,
          expressionEnd: expressionEnd,
        ),
      );
      index = expressionEnd;
    }
    return result;
  }

  static int _expressionEnd(String source, int start) {
    var index = start;
    var parentheses = 0;
    var brackets = 0;
    var braces = 0;
    while (index < source.length) {
      final next = _skipStringOrComment(source, index);
      if (next != index) {
        index = next;
        continue;
      }
      switch (source[index]) {
        case '(':
          parentheses++;
        case ')':
          if (parentheses > 0) parentheses--;
        case '[':
          brackets++;
        case ']':
          if (brackets > 0) brackets--;
        case '{':
          braces++;
        case '}':
          if (braces > 0) {
            braces--;
          } else if (parentheses == 0 && brackets == 0) {
            return index;
          }
        case ';':
          if (parentheses == 0 && brackets == 0 && braces == 0) {
            return index;
          }
      }
      index++;
    }
    return source.length;
  }

  static int _skipStringOrComment(String source, int index) {
    if (index >= source.length) return index;
    final quote = source[index];
    if (quote == "'" || quote == '"' || quote == '`') {
      var cursor = index + 1;
      while (cursor < source.length) {
        if (source.codeUnitAt(cursor) == 92) {
          cursor += 2;
        } else if (source[cursor] == quote) {
          return cursor + 1;
        } else {
          cursor++;
        }
      }
      return source.length;
    }
    if (quote == '/' && index + 1 < source.length) {
      final next = source[index + 1];
      if (next == '/') {
        final newline = source.indexOf('\n', index + 2);
        return newline < 0 ? source.length : newline + 1;
      }
      if (next == '*') {
        final end = source.indexOf('*/', index + 2);
        return end < 0 ? source.length : end + 2;
      }
    }
    return index;
  }

  static int _skipWhitespace(String source, int index) {
    while (index < source.length && source[index].trim().isEmpty) {
      index++;
    }
    return index;
  }

  static bool _isIdentifierChar(String value) =>
      value.isNotEmpty && RegExp(r'[A-Za-z0-9_$]').hasMatch(value);

  static String _hash(String value) {
    var hash = 2166136261;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }
}

class _Assignment {
  const _Assignment({
    required this.target,
    required this.targetStart,
    required this.expressionStart,
    required this.expressionEnd,
  });

  final String target;
  final int targetStart;
  final int expressionStart;
  final int expressionEnd;
}
