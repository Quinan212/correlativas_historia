part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _DatosEstudiantePantalla extends StatefulWidget {
  const _DatosEstudiantePantalla({
    required this.student,
    required this.onSaveContact,
  });

  final PerfilAccesoEstudiante student;
  final Future<void> Function({
    required String phone,
    required String email,
    String? firstName,
    String? lastName,
    String? dni,
    String? careerId,
    String? division,
    int? currentYear,
    int? cohortYear,
  }) onSaveContact;

  @override
  State<_DatosEstudiantePantalla> createState() =>
      _DatosEstudiantePantallaState();
}

class _DatosEstudiantePantallaState extends State<_DatosEstudiantePantalla> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _dniCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _lastNameCtrl;
  late String _selectedCareer;
  late String _selectedDivision;
  late int? _selectedYear;
  late int? _selectedCohort;

  bool _showAcademic = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  static const List<int> _aniosValidos = [1, 2, 3, 4];
  static const List<int> _cohortesValidas = [
    2018,
    2019,
    2020,
    2021,
    2022,
    2023,
    2024,
    2025,
    2026,
  ];

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.student.contactPhone ?? '');
    _emailCtrl = TextEditingController(text: widget.student.contactEmail ?? '');
    _nameCtrl = TextEditingController(text: widget.student.firstName);
    _lastNameCtrl = TextEditingController(text: widget.student.lastName);
    _selectedDivision = switch (widget.student.division?.toUpperCase()) {
      'B' => 'B',
      _ => 'A',
    };
    _dniCtrl = TextEditingController(
        text:
            widget.student.dni.startsWith('guest_') ? '' : widget.student.dni);
    _selectedCareer = widget.student.careerId;
    _selectedYear = widget.student.currentYear;
    _selectedCohort = widget.student.cohortYear;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _dniCtrl.dispose();
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dni = _dniCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{7,9}$').hasMatch(dni)) {
      setState(() => _error = 'El DNI debe tener entre 7 y 9 dígitos.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSaveContact(
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        firstName: _nameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        dni: dni,
        careerId: _selectedCareer,
        division: _selectedDivision,
        currentYear: _selectedYear,
        cohortYear: _selectedCohort,
      );
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados.')),
      );
    } on DniEnUsoException {
      if (!mounted) return;
      await _mostrarDniEnUso();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _mostrarDniEnUso() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('DNI ya registrado'),
        content: const Text(
          'Ese DNI pertenece a otro usuario. No se realizó ningún cambio.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyValue(String label, String value) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final student = widget.student;
    final scheme = theme.colorScheme;
    final primaryBlue = const Color(0xFF0E5E86);
    final editableCareers = kCareers
        .where(
          (career) => const {
            'artes_visuales',
            'musica',
            'historia',
            'geografia',
            'politica',
          }.contains(career.id),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Text(
          'Tus datos',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => _copyValue(
              'Datos',
              '${student.fullName}\nDNI ${student.dni}\n${_etiquetaCarrera(student.careerId)}\n${student.yearLabel}',
            ),
            icon: const Icon(Icons.content_copy_rounded),
            tooltip: 'Copiar datos',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD9E2EE)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _BotonTabDatosEstudiante(
                        label: 'Académicos',
                        selected: _showAcademic,
                        onTap: () => setState(() => _showAcademic = true),
                      ),
                    ),
                    Expanded(
                      child: _BotonTabDatosEstudiante(
                        label: 'Contacto',
                        selected: !_showAcademic,
                        onTap: () => setState(() => _showAcademic = false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_showAcademic) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        student.isDemo
                            ? 'Perfil temporal'
                            : 'Desde la institución',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF182234),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _editing = !_editing),
                      child: Text(_editing ? 'Cancelar' : 'Editar'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _SeccionDatosEstudiante(
                  child: Column(
                    children: [
                      if (_editing) ...[
                        TextField(
                          controller: _nameCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Nombres'),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _lastNameCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Apellido'),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _dniCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLength: 9,
                          decoration: const InputDecoration(
                            labelText: 'DNI',
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DropdownCarreraEstudiante(
                          value: _selectedCareer,
                          careers: editableCareers,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCareer = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDivision,
                          decoration:
                              const InputDecoration(labelText: 'División'),
                          items: const [
                            DropdownMenuItem(value: 'A', child: Text('A')),
                            DropdownMenuItem(value: 'B', child: Text('B')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedDivision = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _DropdownEnteroEstudiante(
                          label: 'Año actual',
                          values: _aniosValidos,
                          selectedValue: _selectedYear,
                          valueLabel: (year) => switch (year) {
                            1 => '1er año',
                            2 => '2do año',
                            3 => '3er año',
                            4 => '4to año',
                            _ => '$year° año',
                          },
                          onChanged: (value) =>
                              setState(() => _selectedYear = value),
                        ),
                        const SizedBox(height: 12),
                        _DropdownEnteroEstudiante(
                          label: 'Cohorte',
                          values: _cohortesValidas,
                          selectedValue: _selectedCohort,
                          valueLabel: (year) => '$year',
                          onChanged: (value) =>
                              setState(() => _selectedCohort = value),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: primaryBlue,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Guardar cambios'),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.error),
                          ),
                        ],
                      ] else ...[
                        _BaldosaDatosEstudiante(
                          label: 'Nombres',
                          value: student.firstName,
                          onCopy: () =>
                              _copyValue('Nombres', student.firstName),
                        ),
                        _BaldosaDatosEstudiante(
                          label: 'Apellido',
                          value: student.lastName,
                          onCopy: () =>
                              _copyValue('Apellido', student.lastName),
                        ),
                        _BaldosaDatosEstudiante(
                          label: 'DNI',
                          value: student.dni.startsWith('guest_')
                              ? 'No especificado'
                              : student.dni,
                          onCopy: () => _copyValue('DNI', student.dni),
                        ),
                        _BaldosaDatosEstudiante(
                          label: 'Carrera',
                          value: _etiquetaCarrera(student.careerId),
                          onCopy: () => _copyValue(
                              'Carrera', _etiquetaCarrera(student.careerId)),
                        ),
                        _BaldosaDatosEstudiante(
                          label: 'Año actual',
                          value: student.yearLabel,
                          onCopy: () =>
                              _copyValue('Año actual', student.yearLabel),
                        ),
                        _BaldosaDatosEstudiante(
                          label: 'Cohorte',
                          value: student.cohortYear != null
                              ? '${student.cohortYear}'
                              : 'No especificada',
                          onCopy: () => _copyValue(
                            'Cohorte',
                            student.cohortYear != null
                                ? '${student.cohortYear}'
                                : '',
                          ),
                        ),
                      ],
                      if (!_editing)
                        _BaldosaDatosEstudiante(
                          label: 'División',
                          value: (student.division?.trim().isNotEmpty ?? false)
                              ? student.division!
                              : 'A',
                          onCopy: () => _copyValue(
                            'División',
                            (student.division?.trim().isNotEmpty ?? false)
                                ? student.division!
                                : 'A',
                          ),
                        ),
                      _BaldosaDatosEstudiante(
                        label: 'Estado',
                        value: _etiquetaEstadoInscripcion(
                            student.enrollmentStatus),
                        onCopy: () => _copyValue(
                          'Estado',
                          _etiquetaEstadoInscripcion(student.enrollmentStatus),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _copyValue(
                          'Datos',
                          '${student.fullName}\nDNI ${student.dni}\n${_etiquetaCarrera(student.careerId)}\n${student.yearLabel}',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE7F0FB),
                          foregroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('Compartir datos'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showAcademic = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,
                          side: const BorderSide(color: Color(0xFFD9E2EE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('Ver contacto'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Desde la app',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF182234),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _editing = !_editing),
                      child: Text(_editing ? 'Cancelar' : 'Editar'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _SeccionDatosEstudiante(
                  child: Column(
                    children: [
                      _BaldosaEditableEstudiante(
                        label: 'Celular',
                        value: student.contactPhone ?? '',
                        hint: 'Agregá tu teléfono',
                        controller: _phoneCtrl,
                        enabled: _editing && !_saving,
                        keyboardType: TextInputType.phone,
                      ),
                      _BaldosaEditableEstudiante(
                        label: 'E-mail',
                        value: student.contactEmail ?? '',
                        hint: 'Agregá tu e-mail',
                        controller: _emailCtrl,
                        enabled: _editing && !_saving,
                        keyboardType: TextInputType.emailAddress,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: !_editing || _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE7F0FB),
                          foregroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: Text(_saving ? 'Guardando...' : 'Guardar datos'),
                      ),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MateriasEstudiantePantalla extends StatefulWidget {
  const _MateriasEstudiantePantalla({
    required this.payload,
    required this.planFuture,
  });

  final DatosAccesoEstudiante payload;
  final Future<List<Materia>> planFuture;

  @override
  State<_MateriasEstudiantePantalla> createState() =>
      _MateriasEstudiantePantallaState();
}

class _MateriasEstudiantePantallaState
    extends State<_MateriasEstudiantePantalla> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedYear = 0;
  String _selectedStatus = 'todos';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF0E5E86);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Text(
          'Materias',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: FutureBuilder<List<Materia>>(
          future: widget.planFuture,
          builder: (context, snapshot) {
            final plan = snapshot.data ?? const <Materia>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _TarjetaMaterias(
                  payload: widget.payload,
                  plan: plan,
                  history: widget.payload.history,
                  loadingPlan: snapshot.connectionState != ConnectionState.done,
                  query: _searchCtrl.text,
                  searchController: _searchCtrl,
                  selectedYear: _selectedYear,
                  selectedStatus: _selectedStatus,
                  onYearSelected: (year) =>
                      setState(() => _selectedYear = year),
                  onStatusSelected: (status) =>
                      setState(() => _selectedStatus = status),
                  onQueryChanged: (_) => setState(() {}),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BarraInferiorDetalle(
          onTap: () => Navigator.of(context).pop(),
          label: 'Cerrar y volver',
        ),
      ),
    );
  }
}

class _SeccionDatosEstudiante extends StatelessWidget {
  const _SeccionDatosEstudiante({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: child,
    );
  }
}

class _BotonTabDatosEstudiante extends StatelessWidget {
  const _BotonTabDatosEstudiante({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: selected
              ? Border.all(
                  color: const Color(0xFFD9E2EE),
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: selected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _BaldosaDatosEstudiante extends StatelessWidget {
  const _BaldosaDatosEstudiante({
    required this.label,
    required this.value,
    required this.onCopy,
    this.isLast = false,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.35),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _BotonAccionDatos(
            icon: Icons.content_copy_rounded,
            onTap: onCopy,
          ),
        ],
      ),
    );
  }
}

class _BaldosaEditableEstudiante extends StatelessWidget {
  const _BaldosaEditableEstudiante({
    required this.label,
    required this.value,
    required this.hint,
    required this.controller,
    required this.enabled,
    required this.keyboardType,
    this.isLast = false,
  });

  final String label;
  final String value;
  final String hint;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.35),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: enabled
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      labelText: label,
                      hintText: hint,
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value.isEmpty ? hint : value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: value.isEmpty
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 12),
          _BotonAccionDatos(
            icon: enabled ? Icons.edit_rounded : Icons.content_copy_rounded,
            onTap: enabled
                ? null
                : () {
                    final text = value.isEmpty ? hint : value;
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$label copiado.')),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _BotonAccionDatos extends StatelessWidget {
  const _BotonAccionDatos({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
}

class _DropdownEnteroEstudiante extends StatelessWidget {
  const _DropdownEnteroEstudiante({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.valueLabel,
    required this.onChanged,
  });

  final String label;
  final List<int> values;
  final int? selectedValue;
  final String Function(int) valueLabel;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: values
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(valueLabel(e)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _DropdownCarreraEstudiante extends StatelessWidget {
  const _DropdownCarreraEstudiante({
    required this.value,
    required this.careers,
    required this.onChanged,
  });

  final String value;
  final List<CareerInfo> careers;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: 'Carrera',
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: careers
            .map((e) => DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(e.nombre),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
