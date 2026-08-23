import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/datos/repositorio_trayectoria_sage_laboratorio.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  const career = CarreraTrayectoriaSageLaboratorio(
    gridRowId: 'row-historia',
    careerKey: 'historia-pscs',
    nombre: 'Profesorado de Historia',
    institucion: 'Profesorado Superior de Ciencias Sociales',
    materias: <MateriaTrayectoriaSageLaboratorio>[
      MateriaTrayectoriaSageLaboratorio(
        idSage: 'ant',
        nombre: 'Antigüedad',
        estadoOriginal: 'Aprobada',
        estado: EstadoMateriaSageLaboratorio.aprobada,
      ),
    ],
  );

  DocumentoAcademicoSage document(
    TipoDocumentoAcademicoSage type, {
    bool disponible = true,
  }) {
    return DocumentoAcademicoSage(
      tipo: type,
      gridRowId: career.gridRowId,
      careerKey: career.careerKey,
      carrera: career.nombre,
      institucion: career.institucion,
      disponible: disponible,
    );
  }

  test('serializa documentos académicos y conserva compatibilidad', () {
    final trajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        document(TipoDocumentoAcademicoSage.situacionAcademica),
        document(TipoDocumentoAcademicoSage.analitico),
        document(TipoDocumentoAcademicoSage.libreta),
      ],
      capturadaEn: DateTime(2026, 7, 17),
    );

    final decoded = TrayectoriaSageLaboratorio.fromJson(trajectory.toJson());

    expect(decoded.versionEsquema, 3);
    expect(decoded.documentos, hasLength(3));
    expect(
      decoded.documentos.first.tipo,
      TipoDocumentoAcademicoSage.situacionAcademica,
    );
    expect(decoded.documentosDeCarrera(career), hasLength(3));
  });

  test('documentosDeCarrera excluye documentos de otra carrera', () {
    final trajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        document(TipoDocumentoAcademicoSage.analitico),
        const DocumentoAcademicoSage(
          tipo: TipoDocumentoAcademicoSage.libreta,
          gridRowId: 'row-geografia',
          careerKey: 'geografia-pscs',
          carrera: 'Profesorado de Geografía',
          institucion: 'Profesorado Superior de Ciencias Sociales',
        ),
      ],
      capturadaEn: DateTime(2026, 7, 17),
    );

    final result = trajectory.documentosDeCarrera(career);

    expect(result, hasLength(1));
    expect(result.single.tipo, TipoDocumentoAcademicoSage.analitico);
  });

  test('conserva documentos deshabilitados para mostrarlos atenuados', () {
    final trajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        document(
          TipoDocumentoAcademicoSage.analitico,
          disponible: false,
        ),
      ],
      capturadaEn: DateTime(2026, 7, 17),
    );

    final decoded = TrayectoriaSageLaboratorio.fromJson(trajectory.toJson());
    final result = decoded.documentosDeCarrera(career);

    expect(result, hasLength(1));
    expect(result.single.disponible, isFalse);
  });

  test('el repositorio persiste documentos deshabilitados', () async {
    const repository = RepositorioTrayectoriaSageLaboratorio();
    final trajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        document(
          TipoDocumentoAcademicoSage.situacionAcademica,
          disponible: false,
        ),
        document(
          TipoDocumentoAcademicoSage.analitico,
          disponible: false,
        ),
        document(
          TipoDocumentoAcademicoSage.libreta,
          disponible: false,
        ),
      ],
      capturadaEn: DateTime(2026, 7, 17),
    );

    final stored = await repository.guardarIdempotente(trajectory);
    final reloaded = await repository.cargar();

    expect(stored.documentos, hasLength(3));
    expect(stored.documentos.every((item) => !item.disponible), isTrue);
    expect(reloaded, isNotNull);
    final loaded = reloaded!;
    expect(loaded.documentos, hasLength(3));
    expect(loaded.documentos.every((item) => !item.disponible), isTrue);
  });

  test('una sincronización Docente deja atenuados documentos previos', () async {
    const repository = RepositorioTrayectoriaSageLaboratorio();
    final studentTrajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        for (final type in TipoDocumentoAcademicoSage.values) document(type),
      ],
      capturadaEn: DateTime(2026, 7, 17),
    );
    final agentTrajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        for (final type in TipoDocumentoAcademicoSage.values)
          document(type, disponible: false),
      ],
      capturadaEn: DateTime(2026, 7, 18),
    );

    await repository.guardarIdempotente(studentTrajectory);
    final stored = await repository.guardarIdempotente(agentTrajectory);

    expect(stored.documentos, hasLength(3));
    expect(stored.documentos.every((item) => !item.disponible), isTrue);
  });

  test('una sincronización Estudiante vuelve a habilitar los documentos', () async {
    const repository = RepositorioTrayectoriaSageLaboratorio();
    final agentTrajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        for (final type in TipoDocumentoAcademicoSage.values)
          document(type, disponible: false),
      ],
      capturadaEn: DateTime(2026, 7, 17),
    );
    final studentTrajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        for (final type in TipoDocumentoAcademicoSage.values) document(type),
      ],
      capturadaEn: DateTime(2026, 7, 18),
    );

    await repository.guardarIdempotente(agentTrajectory);
    final stored = await repository.guardarIdempotente(studentTrajectory);

    expect(stored.documentos, hasLength(3));
    expect(stored.documentos.every((item) => item.disponible), isTrue);
  });

  test('al deduplicar prefiere el documento habilitado', () async {
    const repository = RepositorioTrayectoriaSageLaboratorio();
    final trajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[
        document(
          TipoDocumentoAcademicoSage.analitico,
          disponible: false,
        ),
        document(TipoDocumentoAcademicoSage.analitico),
      ],
      capturadaEn: DateTime(2026, 7, 17),
    );

    final stored = await repository.guardarIdempotente(trajectory);

    expect(stored.documentos, hasLength(1));
    expect(stored.documentos.single.disponible, isTrue);
  });

  test('guardado idempotente elimina documentos duplicados', () async {
    const repository = RepositorioTrayectoriaSageLaboratorio();
    final duplicate = document(TipoDocumentoAcademicoSage.analitico);
    final trajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: <DocumentoAcademicoSage>[duplicate, duplicate],
      capturadaEn: DateTime(2026, 7, 17),
    );

    final stored = await repository.guardarIdempotente(trajectory);
    final reloaded = await repository.cargar();

    expect(stored.documentos, hasLength(1));
    expect(reloaded?.documentos, hasLength(1));
    expect(
      reloaded?.documentos.single.tipo,
      TipoDocumentoAcademicoSage.analitico,
    );
  });

  test('trayectorias antiguas sin documentos siguen cargando', () {
    final legacy = TrayectoriaSageLaboratorio.fromJson(<String, dynamic>{
      'perfil': <String, dynamic>{'nombre': 'Alan'},
      'carreras': <Map<String, dynamic>>[career.toJson()],
      'capturada_en': '2026-07-17T00:00:00.000',
    });

    expect(legacy.versionEsquema, 1);
    expect(legacy.documentos, isEmpty);
    expect(legacy.totalMaterias, 1);
  });
}
