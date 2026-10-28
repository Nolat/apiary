/// A branch of resources, which a hive makes from a bee and the orders ask for
/// (see `docs/CONTENT.md`, "Branches de ressources"): two identical resources
/// merge into the next tier of their branch, and each tier has its own name
/// (wax: wax drop, raw wax, refined wax, candle). Only the branches of the
/// families that exist are listed.
enum ResourceBranch {
  /// "Cire".
  wax(maxTier: 4),

  /// "Miel".
  honey(maxTier: 4);

  const ResourceBranch({required this.maxTier});

  /// The tier of the branch's last resource: two resources of that tier no
  /// longer merge.
  final int maxTier;
}
