// lib/compartido/proveedores/datos_catalogo.dart
class CareerInfo {
  final String id;
  final String nombre;
  final String assetHtml;
  final String downloadUrl;
  final String categoria;
  final String? iconAsset;
  final bool hidden;

  const CareerInfo({
    required this.id,
    required this.nombre,
    required this.assetHtml,
    required this.downloadUrl,
    required this.categoria,
    this.iconAsset,
    this.hidden = false,
  });
}

class MateriaOverride {
  final String materiaId;
  final String? codigo;
  final String? nombre;
  final int? anio;
  final int? cuatri;
  final String? tipo;
  final String? formato;
  final String? horas;

  const MateriaOverride({
    required this.materiaId,
    this.codigo,
    this.nombre,
    this.anio,
    this.cuatri,
    this.tipo,
    this.formato,
    this.horas,
  });
}

class InstitutionInfo {
  final String id;
  final String careerId;
  final String nombre;
  final String? iconAsset;
  final String? downloadUrl;
  final List<MateriaOverride> overrides;
  final bool hidden;

  const InstitutionInfo({
    required this.id,
    required this.careerId,
    required this.nombre,
    this.iconAsset,
    this.downloadUrl,
    this.overrides = const [],
    this.hidden = false,
  });
}

String? institutionIconForCareer(String careerId) {
  for (final institution in kInstitutions) {
    if (institution.careerId == careerId && institution.iconAsset != null) {
      return institution.iconAsset;
    }
  }
  return null;
}

const List<CareerInfo> kCareers = [
  CareerInfo(
    id: 'historia',
    nombre: 'Profesorado de Historia',
    assetHtml: 'assets/data/historia.json',
    downloadUrl:
        'https://drive.google.com/file/d/13znCaPZBl00OHVRLZhJ6Fh8CQaGIKi63/view?usp=sharing',
    categoria: 'profesorado',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  CareerInfo(
    id: 'geografia',
    nombre: 'Profesorado en Geografía',
    assetHtml: 'assets/data/geografia.json',
    downloadUrl:
        'https://drive.google.com/file/d/1Sj91vNoBMlo_0ZPOAvLEJciPsjaWH4S9/view',
    categoria: 'profesorado',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  CareerInfo(
    id: 'politica',
    nombre: 'Profesorado en Ciencia Política',
    assetHtml: 'assets/data/politica.json',
    downloadUrl:
        'https://drive.google.com/file/d/1UjXaF41TL5AKRpOaE9YJOIdtAguPUJ83/view?usp=sharing',
    categoria: 'profesorado',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  CareerInfo(
    id: 'artes_visuales',
    nombre: 'Profesorado en Artes Visuales',
    assetHtml: 'assets/data/artes_visuales.json',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_artes_visuales',
    categoria: 'profesorado',
    iconAsset: 'assets/career_icons/logo_artes.png',
  ),
  CareerInfo(
    id: 'fisica',
    nombre: 'Profesorado en Física',
    assetHtml: 'assets/Fisica.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_fisica',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'musica',
    nombre: 'Profesorado en Música',
    assetHtml: 'assets/Musica.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_musica',
    categoria: 'profesorado',
    iconAsset: 'assets/career_icons/logo_artes.png',
  ),
  CareerInfo(
    id: 'lengua_literatura',
    nombre: 'Profesorado en Lengua y Literatura',
    assetHtml: 'assets/Lengua_Literatura.html',
    downloadUrl:
        'https://drive.google.com/tu_link_oficial_de_lengua_literatura',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'biologia',
    nombre: 'Profesorado en Biología',
    assetHtml: 'assets/Biologia.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_biologia',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'filosofia',
    nombre: 'Profesorado en Filosofía',
    assetHtml: 'assets/Filosofia.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_filosofia',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'psicologia',
    nombre: 'Profesorado en Psicología',
    assetHtml: 'assets/Psicologia.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_psicologia',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'contador',
    nombre: 'Contador Público',
    assetHtml: 'assets/contador_publico.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_contador',
    categoria: 'grado',
    hidden: true,
  ),
];

const List<InstitutionInfo> kInstitutions = [
  InstitutionInfo(
    id: 'historia_pscs',
    careerId: 'historia',
    nombre: 'Profesorado Superior de Ciencias Sociales',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  InstitutionInfo(
    id: 'geografia_pscs',
    careerId: 'geografia',
    nombre: 'Profesorado Superior de Ciencias Sociales',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  InstitutionInfo(
    id: 'politica_pscs',
    careerId: 'politica',
    nombre: 'Profesorado Superior de Ciencias Sociales',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  InstitutionInfo(
    id: 'artes_visuales_cesareo',
    careerId: 'artes_visuales',
    nombre:
        'Instituto Superior de Formación Docente N° 1 "Cesáreo Bernaldo de Quirós"',
    iconAsset: 'assets/career_icons/logo_artes.png',
  ),
  InstitutionInfo(
    id: 'musica_cesareo',
    careerId: 'musica',
    nombre:
        'Instituto Superior de Formación Docente N° 1 "Cesáreo Bernaldo de Quirós"',
    iconAsset: 'assets/career_icons/logo_artes.png',
  ),
];
