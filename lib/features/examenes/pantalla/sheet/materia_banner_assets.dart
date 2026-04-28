String _normalize(String s) {
  return s
      .toLowerCase()
      // Proper accents.
      .replaceAll('\u00e1', 'a')
      .replaceAll('\u00e9', 'e')
      .replaceAll('\u00ed', 'i')
      .replaceAll('\u00f3', 'o')
      .replaceAll('\u00fa', 'u')
      .replaceAll('\u00fc', 'u')
      // Mojibake fallbacks when source text is malformed.
      .replaceAll('\u00c3\u00a1', 'a')
      .replaceAll('\u00c3\u00a9', 'e')
      .replaceAll('\u00c3\u00ad', 'i')
      .replaceAll('\u00c3\u00b3', 'o')
      .replaceAll('\u00c3\u00ba', 'u')
      .replaceAll('\u00c3\u00bc', 'u')
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

enum MateriaBannerVariant { list, detail }

class MateriaBannerAssets {
  static const _historiaAntiguedad = 'assets/banners/historia/1/antiguedad.webp';
  static const _historiaAntiguedadDetail =
      'assets/banners/historia/1/antiguedad_ancho.webp';
  static const _historiaDidacticaGeneral =
      'assets/banners/historia/1/didactica_general.webp';
  static const _historiaDidacticaGeneralDetail =
      'assets/banners/historia/1/didactica_general_ancho.webp';
  static const _historiaCorporeidadJuego =
      'assets/banners/historia/1/corporeidad_juego.webp';
  static const _historiaCorporeidadJuegoDetail =
      'assets/banners/historia/1/corporeidad_juego_ancho.webp';
  static const _historiaHistoriaIdeas1 =
      'assets/banners/historia/1/historia_ideas_1.webp';
  static const _historiaHistoriaIdeas1Detail =
      'assets/banners/historia/1/historia_ideas_1_ancho.webp';
  static const _historiaOralidadLecturaTic =
      'assets/banners/historia/1/oralidad_lectura_tic.webp';
  static const _historiaOralidadLecturaTicDetail =
      'assets/banners/historia/1/oralidad_lectura_tic_ancho.webp';
  static const _historiaProblematicaConocimiento =
      'assets/banners/historia/1/problematica_conocimiento.webp';
  static const _historiaProblematicaConocimientoDetail =
      'assets/banners/historia/1/problematica_conocimiento_ancho.webp';
  static const _historiaPueblosOriginarios =
      'assets/banners/historia/1/pueblos_originarios.webp';
  static const _historiaPueblosOriginariosDetail =
      'assets/banners/historia/1/pueblos_originarios_ancho.webp';
  static const _historiaPedagogia = 'assets/banners/historia/1/pedagogia.webp';
  static const _historiaPedagogiaDetail =
      'assets/banners/historia/1/pedagogia_ancho.webp';
  static const _historiaPracticaDocente1 =
      'assets/banners/historia/1/practica_docente_1.webp';
  static const _historiaPracticaDocente1Detail =
      'assets/banners/historia/1/practica_docente_1_ancho.webp';
  static const _historiaFilosofia = 'assets/banners/historia/2/filosofia.webp';
  static const _historiaFilosofiaDetail =
      'assets/banners/historia/2/filosofia_ancho.webp';
  static const _historiaDidacticaCienciasSociales =
      'assets/banners/historia/2/didactica_ciencias_sociales.webp';
  static const _historiaDidacticaCienciasSocialesDetail =
      'assets/banners/historia/2/didactica_ciencias_sociales_ancho.webp';
  static const _historiaEconomiaPolitica =
      'assets/banners/historia/2/economia_politica.webp';
  static const _historiaEconomiaPoliticaDetail =
      'assets/banners/historia/2/economia_politica_ancho.webp';
  static const _historiaEducacionSexualIntegral =
      'assets/banners/historia/2/educacion_sexual_integral.webp';
  static const _historiaEducacionSexualIntegralDetail =
      'assets/banners/historia/2/educacion_sexual_integral_ancho.webp';
  static const _historiaMundoTerritorialidades =
      'assets/banners/historia/2/mundo_territorialidades.webp';
  static const _historiaMundoTerritorialidadesDetail =
      'assets/banners/historia/2/mundo_territorialidades_ancho.webp';
  static const _historiaPsicologiaEducacional =
      'assets/banners/historia/2/psicologia_educacional.webp';
  static const _historiaPsicologiaEducacionalDetail =
      'assets/banners/historia/2/psicologia_educacional_ancho.webp';
  static const _historiaSujetosEducacionSecundaria =
      'assets/banners/historia/2/sujetos_educacion_secundaria.webp';
  static const _historiaSujetosEducacionSecundariaDetail =
      'assets/banners/historia/2/sujetos_educacion_secundaria_ancho.webp';
  static const _historiaInstitucionesEducativas =
      'assets/banners/historia/3/instituciones_educativas.webp';
  static const _historiaInstitucionesEducativasDetail =
      'assets/banners/historia/3/instituciones_educativas_ancho.webp';
  static const _historiaEpistemologiaHistoria =
      'assets/banners/historia/3/epistemologia_historia.webp';
  static const _historiaEpistemologiaHistoriaDetail =
      'assets/banners/historia/3/epistemologia_historia_ancho.webp';
  static const _historiaHistoriaPoliticaEducacionArgentina =
      'assets/banners/historia/3/historia_politica_educacion_argentina.webp';
  static const _historiaHistoriaPoliticaEducacionArgentinaDetail =
      'assets/banners/historia/3/historia_politica_educacion_argentina_ancho.webp';
  static const _historiaProcesosAmericanos2 =
      'assets/banners/historia/3/procesos_americanos_ii.webp';
  static const _historiaProcesosAmericanos2Detail =
      'assets/banners/historia/3/procesos_americanos_ii_ancho.webp';
  static const _historiaProcesosContemporaneos1 =
      'assets/banners/historia/3/procesos_contemporaneos_i.webp';
  static const _historiaProcesosContemporaneos1Detail =
      'assets/banners/historia/3/procesos_contemporaneos_i_ancho.webp';
  static const _historiaProcesosArgentina1 =
      'assets/banners/historia/3/procesos_argentina_i.webp';
  static const _historiaProcesosArgentina1Detail =
      'assets/banners/historia/3/procesos_argentina_i_ancho.webp';
  static const _historiaSociologiaEducacion =
      'assets/banners/historia/3/sociologia_educacion.webp';
  static const _historiaSociologiaEducacionDetail =
      'assets/banners/historia/3/sociologia_educacion_ancho.webp';

  static String _forVariant(
    MateriaBannerVariant variant, {
    required String list,
    String? detail,
  }) {
    if (variant == MateriaBannerVariant.detail) {
      return detail ?? list;
    }
    return list;
  }

  static String? resolve({
    required String careerId,
    required String materia,
    required int? anio,
    MateriaBannerVariant variant = MateriaBannerVariant.list,
  }) {
    final m = _normalize(materia);
    final normalizedCareerId = careerId.trim().toLowerCase();
    final isHistoria = normalizedCareerId == 'historia';

    final isAntiguedad = m.contains('antiguedad');
    final isDidacticaGeneral = m.contains('didactica') && m.contains('general');
    final isCorporeidadJuego = m.contains('corporeidad') &&
        (m.contains('juego') || m.contains('juegos')) &&
        m.contains('lenguajes');
    final isHistoriaIdeas1 = m.contains('historia') &&
        m.contains('ideas') &&
        RegExp(r'\b(1|i)\b').hasMatch(m);
    final isOralidadLecturaTic =
        (m.contains('oralidad') && m.contains('lectura')) ||
            (m.contains('ole') && m.contains('tic'));
    final isProblematicaConocimiento =
        m.contains('problematica') && m.contains('conocimiento');
    final isPueblosOriginarios =
        m.contains('pueblos') && m.contains('originarios');
    final isPedagogia = m.contains('pedagogia');
    final isPracticaDocente1 = m.contains('practica') &&
        (m.contains('docente') ||
            RegExp(r'\bcomision\b').hasMatch(m) ||
            m == 'practica i') &&
        RegExp(r'\b(1|i)\b').hasMatch(m);
    final isFilosofia = m.contains('filosofia');
    final isDidacticaCienciasSociales = m.contains('didactica') &&
        m.contains('ciencias') &&
        (m.contains('sociales') || m.contains('sociale'));
    final isEconomiaPolitica = m.contains('economia') && m.contains('politica');
    final isEducacionSexualIntegral = m.contains('educacion') &&
        m.contains('sexual') &&
        m.contains('integral');
    final isMundoTerritorialidades =
        m.contains('mundo') && m.contains('territorialidades');
    final isPsicologiaEducacional =
        m.contains('psicologia') && m.contains('educacional');
    final isSujetosEducacionSecundaria = m.contains('sujetos') &&
        m.contains('educacion') &&
        m.contains('secundaria');
    final isInstitucionesEducativas =
        (m.contains('instituciones') || m.contains('institucion')) &&
            m.contains('educativas');
    final isEpistemologiaHistoria =
        m.contains('epistemologia') && m.contains('historia');
    final isHistoriaPoliticaEducacionArgentina = m.contains('historia') &&
        m.contains('politica') &&
        m.contains('educacion') &&
        m.contains('argentina');
    final isProcesosAmericanos2 =
        m.contains('americanos') && RegExp(r'\b(2|ii)\b').hasMatch(m);
    final isProcesosContemporaneos1 =
        m.contains('contemporaneos') && RegExp(r'\b(1|i)\b').hasMatch(m);
    final isProcesosArgentina1 = RegExp(r'\b(arg|argentina)\b').hasMatch(m) &&
        RegExp(r'\b(1|i)\b').hasMatch(m);
    final isSociologiaEducacion =
        m.contains('sociologia') && m.contains('educacion');

    if ((anio == 1 || anio == null) && isAntiguedad && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaAntiguedad,
        detail: _historiaAntiguedadDetail,
      );
    }
    if ((anio == 1 || anio == null) && isDidacticaGeneral) {
      return _forVariant(
        variant,
        list: _historiaDidacticaGeneral,
        detail: _historiaDidacticaGeneralDetail,
      );
    }
    if ((anio == 1 || anio == null) && isCorporeidadJuego) {
      return _forVariant(
        variant,
        list: _historiaCorporeidadJuego,
        detail: _historiaCorporeidadJuegoDetail,
      );
    }
    if ((anio == 1 || anio == null) && isHistoriaIdeas1 && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaHistoriaIdeas1,
        detail: _historiaHistoriaIdeas1Detail,
      );
    }
    if ((anio == 1 || anio == null) && isOralidadLecturaTic) {
      return _forVariant(
        variant,
        list: _historiaOralidadLecturaTic,
        detail: _historiaOralidadLecturaTicDetail,
      );
    }
    if ((anio == 1 || anio == null) &&
        isProblematicaConocimiento &&
        isHistoria) {
      return _forVariant(
        variant,
        list: _historiaProblematicaConocimiento,
        detail: _historiaProblematicaConocimientoDetail,
      );
    }
    if ((anio == 1 || anio == null) && isPueblosOriginarios && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaPueblosOriginarios,
        detail: _historiaPueblosOriginariosDetail,
      );
    }
    if ((anio == 1 || anio == null) && isPedagogia) {
      return _forVariant(
        variant,
        list: _historiaPedagogia,
        detail: _historiaPedagogiaDetail,
      );
    }
    if ((anio == 1 || anio == null) && isPracticaDocente1) {
      return _forVariant(
        variant,
        list: _historiaPracticaDocente1,
        detail: _historiaPracticaDocente1Detail,
      );
    }
    if ((anio == 2 || anio == null) && isFilosofia && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaFilosofia,
        detail: _historiaFilosofiaDetail,
      );
    }
    if ((anio == 2 || anio == null) &&
        isDidacticaCienciasSociales &&
        isHistoria) {
      return _forVariant(
        variant,
        list: _historiaDidacticaCienciasSociales,
        detail: _historiaDidacticaCienciasSocialesDetail,
      );
    }
    if ((anio == 2 || anio == null) && isEconomiaPolitica && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaEconomiaPolitica,
        detail: _historiaEconomiaPoliticaDetail,
      );
    }
    if ((anio == 2 || anio == null) &&
        isEducacionSexualIntegral &&
        isHistoria) {
      return _forVariant(
        variant,
        list: _historiaEducacionSexualIntegral,
        detail: _historiaEducacionSexualIntegralDetail,
      );
    }
    if ((anio == 2 || anio == null) && isMundoTerritorialidades && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaMundoTerritorialidades,
        detail: _historiaMundoTerritorialidadesDetail,
      );
    }
    if ((anio == 2 || anio == null) && isPsicologiaEducacional && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaPsicologiaEducacional,
        detail: _historiaPsicologiaEducacionalDetail,
      );
    }
    if ((anio == 2 || anio == null) &&
        isSujetosEducacionSecundaria &&
        isHistoria) {
      return _forVariant(
        variant,
        list: _historiaSujetosEducacionSecundaria,
        detail: _historiaSujetosEducacionSecundariaDetail,
      );
    }
    if ((anio == 3 || anio == null) &&
        isInstitucionesEducativas &&
        isHistoria) {
      return _forVariant(
        variant,
        list: _historiaInstitucionesEducativas,
        detail: _historiaInstitucionesEducativasDetail,
      );
    }
    if ((anio == 3 || anio == null) && isEpistemologiaHistoria && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaEpistemologiaHistoria,
        detail: _historiaEpistemologiaHistoriaDetail,
      );
    }
    if ((anio == 3 || anio == null) &&
        isHistoriaPoliticaEducacionArgentina &&
        isHistoria) {
      return _forVariant(
        variant,
        list: _historiaHistoriaPoliticaEducacionArgentina,
        detail: _historiaHistoriaPoliticaEducacionArgentinaDetail,
      );
    }
    if ((anio == 3 || anio == null) && isProcesosAmericanos2 && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaProcesosAmericanos2,
        detail: _historiaProcesosAmericanos2Detail,
      );
    }
    if ((anio == 3 || anio == null) &&
        isProcesosContemporaneos1 &&
        isHistoria) {
      return _forVariant(
        variant,
        list: _historiaProcesosContemporaneos1,
        detail: _historiaProcesosContemporaneos1Detail,
      );
    }
    if ((anio == 3 || anio == null) && isProcesosArgentina1 && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaProcesosArgentina1,
        detail: _historiaProcesosArgentina1Detail,
      );
    }
    if ((anio == 3 || anio == null) && isSociologiaEducacion && isHistoria) {
      return _forVariant(
        variant,
        list: _historiaSociologiaEducacion,
        detail: _historiaSociologiaEducacionDetail,
      );
    }

    return null;
  }
}
