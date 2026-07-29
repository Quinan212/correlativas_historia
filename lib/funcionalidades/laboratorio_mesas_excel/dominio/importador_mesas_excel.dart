import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../../examenes/modelos/evento_examen.dart';
import '../configuracion/configuracion_fuente_mesas_excel.dart';
import '../configuracion/reglas_mesas_excel.dart';
import '../modelos/modelos_mesas_excel.dart';
import 'lector_ooxml_mesas.dart';
import 'normalizador_mesas_excel.dart';
import 'resolvedor_materias_mesas.dart';

enum _TipoHojaMesasExcel { primerLlamado, segundoLlamado, coloquios, ignorar, desconocida }

extension _TipoHojaMesasExcelX on _TipoHojaMesasExcel {
  String get id => switch (this) {
    _TipoHojaMesasExcel.primerLlamado => 'llamado_1',
    _TipoHojaMesasExcel.segundoLlamado => 'llamado_2',
    _TipoHojaMesasExcel.coloquios => 'coloquio',
    _TipoHojaMesasExcel.ignorar => 'ignorar',
    _TipoHojaMesasExcel.desconocida => 'desconocida',
  };
}

class ImportadorMesasExcel {
  const ImportadorMesasExcel({
    this.config = ConfiguracionFuenteMesasExcel.current,
    this.reader = const LectorOoxmlMesas(),
  });

  final ConfiguracionFuenteMesasExcel config;
  final LectorOoxmlMesas reader;

  ResultadoImportacionMesasExcel importar({
    required Uint8List bytes,
    required List<MateriaCatalogoExcel> catalogo,
  }) {
    final workbook = reader.read(bytes);
    final resolver = ResolvedorMateriasMesasExcel(catalogo);
    final events = <EventoMesaExcel>[];
    final sheetDiagnostics = <DiagnosticoHojaExcel>[];
    final globalWarnings = <String>[];
    final blockingErrors = <String>[];
    final foundTypes = <_TipoHojaMesasExcel>{};
    var exact = 0;
    var aliases = 0;
    var approximate = 0;
    var ambiguous = 0;
    var unmatched = 0;

    for (final sheet in workbook.sheets) {
      final type = _classifySheet(sheet);
      if (type == _TipoHojaMesasExcel.ignorar) continue;
      if (type == _TipoHojaMesasExcel.desconocida) {
        globalWarnings.add('Se ignoró la hoja no reconocida “${sheet.name}”.');
        continue;
      }
      foundTypes.add(type);
      final result = _parseSheet(sheet, type, resolver);
      events.addAll(result.events);
      sheetDiagnostics.add(result.diagnostic);
      for (final event in result.events) {
        switch (event.coincidencia.tipo) {
          case TipoCoincidenciaMateriaExcel.exacta:
          case TipoCoincidenciaMateriaExcel.codigo:
            exact++;
            break;
          case TipoCoincidenciaMateriaExcel.alias:
            aliases++;
            break;
          case TipoCoincidenciaMateriaExcel.aproximada:
            approximate++;
            break;
          case TipoCoincidenciaMateriaExcel.ambigua:
            ambiguous++;
            break;
          case TipoCoincidenciaMateriaExcel.sinCoincidencia:
            unmatched++;
            break;
        }
      }
      if (!result.diagnostic.valida) {
        blockingErrors.addAll(
          result.diagnostic.errores.map(
            (error) => '${sheet.name}: $error',
          ),
        );
      }
    }

    const requiredTypes = <_TipoHojaMesasExcel>{
      _TipoHojaMesasExcel.primerLlamado,
      _TipoHojaMesasExcel.segundoLlamado,
      _TipoHojaMesasExcel.coloquios,
    };
    for (final required in requiredTypes) {
      if (!foundTypes.contains(required)) {
        blockingErrors.add('Falta la hoja requerida “${required.id}”.');
      }
    }

    final totalActasFound = sheetDiagnostics.fold<int>(
      0,
      (total, item) => total + item.actasEncontradas,
    );
    final totalActasAssociated = sheetDiagnostics.fold<int>(
      0,
      (total, item) => total + item.actasAsociadas,
    );
    if (totalActasFound != totalActasAssociated) {
      blockingErrors.add(
        'Se encontraron $totalActasFound enlaces de acta y solo '
        '$totalActasAssociated pudieron asociarse.',
      );
    }
    if (ambiguous > 0 || unmatched > 0) {
      blockingErrors.add(
        'Hay $ambiguous materias ambiguas y $unmatched materias sin coincidencia.',
      );
    }
    if (events.isEmpty) {
      blockingErrors.add('El libro no produjo eventos académicos.');
    }

    final sorted = List<EventoMesaExcel>.of(events)
      ..sort((first, second) {
        final firstDate = first.evento.fechaHora;
        final secondDate = second.evento.fechaHora;
        if (firstDate == null && secondDate == null) {
          return first.evento.materia.compareTo(second.evento.materia);
        }
        if (firstDate == null) return 1;
        if (secondDate == null) return -1;
        return firstDate.compareTo(secondDate);
      });
    final publicable = blockingErrors.isEmpty &&
        sheetDiagnostics.every((diagnostic) => diagnostic.valida);
    final diagnostic = DiagnosticoLibroExcel(
      publicable: publicable,
      parserVersion: config.parserVersion,
      hojasEncontradas: workbook.sheets.map((sheet) => sheet.name).toList(),
      hojas: List<DiagnosticoHojaExcel>.unmodifiable(sheetDiagnostics),
      eventosGenerados: sorted.length,
      actasEncontradas: totalActasFound,
      actasAsociadas: totalActasAssociated,
      coincidenciasExactas: exact,
      coincidenciasPorAlias: aliases,
      coincidenciasAproximadas: approximate,
      materiasAmbiguas: ambiguous,
      materiasSinCoincidencia: unmatched,
      advertencias: List<String>.unmodifiable(globalWarnings),
      erroresBloqueantes: List<String>.unmodifiable(blockingErrors),
    );
    return ResultadoImportacionMesasExcel(
      eventos: List<EventoMesaExcel>.unmodifiable(sorted),
      diagnostico: diagnostic,
    );
  }

