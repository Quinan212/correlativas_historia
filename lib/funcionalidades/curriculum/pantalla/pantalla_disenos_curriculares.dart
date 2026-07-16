import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../compartido/proveedores/estado_app.dart';
import '../../../compartido/supabase/proveedores_supabase.dart';
import '../../../datos/cargador_fuente_html.dart';
import '../../../modelos/materia.dart';
import '../proveedores/proveedores_curriculum.dart';
import 'pantalla_detalle_curriculum.dart';

class PantallaDisenosCurriculares extends ConsumerStatefulWidget {
  const PantallaDisenosCurriculares({super.key});

  @override
  ConsumerState<PantallaDisenosCurriculares> createState() =>
      _PantallaDisenosCurricularesState();
}

class _PantallaDisenosCurricularesState
    extends ConsumerState<PantallaDisenosCurriculares> {
  static final _cache = <String, List<Materia>>{};
  List<Materia> _materias = [];
  bool _loading = true;
  Set<String> _idsConContenido = {};
  int _vistoMensajePerezoso = 0;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  Future<void> _cargarMaterias() async {
    try {
      String? careerId;
      final session = ref.read(proveedorClienteSupabase)?.auth.currentSession;
      if (session != null) {
        careerId = session.user.userMetadata?['career_id'] as String?;
      }
      careerId ??= ref.read(proveedorCarreraSeleccionada).id;

      if (_cache.containsKey(careerId)) {
        setState(() {
          _materias = _cache[careerId]!;
          _loading = false;
        });
        return;
      }

      String asset = 'assets/historia.html';
      if (careerId == 'politica') asset = 'assets/politica.html';
      if (careerId == 'geografia') asset = 'assets/geografia.html';
      if (careerId == 'artes_visuales') asset = 'assets/Artes_visuales.html';

      final plan = await cargarPlanDesdeAssetHtml(asset);
      if (!mounted) return;
      _cache[careerId] = plan.materias;
      setState(() {
        _materias = plan.materias;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Map<int, List<Materia>> _agruparPorAnio() {
    final map = <int, List<Materia>>{};
    for (final m in _materias) {
      map.putIfAbsent(m.anio, () => []).add(m);
    }
    return map;
  }

  void _abrirDetalle(Materia materia) {
    if (materia.anio >= 3 && !_idsConContenido.contains(materia.id)) {
      _mostrarMensajePerezoso();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaDetalleCurriculum(materiaId: materia.id),
      ),
    );
  }

  void _mostrarMensajePerezoso() {
    _vistoMensajePerezoso++;
    final mensaje = _vistoMensajePerezoso <= 2
        ? 'Lo siento, Alan es muy flojo y todavía no cargó esta materia.\n\n'
            'Mandale 5 memes para demostrar interés en que se cargue pronto.\n\n'
            '¡Gracias!'
        : 'Ya... está bien, lo descubriste.\n\n'
            'Ninguna materia de 3° ni 4° año está cargada todavía en Historia.\n\n'
            'Gracias por tu atención, pronto estarán subidas.';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.sentiment_very_dissatisfied_rounded, size: 48),
        title: const Text('¡Ups!'),
        content: Text(mensaje),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? cs.surface : const Color(0xFFF5F7FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final agrupadas = _agruparPorAnio();
    final anios = agrupadas.keys.toList()..sort();
    final contenidos =
        ref.watch(proveedorContenidosCurriculares).value ?? [];
    final idsConContenido = contenidos.map((c) => c.id).toSet();
    _idsConContenido = idsConContenido;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : const Color(0xFFF5F7FA),
      appBar: const _BannerDisenosAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
const SizedBox(height: 16),
          for (final anio in anios) ...[
            _AnioHeader(anio: anio, cs: cs, isDark: isDark),
            const SizedBox(height: 8),
            for (final m in agrupadas[anio]!)
              _MateriaCard(
                materia: m,
                habilitada: idsConContenido.contains(m.id) || m.anio >= 3,
                cs: cs,
                isDark: isDark,
                onTap: () => _abrirDetalle(m),
              ),
            const SizedBox(height: 16),
          ],
const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AnioHeader extends StatelessWidget {
  final int anio;
  final ColorScheme cs;
  final bool isDark;

  const _AnioHeader({
    required this.anio,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.10),
            ),
            child: Center(
              child: Text(
                '${anio}°',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: cs.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${anio}° Año',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? cs.onSurface : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _MateriaCard extends StatelessWidget {
  final Materia materia;
  final bool habilitada;
  final ColorScheme cs;
  final bool isDark;
  final VoidCallback onTap;

  const _MateriaCard({
    required this.materia,
    required this.habilitada,
    required this.cs,
    required this.isDark,
    required this.onTap,
  });

  static Color _colorFormato(String tipo) {
    switch (tipo.trim()) {
      case 'Formación Específica':
        return const Color(0xFF059669);
      case 'Práctica Profesional':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF0E5E86);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: habilitada ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
              ),
              boxShadow: const [
                BoxShadow(blurRadius: 4, color: Color(0x0F000000)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
                  child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  color: _colorFormato(materia.tipo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materia.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? cs.onSurface : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _MiniChip(label: materia.formato, cs: cs, isDark: isDark),
                          const SizedBox(width: 6),
                          _MiniChip(label: materia.tipo, cs: cs, isDark: isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                  habilitada ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
                  size: habilitada ? 24 : 18,
                  color: isDark
                      ? cs.onSurfaceVariant.withValues(alpha: habilitada ? 1 : 0.4)
                      : habilitada
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                ),
                ),
              ],
            ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  final bool isDark;

  const _MiniChip({
    required this.label,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? cs.onSurfaceVariant.withValues(alpha: 0.08)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? cs.onSurfaceVariant : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}


class _BannerDisenosAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _BannerDisenosAppBar();

  static const _c1 = Color(0xFF005B7F);
  static const _c2 = Color(0xFF004966);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _c1,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: kToolbarHeight,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diseños Curriculares'),
          Text(
            'Resolución Nº 0765-14 CGE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_c1, _c2],
          ),
        ),
      ),
    );
  }
}
