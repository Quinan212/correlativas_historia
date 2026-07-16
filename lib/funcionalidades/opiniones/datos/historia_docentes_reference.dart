class HistoriaDocenteCanon {
  const HistoriaDocenteCanon({
    required this.displayName,
    required this.sortName,
    this.aliases = const <String>[],
  });

  final String displayName;
  final String sortName;
  final List<String> aliases;
}

const kHistoriaDocentesCanon = <HistoriaDocenteCanon>[
  HistoriaDocenteCanon(
    displayName: 'Diego Almiron',
    sortName: 'Almiron, Diego',
  ),
  HistoriaDocenteCanon(
    displayName: 'Fernando Belottini',
    sortName: 'Belottini, Fernando',
    aliases: <String>['belotini fernando', 'belotini'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Javier Borche',
    sortName: 'Borche, Javier',
  ),
  HistoriaDocenteCanon(
    displayName: 'Rosana Carmaran',
    sortName: 'Carmaran, Rosana',
    aliases: <String>['carmaran', 'rosana carmaran'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Emilia Coduri',
    sortName: 'Coduri, Emilia',
  ),
  HistoriaDocenteCanon(
    displayName: 'Romina Diaz',
    sortName: 'Diaz, Romina',
  ),
  HistoriaDocenteCanon(
    displayName: 'Gabriela Dri',
    sortName: 'Dri, Gabriela',
  ),
  HistoriaDocenteCanon(
    displayName: 'Maria del Carmen Fernandez',
    sortName: 'Fernandez, Maria del Carmen',
    aliases: <String>['fernandez maria c', 'maria c fernandez'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Flavia Frigo',
    sortName: 'Frigo, Flavia',
  ),
  HistoriaDocenteCanon(
    displayName: 'Guillermo Galarza',
    sortName: 'Galarza, Guillermo',
  ),
  HistoriaDocenteCanon(
    displayName: 'Diego Garcia',
    sortName: 'Garcia, Diego',
  ),
  HistoriaDocenteCanon(
    displayName: 'Giuliana Gay',
    sortName: 'Gay, Giuliana',
  ),
  HistoriaDocenteCanon(
    displayName: 'Lujan Gonzalez',
    sortName: 'Gonzalez, Lujan',
  ),
  HistoriaDocenteCanon(
    displayName: 'Ines Igual',
    sortName: 'Igual, Ines',
  ),
  HistoriaDocenteCanon(
    displayName: 'Carina Leiva',
    sortName: 'Leiva, Carina',
  ),
  HistoriaDocenteCanon(
    displayName: 'Elizabeth Lindt',
    sortName: 'Lindt, Elizabeth',
  ),
  HistoriaDocenteCanon(
    displayName: 'Evelyn Lopez',
    sortName: 'Lopez, Evelyn',
  ),
  HistoriaDocenteCanon(
    displayName: 'Gustavo Martinez',
    sortName: 'Martinez, Gustavo',
    aliases: <String>['martinez gustavo'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Yanina Martinez',
    sortName: 'Martinez, Yanina',
    aliases: <String>['martinez yanina'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Jorge Medina',
    sortName: 'Medina, Jorge',
  ),
  HistoriaDocenteCanon(
    displayName: 'Natalia Ochoa',
    sortName: 'Ochoa, Natalia',
  ),
  HistoriaDocenteCanon(
    displayName: 'Patricia Palavicini',
    sortName: 'Palavicini, Patricia',
  ),
  HistoriaDocenteCanon(
    displayName: 'Marcos Pizzio',
    sortName: 'Pizzio, Marcos',
  ),
  HistoriaDocenteCanon(
    displayName: 'Gerardo Pozzi',
    sortName: 'Pozzi, Gerardo',
  ),
  HistoriaDocenteCanon(
    displayName: 'Soledad Robinson',
    sortName: 'Robinson, Soledad',
  ),
  HistoriaDocenteCanon(
    displayName: 'Carlos Ruiz Diaz',
    sortName: 'Ruiz Diaz, Carlos',
    aliases: <String>['ruizdiaz carlos', 'carlos ruiz diaz'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Diana Salud',
    sortName: 'Salud, Diana',
  ),
  HistoriaDocenteCanon(
    displayName: 'Paola Segovia',
    sortName: 'Segovia, Paola',
  ),
  HistoriaDocenteCanon(
    displayName: 'Patricia Stadelman',
    sortName: 'Stadelman, Patricia',
  ),
  HistoriaDocenteCanon(
    displayName: 'Mc Laughlin',
    sortName: 'Mc Laughlin',
    aliases: <String>['mclaughlin', 'mc laughlin'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Horacio Velazque Pens',
    sortName: 'Velazque Pens, Horacio',
    aliases: <String>['velazque pens', 'velazque pens horacio'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Vilche C.',
    sortName: 'Vilche C.',
    aliases: <String>['vilche c', 'vilche c.'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Moran',
    sortName: 'Moran',
    aliases: <String>['moran'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Canete',
    sortName: 'Canete',
    aliases: <String>['canete', 'cañete'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Jeremias Gomez',
    sortName: 'Gomez, Jeremias',
    aliases: <String>['jeremias gomez'],
  ),
  HistoriaDocenteCanon(
    displayName: 'Carolina Maidana',
    sortName: 'Maidana, Carolina',
    aliases: <String>['maidana carolina'],
  ),
];