  _ResultadoHoja _parseSheet(
    HojaOoxmlMesas sheet,
    _TipoHojaMesasExcel type,
    ResolvedorMateriasMesasExcel resolver,
  ) {
    final warnings = <String>[];
    final errors = <String>[];
    final header = _detectHeader(sheet);
    if (header == null) {
      return _ResultadoHoja(
        events: const <EventoMesaExcel>[],
        diagnostic: DiagnosticoHojaExcel(
          nombre: sheet.name,
          tipo: type.id,
          valida: false,
          filasLeidas: 0,
          eventosGenerados: 0,
          filasRechazadas: 0,
          filasFusionadas: 0,
          duplicadosFusionados: 0,
          actasEncontradas: _countHyperlinks(sheet),
          actasAsociadas: 0,
          errores: const <String>[
            'No se encontró una fila de encabezados compatible.',
          ],
        ),
      );
    }

    final candidates = <EventoMesaExcel>[];
    var rowsRead = 0;
    var rejected = 0;
    var actasFound = 0;
    var actasAssociated = 0;
    for (var row = header.row + 1; row <= sheet.maxRow; row++) {
      final rowCells = sheet.rowCells(row);
      if (rowCells.isEmpty) continue;
      final hyperlinks = rowCells
          .where((cell) => (cell.hyperlink?.trim().isNotEmpty ?? false))
          .map((cell) => cell.hyperlink!.trim())
          .toList(growable: false);
      actasFound += hyperlinks.length;

      final rawCareer = header.value(sheet, row, 'carrera');
      final rawSubject = header.value(sheet, row, 'materia');
      final careerText = rawCareer?.toString().trim() ?? '';
      final subjectText = rawSubject?.toString().trim() ?? '';
      final hasAcademicData = careerText.isNotEmpty || subjectText.isNotEmpty;
      if (!hasAcademicData) {
        if (hyperlinks.isNotEmpty) {
          rejected++;
          errors.add('Fila $row: enlace de acta sin carrera ni materia.');
        }
        continue;
      }
      rowsRead++;
      if (careerText.isEmpty || subjectText.isEmpty) {
        rejected++;
        errors.add('Fila $row: carrera o materia vacía.');
        continue;
      }
      if (hyperlinks.length > 1) {
        rejected++;
        errors.add('Fila $row: contiene más de un enlace de acta.');
        continue;
      }

      final careerId = normalizarCarreraExcel(rawCareer, aliasCarrerasExcel);
      if (careerId == null) {
        rejected++;
        errors.add('Fila $row: carrera no reconocida “$careerText”.');
        continue;
      }
      final placement = normalizarAnioDivisionExcel(
        header.value(sheet, row, 'anio'),
      );
      final cleaned = _cleanSubjectStatus(subjectText);
      final cleanedSubject = cleaned.$1;
      final status = cleaned.$2;
      final match = resolver.resolver(
        careerId: careerId,
        sourceName: cleanedSubject,
        year: placement.anio,
      );
      if (!match.aceptada || match.materia == null) {
        rejected++;
        final second = match.segundoCandidato?.nombre;
        errors.add(
          'Fila $row: materia no resuelta “$subjectText”'
          '${second == null ? '' : ' (segundo candidato: $second)'}.',
        );
        continue;
      }

      final date = normalizarFechaExcel(header.value(sheet, row, 'fecha'));
      final time = normalizarHoraExcel(header.value(sheet, row, 'horario'));
      final teachers = normalizarDocentesExcel(
        header.value(sheet, row, 'docentes'),
      );
      final actaUrl = hyperlinks.firstOrNull;
      if (actaUrl != null) actasAssociated++;
      final actLabel = rowCells.any(
        (cell) => normalizarClaveExcel(cell.text) == 'acta',
      );
      final actStatus = actaUrl != null
          ? EstadoActaExcel.disponible
          : actLabel
          ? EstadoActaExcel.etiquetaSinEnlace
          : EstadoActaExcel.noInformada;
      final eventWarnings = <String>[];
      if (date == null) eventWarnings.add('Fecha no informada o no interpretable.');
      if (time == null) eventWarnings.add('Horario no informado o no interpretable.');
      if (actStatus == EstadoActaExcel.etiquetaSinEnlace) {
        eventWarnings.add('La celda indica ACTA, pero no contiene un hipervínculo.');
      }
      final subject = match.materia!;
      final baseIdentity = generarIdentidadBaseEventoExcel(
        instancia: type.id,
        careerId: careerId,
        subjectId: subject.id,
        anio: placement.anio ?? subject.anio,
        division: placement.division,
        fecha: date,
        hora: time,
      );
      final id = _eventId(
        '$baseIdentity|${generarFirmaDocentesExcel(teachers)}|${sheet.name}|$row',
      );
      final event = EventoExamen(
        id: id,
        careerId: careerId,
        anio: placement.anio ?? subject.anio,
        fecha: date,
        hora: time,
        materia: subject.nombre,
        instancia: type.id,
        docentes: teachers,
        division: placement.division,
        actaUrl: actaUrl,
        estado: status,
        actaHabilitada: actaUrl != null,
      );
      candidates.add(
        EventoMesaExcel(
          evento: event,
          materiaId: subject.id,
          coincidencia: match,
          origen: OrigenFilaExcel(
            hoja: sheet.name,
            filas: <int>[row],
            nombreMateriaFuente: subjectText,
          ),
          estadoActa: actStatus,
          advertencias: List<String>.unmodifiable(eventWarnings),
        ),
      );
    }

    var continuationMerges = 0;
    final reconstructed = <EventoMesaExcel>[];
    for (final candidate in candidates) {
      if (type == _TipoHojaMesasExcel.coloquios &&
          _canMergeContinuation(reconstructed.lastOrNull, candidate)) {
        final previous = reconstructed.removeLast();
        reconstructed.add(_mergeEvents(previous, candidate));
        continuationMerges++;
      } else {
        reconstructed.add(candidate);
      }
    }

    final deduplicated = <EventoMesaExcel>[];
    var duplicateMerges = 0;
    for (final candidate in reconstructed) {
      final index = deduplicated.indexWhere(
        (existing) => _canMergeDuplicate(existing, candidate),
      );
      if (index < 0) {
        deduplicated.add(candidate);
      } else {
        deduplicated[index] = _mergeEvents(deduplicated[index], candidate);
        duplicateMerges++;
      }
    }

    if (deduplicated.isEmpty) {
      errors.add('La hoja no produjo eventos válidos.');
    }
    if (actasFound != actasAssociated) {
      errors.add(
        'Se encontraron $actasFound enlaces de acta y se asociaron $actasAssociated.',
      );
    }
    if (rejected > 0) {
      errors.add('Se rechazaron $rejected filas académicas.');
    }
    if (continuationMerges > 0) {
      warnings.add('Se fusionaron $continuationMerges filas de continuación.');
    }
    if (duplicateMerges > 0) {
      warnings.add('Se fusionaron $duplicateMerges registros duplicados.');
    }

    return _ResultadoHoja(
      events: List<EventoMesaExcel>.unmodifiable(deduplicated),
      diagnostic: DiagnosticoHojaExcel(
        nombre: sheet.name,
        tipo: type.id,
        valida: errors.isEmpty,
        filasLeidas: rowsRead,
        eventosGenerados: deduplicated.length,
        filasRechazadas: rejected,
        filasFusionadas: continuationMerges,
        duplicadosFusionados: duplicateMerges,
        actasEncontradas: actasFound,
        actasAsociadas: actasAssociated,
        advertencias: List<String>.unmodifiable(warnings),
        errores: List<String>.unmodifiable(errors),
      ),
    );
  }

