import 'solicitud_verificacion.dart';

enum SituacionVerificacionMateria {
  unverified,
  pending,
  approved,
  rejected,
}

class EstadoVerificacionMateria {
  const EstadoVerificacionMateria({
    required this.status,
    this.request,
  });

  final SituacionVerificacionMateria status;
  final SolicitudVerificacion? request;

  bool get canReview => status == SituacionVerificacionMateria.approved;

  bool get isPending => status == SituacionVerificacionMateria.pending;

  String get label => switch (status) {
        SituacionVerificacionMateria.unverified => 'Sin verificar',
        SituacionVerificacionMateria.pending => 'Pendiente',
        SituacionVerificacionMateria.approved => 'Habilitada',
        SituacionVerificacionMateria.rejected => 'Rechazada',
      };
}
