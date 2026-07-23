import 'package:correlativas_historia/funcionalidades/examenes/modelos/evento_examen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventoExamen con control remoto', () {
    test('interpreta una suspensión configurada en Supabase', () {
      final event = EventoExamen.fromJson({
        'id': 'exam-1',
        'career_id': 'historia',
        'anio': 2,
        'fecha': '2026-07-21',
        'hora': '18:30:00',
        'materia': 'Problemática del Conocimiento Histórico',
        'instancia': 'llamado_1',
        'docentes': const ['Docente Uno'],
        'estado': 'suspendida',
        'titulo_estado': 'Mesa suspendida por la institución',
        'mensaje_estado': 'Se informará una nueva fecha.',
        'acta_habilitada': false,
        'visible': true,
      });

      expect(event.estado, EstadoEventoExamen.suspendida);
      expect(event.suspendido, isTrue);
      expect(event.tituloEstadoEfectivo, 'Mesa suspendida por la institución');
      expect(event.mensajeEstadoEfectivo, 'Se informará una nueva fecha.');
      expect(event.puedeAbrirActa, isFalse);
    });

    test('usa nueva fecha y hora cuando la mesa está reprogramada', () {
      final event = EventoExamen.fromJson({
        'id': 'exam-2',
        'career_id': 'historia',
        'anio': 3,
        'fecha': '2026-07-21',
        'hora': '18:30',
        'materia': 'Historia Argentina',
        'instancia': 'llamado_2',
        'docentes': const <String>[],
        'acta_url': 'https://example.com/acta',
        'estado': 'reprogramada',
        'fecha_reprogramada': '2026-07-28',
        'hora_reprogramada': '20:00',
        'acta_habilitada': true,
        'visible': true,
      });

      expect(event.estado, EstadoEventoExamen.reprogramada);
      expect(event.fechaVigente, DateTime(2026, 7, 28));
      expect(event.horaVigente, '20:00');
      expect(event.fechaHora, DateTime(2026, 7, 28, 20));
      expect(event.tieneFechaOriginalDistinta, isTrue);
      expect(event.puedeAbrirActa, isTrue);
    });

    test('muestra el acta en cualquier estado cuando está habilitada', () {
      final event = EventoExamen.fromJson({
        'id': 'exam-3',
        'career_id': 'historia',
        'anio': 3,
        'fecha': '2026-07-21',
        'hora': '18:30',
        'materia': 'Historia Argentina',
        'instancia': 'llamado_1',
        'docentes': const <String>[],
        'acta_url': 'https://example.com/acta',
        'estado': 'activa',
        'acta_habilitada': true,
        'visible': true,
      });

      expect(event.puedeAbrirActa, isTrue);
      expect(
        event.copyWith(estado: EstadoEventoExamen.suspendida).puedeAbrirActa,
        isTrue,
      );
      expect(
        event.copyWith(estado: EstadoEventoExamen.cancelada).puedeAbrirActa,
        isTrue,
      );
      expect(
        event.copyWith(estado: EstadoEventoExamen.reprogramada).puedeAbrirActa,
        isTrue,
      );
      expect(event.copyWith(actaHabilitada: false).puedeAbrirActa, isFalse);
      expect(event.copyWith(actaUrl: '').puedeAbrirActa, isFalse);
    });

    test('mantiene compatibilidad con el booleano suspendido anterior', () {
      final event = EventoExamen.fromJson({
        'career_id': 'historia',
        'anio': 1,
        'fecha': '2026-07-21',
        'hora': '18:30',
        'materia': 'Historia Antigua',
        'instancia': 'llamado_1',
        'docentes': const <String>[],
        'suspendido': true,
      });

      expect(event.estado, EstadoEventoExamen.suspendida);
      expect(event.tituloEstadoEfectivo, 'MESA SUSPENDIDA');
      expect(
        event.mensajeEstadoEfectivo,
        'Pendiente de reprogramación por la institución.',
      );
    });

    test('una mesa oculta conserva su estado para el repositorio', () {
      final event = EventoExamen.fromJson({
        'career_id': 'historia',
        'anio': 1,
        'fecha': '2026-07-21',
        'hora': '18:30',
        'materia': 'Historia Antigua',
        'instancia': 'llamado_1',
        'docentes': const <String>[],
        'visible': false,
      });

      expect(event.visible, isFalse);
    });
  });
}
