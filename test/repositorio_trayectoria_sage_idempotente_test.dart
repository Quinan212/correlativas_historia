import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/datos/repositorio_trayectoria_sage_laboratorio.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('guardarIdempotente fusiona carreras y materias repetidas', () async {
    const repository = RepositorioTrayectoriaSageLaboratorio();
    final capturedAt = DateTime(2026, 7, 17, 12);
    final draft = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(
        nombre: 'Alan Gabriel Maillet',
        dni: '12345678',
      ),
      capturadaEn: capturedAt,
      carreras: const <CarreraTrayectoriaSageLaboratorio>[
        CarreraTrayectoriaSageLaboratorio(
          gridRowId: 'row-1',
          careerKey: 'historia-pscs',
          nombre: 'Profesorado de Historia',
          institucion: 'Profesorado Superior de Ciencias Sociales',
          materias: <MateriaTrayectoriaSageLaboratorio>[
            MateriaTrayectoriaSageLaboratorio(
              idSage: 'ant',
              nombre: 'Antigüedad',
              estadoOriginal: 'Regular',
              estado: EstadoMateriaSageLaboratorio.regular,
              anio: 1,
            ),
          ],
        ),
        CarreraTrayectoriaSageLaboratorio(
          gridRowId: 'row-1-duplicate',
          careerKey: 'historia-pscs',
          nombre: 'Profesorado de Historia',
          institucion: 'Profesorado Superior de Ciencias Sociales',
          materias: <MateriaTrayectoriaSageLaboratorio>[
            MateriaTrayectoriaSageLaboratorio(
              idSage: 'ant',
              nombre: 'Antigüedad',
              estadoOriginal: 'Aprobada 9',
              estado: EstadoMateriaSageLaboratorio.aprobada,
              anio: 1,
            ),
            MateriaTrayectoriaSageLaboratorio(
              idSage: 'ped',
              nombre: 'Pedagogía',
              estadoOriginal: 'Cursando',
              estado: EstadoMateriaSageLaboratorio.cursando,
              anio: 1,
            ),
          ],
        ),
      ],
    );

    final stored = await repository.guardarIdempotente(draft);
    final reloaded = await repository.cargar();

    expect(stored.carreras, hasLength(1));
    expect(stored.carreras.single.materias, hasLength(2));
    expect(
      stored.carreras.single.materias
          .firstWhere((subject) => subject.idSage == 'ant')
          .estado,
      EstadoMateriaSageLaboratorio.aprobada,
    );
    expect(reloaded?.totalMaterias, 2);
    expect(reloaded?.perfil.nombre, 'Alan Gabriel Maillet');
    expect(reloaded?.sincronizadaEn, isNotNull);
  });

  test('guardarIdempotente reemplaza la copia previa sin duplicar', () async {
    const repository = RepositorioTrayectoriaSageLaboratorio();

    TrayectoriaSageLaboratorio trajectory(String statusText) {
      final approved = statusText == 'Aprobada';
      return TrayectoriaSageLaboratorio(
        perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
        capturadaEn: DateTime(2026, 7, 17),
        carreras: <CarreraTrayectoriaSageLaboratorio>[
          CarreraTrayectoriaSageLaboratorio(
            gridRowId: 'row-1',
            careerKey: 'historia-pscs',
            nombre: 'Profesorado de Historia',
            institucion: 'PSCS',
            materias: <MateriaTrayectoriaSageLaboratorio>[
              MateriaTrayectoriaSageLaboratorio(
                idSage: 'ant',
                nombre: 'Antigüedad',
                estadoOriginal: statusText,
                estado: approved
                    ? EstadoMateriaSageLaboratorio.aprobada
                    : EstadoMateriaSageLaboratorio.cursando,
              ),
            ],
          ),
        ],
      );
    }

    await repository.guardarIdempotente(trajectory('Cursando'));
    await repository.guardarIdempotente(trajectory('Aprobada'));
    final reloaded = await repository.cargar();

    expect(reloaded?.carreras, hasLength(1));
    expect(reloaded?.carreras.single.materias, hasLength(1));
    expect(
      reloaded?.carreras.single.materias.single.estado,
      EstadoMateriaSageLaboratorio.aprobada,
    );
  });
}
