import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../configuracion/configuracion_fuente_mesas_excel.dart';
import '../datos/descargador_mesas_excel.dart';
import '../datos/repositorio_catalogo_materias_excel.dart';
import '../datos/repositorio_local_mesas_excel.dart';
import '../dominio/importador_mesas_excel.dart';
import '../modelos/modelos_mesas_excel.dart';

enum EtapaActualizacionMesasExcel {
  inactiva,
  descargando,
  interpretando,
  validando,
  guardando,
}

class ControladorMesasExcel extends ChangeNotifier {
  ControladorMesasExcel({
    DescargadorMesasExcel? descargador,
    RepositorioCatalogoMateriasExcel? catalogo,
    RepositorioLocalMesasExcel? repositorioLocal,
    ImportadorMesasExcel? importador,
    this.minimumAutomaticRefresh = const Duration(minutes: 30),
  }) : _descargador = descargador ?? DescargadorMesasExcel(),
       _catalogo = catalogo ?? const RepositorioCatalogoMateriasExcel(),
       _repositorioLocal =
           repositorioLocal ?? const RepositorioLocalMesasExcel(),
       _importador = importador ?? const ImportadorMesasExcel();

  final DescargadorMesasExcel _descargador;
  final RepositorioCatalogoMateriasExcel _catalogo;
  final RepositorioLocalMesasExcel _repositorioLocal;
  final ImportadorMesasExcel _importador;
  final Duration minimumAutomaticRefresh;

  EstadoFuenteMesasExcel _estado = EstadoFuenteMesasExcel.inicializando;
  EtapaActualizacionMesasExcel _etapaActualizacion =
      EtapaActualizacionMesasExcel.inactiva;
  List<EventoMesaExcel> _eventos = const <EventoMesaExcel>[];
  CopiaLocalMesasExcel? _copiaLocal;
  DiagnosticoLibroExcel? _diagnostico;
  MetadatosFuenteMesasExcel? _metadatos;
  String? _mensajeError;
  bool _initialized = false;
  bool _disposed = false;
  Future<void>? _runningUpdate;

  EstadoFuenteMesasExcel get estado => _estado;
  EtapaActualizacionMesasExcel get etapaActualizacion => _etapaActualizacion;
  List<EventoMesaExcel> get eventos => _eventos;
  DiagnosticoLibroExcel? get diagnostico => _diagnostico;
  MetadatosFuenteMesasExcel? get metadatos => _metadatos;
  String? get mensajeError => _mensajeError;
  bool get tieneDatos => _eventos.isNotEmpty && _estado.permiteMostrarDatos;
  bool get estaComprobando => _estado.estaComprobando;

  int get totalActas =>
      _eventos.where((item) => item.evento.puedeAbrirActa).length;

  int get totalLlamados => _eventos
      .where((item) => item.evento.instancia.startsWith('llamado_'))
      .length;

  int get totalColoquios =>
      _eventos.where((item) => item.evento.instancia == 'coloquio').length;

  DateTime? get proximoEvento {
    final now = DateTime.now();
    DateTime? result;
    for (final item in _eventos) {
      final date = item.evento.fechaHora;
      if (date == null || date.isBefore(now)) continue;
      if (result == null || date.isBefore(result)) result = date;
    }
    return result;
  }

  Future<void> inicializar() async {
    if (_initialized || _disposed) return;
    _initialized = true;
    try {
      final local = await _repositorioLocal.cargar();
      if (_disposed) return;
      if (local != null &&
          local.metadatos.parserVersion ==
              ConfiguracionFuenteMesasExcel.current.parserVersion &&
          local.diagnostico.publicable) {
        _adoptarCopiaLocal(
          local,
          estado: EstadoFuenteMesasExcel.disponibleDesdeCopiaLocal,
        );
      }
    } catch (error) {
      _mensajeError = 'No se pudo leer la copia local: $error';
    }
    _notificar();
    await actualizar(automatic: true);
  }

  Future<void> actualizar({bool force = false, bool automatic = false}) async {
    final running = _runningUpdate;
    if (running != null) {
      await running;
      return;
    }

    final operation = _actualizarInterno(force: force, automatic: automatic);
    _runningUpdate = operation;
    try {
      await operation;
    } finally {
      if (identical(_runningUpdate, operation)) {
        _runningUpdate = null;
      }
    }
  }

