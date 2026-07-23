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
              fecha: '14/07/2026',
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
              nota: '9',
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
    final antiguedad = stored.carreras.single.materias.firstWhere(
      (subject) => subject.idSage == 'ant',
    );
    expect(antiguedad.estado, EstadoMateriaSageLaboratorio.aprobada);
    expect(antiguedad.nota, '9');
    expect(antiguedad.fecha, '14/07/2026');
    expect(reloaded?.totalMaterias, 2);
    expect(reloaded?.perfil.nombre, 'Alan Gabriel Maillet');
    expect(reloaded?.sincronizadaEn, isNotNull);
  });

  test(
    'conserva nota y fecha previas si una resincronizacion no las informa',
    () async {
      const repository = RepositorioTrayectoriaSageLaboratorio();

      TrayectoriaSageLaboratorio trajectory({String? note, String? date}) {
        return TrayectoriaSageLaboratorio(
          perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
          capturadaEn: DateTime(2026, 7, 20),
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
                  estadoOriginal: 'Aprobada',
                  estado: EstadoMateriaSageLaboratorio.aprobada,
                  anio: 1,
                  nota: note,
                  fecha: date,
                ),
              ],
            ),
          ],
        );
      }

      await repository.guardarIdempotente(
        trajectory(note: '9', date: '14/07/2026'),
      );
      await repository.guardarIdempotente(trajectory());
      final reloaded = await repository.cargar();
      final subject = reloaded!.carreras.single.materias.single;

      expect(subject.nota, '9');
      expect(subject.fecha, '14/07/2026');
    },
  );

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
