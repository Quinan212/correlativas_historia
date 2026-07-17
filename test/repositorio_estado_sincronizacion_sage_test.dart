import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/datos/repositorio_estado_sincronizacion_sage.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('registra éxito, perfil, carreras y sesión reutilizable', () async {
    const repository = RepositorioEstadoSincronizacionSage();
    final syncedAt = DateTime(2026, 7, 17, 15, 30);
    final trajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(
        nombre: 'Alan Gabriel Maillet',
        dni: '12345678',
      ),
      capturadaEn: syncedAt,
      sincronizadaEn: syncedAt,
      carreras: const <CarreraTrayectoriaSageLaboratorio>[
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
            ),
          ],
        ),
      ],
    );

    await repository.registrarExito(trajectory, firmaLegajo: 'legajo:12345678');
    final state = await repository.cargar();

    expect(state.ultimoExito, syncedAt);
    expect(state.nombrePerfil, 'Alan Gabriel Maillet');
    expect(state.dniPerfil, '12345678');
    expect(state.firmaLegajo, 'legajo:12345678');
    expect(state.clavesCarrera, contains('historia-pscs'));
    expect(state.sesionConfirmada, isTrue);
    expect(state.totalSincronizaciones, 1);
    expect(state.fallosConsecutivos, 0);
  });

  test('registra error y descarta sesión vencida', () async {
    const repository = RepositorioEstadoSincronizacionSage();

    await repository.registrarSesionActiva();
    await repository.registrarError(
      codigo: 'SAGE-SESION',
      mensaje: 'La sesión venció.',
      sesionVencida: true,
    );
    final state = await repository.cargar();

    expect(state.sesionConfirmada, isFalse);
    expect(state.ultimoCodigoError, 'SAGE-SESION');
    expect(state.ultimoMensajeError, 'La sesión venció.');
    expect(state.fallosConsecutivos, 1);
  });

  test('borrarPreferencias elimina los metadatos', () async {
    const repository = RepositorioEstadoSincronizacionSage();

    await repository.registrarIntento();
    await repository.borrarPreferencias();
    final state = await repository.cargar();

    expect(state.ultimoIntento, isNull);
    expect(state.totalSincronizaciones, 0);
    expect(state.sesionConfirmada, isFalse);
  });
}
