/// A kind of resource, which a hive makes from a bee and the orders ask for
/// (see `docs/DESIGN.md`, "Éléments du plateau"). Provisional, until the
/// resources of each species are designed (see "Chantiers à part").
enum ResourceType {
  comb(maxTier: 5),
  pollen(maxTier: 5);

  const ResourceType({required this.maxTier});

  /// The tier of the type's last resource: two resources of that tier no
  /// longer merge.
  final int maxTier;
}
