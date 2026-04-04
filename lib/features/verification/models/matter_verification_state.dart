import 'verification_request.dart';

enum MatterVerificationStatus {
  unverified,
  pending,
  approved,
  rejected,
}

class MatterVerificationState {
  const MatterVerificationState({
    required this.status,
    this.request,
  });

  final MatterVerificationStatus status;
  final VerificationRequest? request;

  bool get canReview => status == MatterVerificationStatus.approved;

  bool get isPending => status == MatterVerificationStatus.pending;

  String get label => switch (status) {
        MatterVerificationStatus.unverified => 'Sin verificar',
        MatterVerificationStatus.pending => 'Pendiente',
        MatterVerificationStatus.approved => 'Habilitada',
        MatterVerificationStatus.rejected => 'Rechazada',
      };
}