  Future<void> _actualizarInterno({
    required bool force,
    required bool automatic,
  }) async {
    if (_disposed) return;
    final current = _copiaLocal;
    if (automatic && !force && current != null) {
      final age = DateTime.now().toUtc().difference(
        current.metadatos.checkedAt.toUtc(),
      );
      if (age >= Duration.zero && age < minimumAutomaticRefresh) {
        return;
      }
    }

    _estado = EstadoFuenteMesasExcel.comprobando;
    _etapaActualizacion = EtapaActualizacionMesasExcel.descargando;
    _mensajeError = null;
    _notificar();

    try {
      final download = await _descargador.descargar(
        eTag: current?.metadatos.eTag,
        lastModified: current?.metadatos.lastModified,
        force: force,
      );
      if (_disposed) return;

      if (download.notModified) {
        if (current == null) {
          throw const ExcepcionDescargaMesasExcel(
            'La fuente informó que no cambió, pero no existe una copia local.',
          );
        }
        _actualizarEtapa(EtapaActualizacionMesasExcel.guardando);
        final updatedMetadata = current.metadatos.copyWith(
          checkedAt: download.checkedAt,
          eTag: download.eTag,
          lastModified: download.lastModified,
        );
        final updatedCopy = CopiaLocalMesasExcel(
          eventos: current.eventos,
          metadatos: updatedMetadata,
          diagnostico: current.diagnostico,
        );
        await _repositorioLocal.guardarAtomico(updatedCopy);
        if (_disposed) return;
        _adoptarCopiaLocal(
          updatedCopy,
          estado: EstadoFuenteMesasExcel.sinCambios,
        );
        return;
      }

      final bytes = download.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('La descarga no contiene datos XLSX.');
      }
      final hash = sha256.convert(bytes).toString();
      if (!force && current != null && current.metadatos.sourceHash == hash) {
        _actualizarEtapa(EtapaActualizacionMesasExcel.guardando);
        final updatedMetadata = current.metadatos.copyWith(
          checkedAt: download.checkedAt,
          eTag: download.eTag,
          lastModified: download.lastModified,
          sourceSize: bytes.length,
        );
        final updatedCopy = CopiaLocalMesasExcel(
          eventos: current.eventos,
          metadatos: updatedMetadata,
          diagnostico: current.diagnostico,
        );
        await _repositorioLocal.guardarAtomico(updatedCopy);
        if (_disposed) return;
        _adoptarCopiaLocal(
          updatedCopy,
          estado: EstadoFuenteMesasExcel.sinCambios,
        );
        return;
      }

      _actualizarEtapa(EtapaActualizacionMesasExcel.interpretando);
      await Future<void>.delayed(Duration.zero);
      final catalog = await _catalogo.cargar();
      final imported = _importador.importar(bytes: bytes, catalogo: catalog);
      _actualizarEtapa(EtapaActualizacionMesasExcel.validando);
      await Future<void>.delayed(Duration.zero);
      if (_disposed) return;
      _diagnostico = imported.diagnostico;

      if (!imported.diagnostico.publicable) {
        _eventos = const <EventoMesaExcel>[];
        _etapaActualizacion = EtapaActualizacionMesasExcel.inactiva;
        _estado = _estadoParaDiagnostico(imported.diagnostico);
        _mensajeError = _mensajeDiagnostico(imported.diagnostico);
        _notificar();
        return;
      }

      final now = DateTime.now().toUtc();
      final metadata = MetadatosFuenteMesasExcel(
        parserVersion: ConfiguracionFuenteMesasExcel.current.parserVersion,
        checkedAt: download.checkedAt,
        validatedAt: now,
        sourceHash: hash,
        sourceSize: bytes.length,
        eTag: download.eTag,
        lastModified: download.lastModified,
      );
      _actualizarEtapa(EtapaActualizacionMesasExcel.guardando);
      final copy = CopiaLocalMesasExcel(
        eventos: imported.eventos,
        metadatos: metadata,
        diagnostico: imported.diagnostico,
      );
      await _repositorioLocal.guardarAtomico(copy);
      if (_disposed) return;
      _adoptarCopiaLocal(copy, estado: EstadoFuenteMesasExcel.disponible);
    } on ExcepcionDescargaMesasExcel catch (error) {
      _manejarErrorDeRed(error.message);
    } on FormatException catch (error) {
      _etapaActualizacion = EtapaActualizacionMesasExcel.inactiva;
      _eventos = const <EventoMesaExcel>[];
      _estado = EstadoFuenteMesasExcel.archivoInvalido;
      _mensajeError = error.message;
      _notificar();
    } catch (error, stackTrace) {
      debugPrint('Error en laboratorio de mesas Excel: $error\n$stackTrace');
      _etapaActualizacion = EtapaActualizacionMesasExcel.inactiva;
      _eventos = const <EventoMesaExcel>[];
      _estado = EstadoFuenteMesasExcel.noDisponible;
      _mensajeError = 'No se pudo completar la validación del archivo.';
      _notificar();
    }
  }

  void _manejarErrorDeRed(String message) {
    final local = _copiaLocal;
    if (local != null && local.eventos.isNotEmpty) {
      _adoptarCopiaLocal(local, estado: EstadoFuenteMesasExcel.sinConexion);
      _mensajeError = message;
      _notificar();
      return;
    }
    _etapaActualizacion = EtapaActualizacionMesasExcel.inactiva;
    _eventos = const <EventoMesaExcel>[];
    _estado = EstadoFuenteMesasExcel.noDisponible;
    _mensajeError = message;
    _notificar();
  }

  void _adoptarCopiaLocal(
    CopiaLocalMesasExcel copy, {
    required EstadoFuenteMesasExcel estado,
  }) {
    _etapaActualizacion = EtapaActualizacionMesasExcel.inactiva;
    _copiaLocal = copy;
    _eventos = List<EventoMesaExcel>.unmodifiable(copy.eventos);
    _metadatos = copy.metadatos;
    _diagnostico = copy.diagnostico;
    _estado = estado;
    _mensajeError = null;
    _notificar();
  }

  EstadoFuenteMesasExcel _estadoParaDiagnostico(
    DiagnosticoLibroExcel diagnostic,
  ) {
    if (diagnostic.hojas.any(
      (sheet) => sheet.errores.any(
        (error) => error.contains('encabezados compatible'),
      ),
    )) {
      return EstadoFuenteMesasExcel.estructuraIncompatible;
    }
    return EstadoFuenteMesasExcel.datosIncoherentes;
  }

  String _mensajeDiagnostico(DiagnosticoLibroExcel diagnostic) {
    if (diagnostic.erroresBloqueantes.isEmpty) {
      return 'La fuente no superó los controles de integridad.';
    }
    return diagnostic.erroresBloqueantes.first;
  }

  void _actualizarEtapa(EtapaActualizacionMesasExcel value) {
    if (_etapaActualizacion == value || _disposed) return;
    _etapaActualizacion = value;
    _notificar();
  }

  void _notificar() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _descargador.dispose();
    super.dispose();
  }
}