  _TipoHojaMesasExcel _classifySheet(HojaOoxmlMesas sheet) {
    final name = normalizarClaveExcel(sheet.name);
    final firstText = <String>[
      for (var row = 1; row <= sheet.maxRow && row <= 12; row++)
        for (final cell in sheet.rowCells(row)) cell.text,
    ].join(' ');
    final content = normalizarClaveExcel('$name $firstText');
    if (content.contains('primer llamado') ||
        content.contains('1er llamado') ||
        name.contains('primer llamado')) {
      return _TipoHojaMesasExcel.primerLlamado;
    }
    if (content.contains('segundo llamado') ||
        content.contains('2do llamado') ||
        name.contains('segundo llamado')) {
      return _TipoHojaMesasExcel.segundoLlamado;
    }
    if (content.contains('coloquio')) return _TipoHojaMesasExcel.coloquios;
    if (sheet.cells.isEmpty || sheet.maxRow <= 1) {
      return _TipoHojaMesasExcel.ignorar;
    }
    return _TipoHojaMesasExcel.desconocida;
  }

  _HeaderMap? _detectHeader(HojaOoxmlMesas sheet) {
    _HeaderMap? best;
    for (var row = 1; row <= sheet.maxRow && row <= 40; row++) {
      final columns = <String, int>{};
      for (final cell in sheet.rowCells(row)) {
        final text = normalizarClaveExcel(cell.text);
        if (text.isEmpty) continue;
        for (final entry in aliasEncabezadosExcel.entries) {
          if (columns.containsKey(entry.key)) continue;
          if (entry.value.any((alias) => text == normalizarClaveExcel(alias))) {
            columns[entry.key] = cell.column;
          }
        }
      }
      final score = columns.length;
      final required = columns.containsKey('carrera') &&
          columns.containsKey('materia');
      if (!required || score < 5) continue;
      if (best == null || score > best.score) {
        best = _HeaderMap(row: row, columns: columns, score: score);
      }
    }
    return best;
  }

