class ConfiguracionFuenteMesasExcel {
  const ConfiguracionFuenteMesasExcel({
    required this.fileId,
    required this.sourcePageUrl,
    required this.parserVersion,
    this.maximumBytes = 15 * 1024 * 1024,
    this.requestTimeout = const Duration(seconds: 35),
  });

  final String fileId;
  final String sourcePageUrl;
  final int parserVersion;
  final int maximumBytes;
  final Duration requestTimeout;

  List<Uri> get downloadCandidates => <Uri>[
    Uri.https('drive.google.com', '/uc', <String, String>{
      'export': 'download',
      'id': fileId,
    }),
    Uri.https('drive.usercontent.google.com', '/download', <String, String>{
      'id': fileId,
      'export': 'download',
      'confirm': 't',
    }),
  ];

  static const current = ConfiguracionFuenteMesasExcel(
    fileId: '1zkPX0IK7ikpRA1qpzgdMunEqd5dVFPGz',
    sourcePageUrl:
        'https://docs.google.com/spreadsheets/u/0/d/1zkPX0IK7ikpRA1qpzgdMunEqd5dVFPGz/htmlview#gid=1407735315',
    parserVersion: 1,
  );
}
