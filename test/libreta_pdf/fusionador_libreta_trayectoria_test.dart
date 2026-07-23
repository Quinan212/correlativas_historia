import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/libreta_pdf/fusionador_libreta_trayectoria.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/libreta_pdf/modelos_libreta_pdf.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const merger = FusionadorLibretaTrayectoria();

  test('agrega nota y fecha a la materia de la misma carrera y año', () {
    final result = merger.aplicar(
      trayectoria: _trayectoria(<MateriaTrayectoriaSageLaboratorio>[
        const MateriaTrayectoriaSageLaboratorio(
          idSage: '8619',
          nombre: 'ORAL. -LECT. - ESCRITURA Y TIC',
          estadoOriginal: 'Aprobada',
          estado: EstadoMateriaSageLaboratorio.aprobada,
          anio: 1,
        ),
      ]),
      gridRowId: 'carrera-1',
      libreta: const ResultadoExtraccionLibretaPdf(
        materias: <MateriaLibretaPdf>[
          MateriaLibretaPdf(
            nombre: 'ORAL. LECT. ESCRITURA Y TIC',
            anio: 1,
            estado: 'Aprobada',
            fecha: '15/11/2024',
            calificacion: '9',
          ),
        ],
      ),
    );

    final subject = result.trayectoria.carreras.single.materias.single;
    expect(result.coincidencias, 1);
    expect(subject.nota, '9');
    expect(subject.fecha, '15/11/2024');
    expect(subject.idSage, '8619');
  });

  test('usa el año para evitar asociar una materia homónima incorrecta', () {
    final result = merger.aplicar(
      trayectoria: _trayectoria(<MateriaTrayectoriaSageLaboratorio>[
        const MateriaTrayectoriaSageLaboratorio(
          idSage: 'a',
          nombre: 'HISTORIA DE LAS IDEAS',
          estadoOriginal: 'Aprobada',
          estado: EstadoMateriaSageLaboratorio.aprobada,
          anio: 1,
        ),
        const MateriaTrayectoriaSageLaboratorio(
          idSage: 'b',
          nombre: 'HISTORIA DE LAS IDEAS',
          estadoOriginal: 'Aprobada',
          estado: EstadoMateriaSageLaboratorio.aprobada,
          anio: 2,
        ),
      ]),
      gridRowId: 'carrera-1',
      libreta: const ResultadoExtraccionLibretaPdf(
        materias: <MateriaLibretaPdf>[
          MateriaLibretaPdf(
            nombre: 'HISTORIA DE LAS IDEAS',
            anio: 2,
            estado: 'Aprobada',
            fecha: '18/12/2025',
            calificacion: '10',
          ),
        ],
      ),
    );

    expect(result.coincidencias, 1);
    expect(result.trayectoria.carreras.single.materias.first.nota, isNull);
    expect(result.trayectoria.carreras.single.materias.last.nota, '10');
  });

  test('no aplica una coincidencia ambigua', () {
    final result = merger.aplicar(
      trayectoria: _trayectoria(<MateriaTrayectoriaSageLaboratorio>[
        const MateriaTrayectoriaSageLaboratorio(
          idSage: 'a',
          nombre: 'MATERIA GENERAL',
          estadoOriginal: 'Aprobada',
          estado: EstadoMateriaSageLaboratorio.aprobada,
          anio: 1,
        ),
        const MateriaTrayectoriaSageLaboratorio(
          idSage: 'b',
          nombre: 'MATERIA GENERAL',
          estadoOriginal: 'Aprobada',
          estado: EstadoMateriaSageLaboratorio.aprobada,
          anio: 1,
        ),
      ]),
      gridRowId: 'carrera-1',
      libreta: const ResultadoExtraccionLibretaPdf(
        materias: <MateriaLibretaPdf>[
          MateriaLibretaPdf(
            nombre: 'MATERIA GENERAL',
            anio: 1,
            estado: 'Aprobada',
            fecha: '01/01/2025',
            calificacion: '8',
          ),
        ],
      ),
    );

    expect(result.coincidencias, 0);
    expect(result.ambiguas, 1);
    expect(
      result.trayectoria.carreras.single.materias.every(
        (subject) => subject.nota == null,
      ),
      isTrue,
    );
  });

  test(
    'relaciona abreviaturas de la Libreta con denominaciones desarrolladas',
    () {
      final result = merger.aplicar(
        trayectoria: _trayectoria(<MateriaTrayectoriaSageLaboratorio>[
          const MateriaTrayectoriaSageLaboratorio(
            idSage: 'cjl',
            nombre: 'Corporeidad, Juegos y Lenguajes Artísticos',
            estadoOriginal: 'Aprobada',
            estado: EstadoMateriaSageLaboratorio.aprobada,
            anio: 1,
          ),
          const MateriaTrayectoriaSageLaboratorio(
            idSage: 'olt',
            nombre: 'Oralidad, Lectura, Escritura y TIC',
            estadoOriginal: 'Aprobada',
            estado: EstadoMateriaSageLaboratorio.aprobada,
            anio: 1,
          ),
        ]),
        gridRowId: 'carrera-1',
        libreta: const ResultadoExtraccionLibretaPdf(
          materias: <MateriaLibretaPdf>[
            MateriaLibretaPdf(
              nombre: 'CORP. JUEGO Y LENGUAJES ARTISTICOS',
              anio: 1,
              estado: 'Aprobada',
              fecha: '21/11/2024',
              calificacion: '10',
            ),
            MateriaLibretaPdf(
              nombre: 'ORAL. -LECT. - ESCRITURA Y TIC',
              anio: 1,
              estado: 'Aprobada',
              fecha: '15/11/2024',
              calificacion: '9',
            ),
          ],
        ),
      );

      expect(result.coincidencias, 2);
      expect(result.trayectoria.carreras.single.materias.first.nota, '10');
      expect(result.trayectoria.carreras.single.materias.last.nota, '9');
    },
  );
}

TrayectoriaSageLaboratorio _trayectoria(
  List<MateriaTrayectoriaSageLaboratorio> subjects,
) {
  return TrayectoriaSageLaboratorio(
    perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Estudiante'),
    carreras: <CarreraTrayectoriaSageLaboratorio>[
      CarreraTrayectoriaSageLaboratorio(
        gridRowId: 'carrera-1',
        careerKey: 'historia',
        nombre: 'Profesorado de Historia',
        institucion: 'Instituto',
        materias: subjects,
      ),
    ],
    capturadaEn: DateTime(2026, 7, 21),
  );
}
