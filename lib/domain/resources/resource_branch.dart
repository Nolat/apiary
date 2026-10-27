/// A branch of resources, which a hive makes from a bee and the orders ask for
/// (see `docs/DESIGN.md`, "Éléments du plateau"): tier 1 is what a hive makes,
/// and two identical resources merge into the next tier of their branch. Each
/// tier has its own name: the comb branch is the comb (tier 1) then honey
/// (tier 2, its last), the pollen branch is pollen alone. Provisional, until
/// the resources of each species are designed (see "Chantiers à part").
enum ResourceBranch {
  comb(maxTier: 2),
  pollen(maxTier: 1);

  const ResourceBranch({required this.maxTier});

  /// The tier of the branch's last resource: two resources of that tier no
  /// longer merge.
  final int maxTier;
}
