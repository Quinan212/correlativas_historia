part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _TrayectoriaReimaginadaEstudiantePantalla extends StatelessWidget {
  const _TrayectoriaReimaginadaEstudiantePantalla({
    required this.payload,
    required this.entries,
  });

  final DatosAccesoEstudiante payload;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('1'),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFFF6F8FC), Color(0xFFEFF4FB)],
            ),
          ),
          child: Center(child: Text('', style: theme.textTheme.bodyMedium)),
        ),
      ),
    );
  }
}