  bool _canMergeContinuation(
    EventoMesaExcel? previous,
    EventoMesaExcel current,
  ) {
    if (previous == null) return false;
    if (current.evento.fecha != null || current.evento.hora != null) return false;
    if (current.estadoActa != EstadoActaExcel.disponible) return false;
    if (previous.estadoActa == EstadoActaExcel.disponible) return false;
    if (previous.evento.careerId != current.evento.careerId) return false;
    if (previous.materiaId != current.materiaId) return false;
    final previousYear = previous.evento.anio;
    final currentYear = current.evento.anio;
    return previousYear == null || currentYear == null || previousYear == currentYear;
  }

  bool _canMergeDuplicate(EventoMesaExcel first, EventoMesaExcel second) {
    if (first.evento.instancia != second.evento.instancia ||
        first.evento.careerId != second.evento.careerId ||
        first.materiaId != second.materiaId ||
        first.evento.anio != second.evento.anio ||
        (first.evento.division ?? '') != (second.evento.division ?? '') ||
        first.evento.fecha != second.evento.fecha ||
        first.evento.hora != second.evento.hora) {
      return false;
    }
    final firstTeachers = generarFirmaDocentesExcel(first.evento.docentes);
    final secondTeachers = generarFirmaDocentesExcel(second.evento.docentes);
    return firstTeachers.isEmpty ||
        secondTeachers.isEmpty ||
        firstTeachers == secondTeachers;
  }

