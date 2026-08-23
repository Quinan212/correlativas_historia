import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/modelos_trayectoria_sage_laboratorio.dart';

class EstadoPersistidoSincronizacionSage {
  const EstadoPersistidoSincronizacionSage({
    this.ultimoIntento,
    this.ultimoExito,
    this.ultimoCodigoError,
    this.ultimoMensajeError,
    this.nombrePerfil,
    this.dniPerfil,
    this.firmaLegajo,
    this.clavesCarrera = const <String>[],
    this.sesionConfirmada = false,
    this.totalSincronizaciones = 0,
    this.fallosConsecutivos = 0,
  });

  final DateTime? ultimoIntento;
  final DateTime? ultimoExito;
  final String? ultimoCodigoError;
  final String? ultimoMensajeError;
  final String? nombrePerfil;
  final String? dniPerfil;
  final String? firmaLegajo;
  final List<String> clavesCarrera;
  final bool sesionConfirmada;
  final int totalSincronizaciones;
  final int fallosConsecutivos;

  EstadoPersistidoSincronizacionSage copyWith({
    DateTime? ultimoIntento,
    DateTime? ultimoExito,
    String? ultimoCodigoError,
    String? ultimoMensajeError,
    String? nombrePerfil,
    String? dniPerfil,
    String? firmaLegajo,
    List<String>? clavesCarrera,
    bool? sesionConfirmada,
    int? totalSincronizaciones,
    int? fallosConsecutivos,
    bool limpiarError = false,
    bool limpiarSesion = false,
    bool reemplazarIdentidad = false,
    bool limpiarIdentidad = false,
  }) {
    return EstadoPersistidoSincronizacionSage(
      ultimoIntento: ultimoIntento ?? this.ultimoIntento,
      ultimoExito: ultimoExito ?? this.ultimoExito,
      ultimoCodigoError: limpiarError
          ? null
          : ultimoCodigoError ?? this.ultimoCodigoError,
      ultimoMensajeError: limpiarError
          ? null
          : ultimoMensajeError ?? this.ultimoMensajeError,
      nombrePerfil: limpiarIdentidad
          ? null
          : reemplazarIdentidad
          ? _nullableText(nombrePerfil)
          : nombrePerfil ?? this.nombrePerfil,
      dniPerfil: limpiarIdentidad
          ? null
          : reemplazarIdentidad
          ? _nullableText(dniPerfil)
          : dniPerfil ?? this.dniPerfil,
      firmaLegajo: limpiarIdentidad
          ? null
          : reemplazarIdentidad
          ? _nullableText(firmaLegajo)
          : firmaLegajo ?? this.firmaLegajo,
      clavesCarrera: clavesCarrera ?? this.clavesCarrera,
      sesionConfirmada: limpiarSesion
          ? false
          : sesionConfirmada ?? this.sesionConfirmada,
      totalSincronizaciones:
          totalSincronizaciones ?? this.totalSincronizaciones,
      fallosConsecutivos: fallosConsecutivos ?? this.fallosConsecutivos,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'ultimo_intento': ultimoIntento?.toIso8601String(),
    'ultimo_exito': ultimoExito?.toIso8601String(),
    'ultimo_codigo_error': ultimoCodigoError,
    'ultimo_mensaje_error': ultimoMensajeError,
    'nombre_perfil': nombrePerfil,
    'dni_perfil': dniPerfil,
    'firma_legajo': firmaLegajo,
    'claves_carrera': clavesCarrera,
    'sesion_confirmada': sesionConfirmada,
    'total_sincronizaciones': totalSincronizaciones,
    'fallos_consecutivos': fallosConsecutivos,
  };

  factory EstadoPersistidoSincronizacionSage.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawCareers = json['claves_carrera'];
    return EstadoPersistidoSincronizacionSage(
      ultimoIntento: DateTime.tryParse(
        (json['ultimo_intento'] ?? '').toString(),
      ),
      ultimoExito: DateTime.tryParse((json['ultimo_exito'] ?? '').toString()),
      ultimoCodigoError: _nullableText(json['ultimo_codigo_error']),
      ultimoMensajeError: _nullableText(json['ultimo_mensaje_error']),
      nombrePerfil: _nullableText(json['nombre_perfil']),
      dniPerfil: _nullableText(json['dni_perfil']),
      firmaLegajo: _nullableText(json['firma_legajo']),
      clavesCarrera: rawCareers is List
          ? List<String>.unmodifiable(
              rawCareers
                  .map((item) => item.toString().trim())
                  .where((item) => item.isNotEmpty),
            )
          : const <String>[],
      sesionConfirmada: json['sesion_confirmada'] == true,
      totalSincronizaciones:
          (json['total_sincronizaciones'] as num?)?.toInt() ?? 0,
      fallosConsecutivos: (json['fallos_consecutivos'] as num?)?.toInt() ?? 0,
    );
  }
}

class RepositorioEstadoSincronizacionSage {
  const RepositorioEstadoSincronizacionSage();

  static const String _storageKey = 'estado_sincronizacion_sage_v2';

  Future<EstadoPersistidoSincronizacionSage> cargar() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const EstadoPersistidoSincronizacionSage();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const EstadoPersistidoSincronizacionSage();
      }
      return EstadoPersistidoSincronizacionSage.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return const EstadoPersistidoSincronizacionSage();
    }
  }

  Future<void> registrarIntento() async {
    final current = await cargar();
    await _guardar(
      current.copyWith(ultimoIntento: DateTime.now(), limpiarError: true),
    );
  }

  Future<void> registrarSesionActiva() async {
    final current = await cargar();
    await _guardar(current.copyWith(sesionConfirmada: true));
  }

  Future<void> registrarError({
    required String codigo,
    required String mensaje,
    bool sesionVencida = false,
  }) async {
    final current = await cargar();
    await _guardar(
      current.copyWith(
        ultimoCodigoError: codigo,
        ultimoMensajeError: mensaje,
        fallosConsecutivos: current.fallosConsecutivos + 1,
        limpiarSesion: sesionVencida,
        limpiarIdentidad: sesionVencida,
      ),
    );
  }

  Future<void> registrarExito(
    TrayectoriaSageLaboratorio trayectoria, {
    String? firmaLegajo,
  }) async {
    final current = await cargar();
    await _guardar(
      current.copyWith(
        ultimoExito: trayectoria.sincronizadaEn ?? DateTime.now(),
        ultimoIntento: DateTime.now(),
        nombrePerfil: trayectoria.perfil.nombre,
        dniPerfil: trayectoria.perfil.dni,
        firmaLegajo: firmaLegajo,
        reemplazarIdentidad: true,
        clavesCarrera: <String>[
          for (final career in trayectoria.carreras) _careerKey(career),
        ],
        sesionConfirmada: true,
        totalSincronizaciones: current.totalSincronizaciones + 1,
        fallosConsecutivos: 0,
        limpiarError: true,
      ),
    );
  }

  Future<void> registrarSesionCerrada() async {
    final current = await cargar();
    await _guardar(
      current.copyWith(limpiarSesion: true, limpiarIdentidad: true),
    );
  }

  Future<void> borrarPreferencias() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  Future<void> _guardar(EstadoPersistidoSincronizacionSage state) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(state.toJson()));
  }

  static String _careerKey(CarreraTrayectoriaSageLaboratorio career) {
    final structural = career.careerKey.trim();
    if (structural.isNotEmpty) return structural;
    return <String>[
      career.nombre.trim().toLowerCase(),
      career.institucion.trim().toLowerCase(),
      career.anioInicio?.toString() ?? '',
    ].join('|');
  }
}

String? _nullableText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
