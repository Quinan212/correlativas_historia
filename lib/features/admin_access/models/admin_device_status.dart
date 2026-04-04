class AdminDeviceStatus {
  const AdminDeviceStatus({
    required this.deviceId,
    required this.isAdmin,
    required this.message,
    this.adminLabel,
  });

  final String deviceId;
  final bool isAdmin;
  final String message;
  final String? adminLabel;
}
