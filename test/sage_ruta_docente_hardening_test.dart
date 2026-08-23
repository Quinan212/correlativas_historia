import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_perfiles/modelos_perfiles_sage.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/sage/modelos_sincronizacion_sage_automatica.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/sage/pantalla_sage_laboratorio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('usa el perfil Docente cuando es el perfil activo', () {
    final selected = elegirPerfilSincronizacionSage(
      disponibles: const <PerfilSage>[
        PerfilSage.alumnos,
        PerfilSage.agente,
      ],
      activo: PerfilSage.agente,
    );

    expect(selected, PerfilSage.agente);
  });

  test('usa el perfil Estudiante cuando es el perfil activo', () {
    final selected = elegirPerfilSincronizacionSage(
      disponibles: const <PerfilSage>[
        PerfilSage.agente,
        PerfilSage.alumnos,
      ],
      activo: PerfilSage.alumnos,
    );

    expect(selected, PerfilSage.alumnos);
  });

  test('usa el otro perfil después de que falla el perfil activo', () {
    final selected = elegirPerfilSincronizacionSage(
      disponibles: const <PerfilSage>[
        PerfilSage.alumnos,
        PerfilSage.agente,
      ],
      activo: PerfilSage.agente,
      intentados: const <PerfilSage>{PerfilSage.agente},
    );

    expect(selected, PerfilSage.alumnos);
  });

  test('respeta el perfil de respaldo solicitado durante la recuperación', () {
    final selected = elegirPerfilSincronizacionSage(
      disponibles: const <PerfilSage>[
        PerfilSage.alumnos,
        PerfilSage.agente,
      ],
      activo: PerfilSage.alumnos,
      preferido: PerfilSage.agente,
    );

    expect(selected, PerfilSage.agente);
  });

  test('termina cuando ya se intentaron todos los perfiles disponibles', () {
    final selected = elegirPerfilSincronizacionSage(
      disponibles: const <PerfilSage>[
        PerfilSage.alumnos,
        PerfilSage.agente,
      ],
      intentados: const <PerfilSage>{
        PerfilSage.alumnos,
        PerfilSage.agente,
      },
    );

    expect(selected, isNull);
  });

  test('la pantalla automática ya no requiere una ruta forzada', () {
    const screen = PantallaSageLaboratorio(
      modo: ModoPantallaSageLaboratorio.sincronizacionAutomatica,
    );

    expect(screen.modo, ModoPantallaSageLaboratorio.sincronizacionAutomatica);
  });
}
