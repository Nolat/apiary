/// A family of bees, each with its own queen (see `docs/DESIGN.md`,
/// "Éléments du plateau", and `docs/CONTENT.md` for the species of each
/// family). Only the family every player starts with exists for now; the
/// others arrive with their end-of-day reward.
enum Family {
  /// "Mellifère": waxes and honeys, in four species.
  honeybee(maxLevel: 4);

  const Family({required this.maxLevel});

  /// The level of the family's last species: two bees of that level no longer
  /// merge.
  final int maxLevel;
}
