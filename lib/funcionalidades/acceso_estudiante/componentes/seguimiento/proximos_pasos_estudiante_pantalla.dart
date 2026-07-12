part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _ItemProximoPaso {
  const _ItemProximoPaso({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
}

class _TarjetaProximoPaso extends StatelessWidget {
  const _TarjetaProximoPaso({required this.item});

  final _ItemProximoPaso item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _TarjetaVidrio(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProximosPasosEstudiantePantalla extends StatelessWidget {
  const _ProximosPasosEstudiantePantalla({
    required this.payload,
    required this.entries,
  });

  final DatosAccesoEstudiante payload;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final student = payload.student;
    final availableEntries = entries
        .where((entry) => entry.current == null && entry.available)
        .toList(growable: false);
    final pendingFinals = entries.where((entry) {
      final current = entry.current;
      if (current == null || _isSubjectApproved(current)) return false;
      return _estadoMateriaParaRequisito(current) == 'regular' ||
          _isSubjectInProgress(current);
    }).toList(growable: false);
    final missingContact = (student.contactPhone?.trim().isEmpty ?? true) ||
        (student.contactEmail?.trim().isEmpty ?? true);

    _CurriculumEntry? bestCandidate;
    var bestUnlockCount = 0;
    for (final entry in availableEntries) {
      final unlockCount = _subjectsUnlockedBy(entry, entries)
          .where((candidate) => candidate.current == null)
          .length;
      if (unlockCount > bestUnlockCount) {
        bestUnlockCount = unlockCount;
        bestCandidate = entry;
      }
    }

    final items = <_ItemProximoPaso>[
      if (availableEntries.isNotEmpty)
        _ItemProximoPaso(
          icon: Icons.task_alt_rounded,
          color: const Color(0xFF0E7490),
          title:
              'Ten\u00e9s ${availableEntries.length} materias disponibles para cursar.',
          detail: availableEntries
              .take(2)
              .map((entry) => entry.materia.displayNombre)
              .join(' \u00b7 '),
        )
      else
        const _ItemProximoPaso(
          icon: Icons.pause_circle_outline_rounded,
          color: Color(0xFF64748B),
          title: 'No hay materias nuevas habilitadas por ahora.',
          detail:
              'Conviene revisar correlativas pendientes o finales en curso.',
        ),
      _ItemProximoPaso(
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFFD97706),
        title:
            'Ten\u00e9s ${pendingFinals.length} finales o cierres pendientes.',
        detail: pendingFinals.isEmpty
            ? 'No hay materias en curso pendientes de cierre.'
            : pendingFinals
                .take(2)
                .map((entry) => entry.materia.displayNombre)
                .join(' \u00b7 '),
      ),
      if (bestCandidate != null)
        _ItemProximoPaso(
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF2EAD57),
          title: 'Conviene priorizar ${bestCandidate.materia.displayNombre}.',
          detail: bestUnlockCount == 0
              ? 'Ya est\u00e1 disponible y ayuda a sostener tu avance actual.'
              : 'Puede habilitar $bestUnlockCount materias posteriores si la aprob\u00e1s.',
        ),
      if (missingContact)
        const _ItemProximoPaso(
          icon: Icons.contact_phone_outlined,
          color: Color(0xFF7C3AED),
          title: 'Faltan completar datos de contacto.',
          detail:
              'Revis\u00e1 tel\u00e9fono y correo en la secci\u00f3n Tus datos.',
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pr\u00f3ximos pasos'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _TarjetaVidrio(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PildoraSeccion(label: 'Orientaci\u00f3n r\u00e1pida'),
                  const SizedBox(height: 12),
                  Text(
                    'Qu\u00e9 conviene hacer ahora',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Leemos tu trayectoria actual para marcar lo m\u00e1s urgente, lo disponible y lo que m\u00e1s impacto puede tener en el recorrido.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final item in items) ...[
              _TarjetaProximoPaso(item: item),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