  EventoMesaExcel _mergeEvents(
    EventoMesaExcel first,
    EventoMesaExcel second,
  ) {
    final firstActa = first.evento.actaUrl?.trim() ?? '';
    final secondActa = second.evento.actaUrl?.trim() ?? '';
    final acta = firstActa.isNotEmpty ? firstActa : secondActa;
    final teachers = first.evento.docentes.isNotEmpty
        ? first.evento.docentes
        : second.evento.docentes;
    final date = first.evento.fecha ?? second.evento.fecha;
    final time = first.evento.hora ?? second.evento.hora;
    final division = first.evento.division ?? second.evento.division;
    final sourceRows = <int>{...first.origen.filas, ...second.origen.filas}.toList()
      ..sort();
    final mergedWarnings = <String>{
      ...first.advertencias,
      ...second.advertencias,
    };
    if (date != null) {
      mergedWarnings.remove('Fecha no informada o no interpretable.');
    }
    if (time != null) {
      mergedWarnings.remove('Horario no informado o no interpretable.');
    }
    if (acta.isNotEmpty) {
      mergedWarnings.remove(
        'La celda indica ACTA, pero no contiene un hipervínculo.',
      );
    }
    final event = EventoExamen(
      id: first.evento.id,
      careerId: first.evento.careerId,
      anio: first.evento.anio ?? second.evento.anio,
      fecha: date,
      hora: time,
      materia: first.evento.materia,
      instancia: first.evento.instancia,
      docentes: teachers,
      division: division,
      actaUrl: acta.isEmpty ? null : acta,
      estado: first.evento.estado,
      tituloEstado: first.evento.tituloEstado,
      mensajeEstado: first.evento.mensajeEstado,
      actaHabilitada: acta.isNotEmpty,
    );
    return EventoMesaExcel(
      evento: event,
      materiaId: first.materiaId,
      coincidencia: first.coincidencia,
      origen: OrigenFilaExcel(
        hoja: first.origen.hoja,
        filas: List<int>.unmodifiable(sourceRows),
        nombreMateriaFuente: first.origen.nombreMateriaFuente,
      ),
      estadoActa: acta.isEmpty
          ? first.estadoActa
          : EstadoActaExcel.disponible,
      advertencias: List<String>.unmodifiable(mergedWarnings),
    );
  }

  (String, EstadoEventoExamen) _cleanSubjectStatus(String source) {
    var value = sanitizarTexto(source).trim();
    var status = EstadoEventoExamen.activa;
    final prefixes = <(RegExp, EstadoEventoExamen)>[
      (RegExp(r'^\s*\[?suspendid[ao]\]?\s*', caseSensitive: false), EstadoEventoExamen.suspendida),
      (RegExp(r'^\s*\[?cancelad[ao]\]?\s*', caseSensitive: false), EstadoEventoExamen.cancelada),
      (RegExp(r'^\s*\[?reprogramad[ao]\]?\s*', caseSensitive: false), EstadoEventoExamen.reprogramada),
    ];
    for (final prefix in prefixes) {
      if (prefix.$1.hasMatch(value)) {
        value = value.replaceFirst(prefix.$1, '').trim();
        status = prefix.$2;
        break;
      }
    }
    return (value, status);
  }

  int _countHyperlinks(HojaOoxmlMesas sheet) {
    return sheet.cells.values
        .where((cell) => (cell.hyperlink?.trim().isNotEmpty ?? false))
        .length;
  }

  String _eventId(String input) {
    final digest = sha256.convert(utf8.encode(input)).toString();
    return 'excel_${digest.substring(0, 24)}';
  }
}

class _HeaderMap {
  const _HeaderMap({required this.row, required this.columns, required this.score});

  final int row;
  final Map<String, int> columns;
  final int score;

  dynamic value(HojaOoxmlMesas sheet, int row, String field) {
    final column = columns[field];
    return column == null ? null : sheet.cell(row, column)?.value;
  }
}

class _ResultadoHoja {
  const _ResultadoHoja({required this.events, required this.diagnostic});

  final List<EventoMesaExcel> events;
  final DiagnosticoHojaExcel diagnostic;
}

extension _FirstLastOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}
