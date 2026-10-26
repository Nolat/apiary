/// A family of bees, each with its own queen (see `docs/DESIGN.md`,
/// "Éléments du plateau"). Only the family every player starts with exists
/// for now; the others (Rocheuse…) arrive with their end-of-day reward.
enum Family {
  /// Provisional number of levels, until the species of each family are
  /// designed (see `docs/DESIGN.md`, "Chantiers à part").
  common(maxLevel: 5);

  const Family({required this.maxLevel});

  /// The level of the family's last species: two bees of that level no longer
  /// merge.
  final int maxLevel;
}
