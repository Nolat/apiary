# Apiary · Game Design Document

Un jeu mobile de fusion relaxant où l'on élève des abeilles, croise les espèces pour en découvrir de nouvelles et récolte leurs ressources pour honorer les commandes du jour.

## Vision et piliers

Un merge-2 où le joueur élève des abeilles, découvre de nouvelles espèces par croisement et transforme leur production pour honorer les commandes de la journée.

**Inspirations** : APICO / Forestry Bees (croisement, mutations, collection), Flambé (journées à terminer via des commandes), Gossip Harbor (plateau de fusion, générateurs, énergie).

**Piliers**

1. **Découvrir** : chaque nouvelle espèce naît d'une paire de parents à trouver, jamais d'un tirage au sort.
2. **Produire** : les abeilles sont un carburant. Les placer en ruche les use, ce qui maintient une demande constante en larves.
3. **Arbitrer** : chaque abeille sert soit à produire, soit à découvrir. Chaque case du plateau compte.

**Ce que le jeu n'est pas**

- Pas d'incrémental ni de production hors ligne (seule l'énergie se recharge hors ligne).
- Pas d'échec : une journée se termine toujours, parfois avec plus de temps.
- Pas de hasard dans les mutations : deux parents donnés donnent toujours la même espèce.

## Boucle de gameplay

Une abeille part soit en ruche pour produire, soit en incubateur pour découvrir une espèce. Chaque journée terminée relance la boucle avec une jauge pleine et de nouveaux générateurs.

## Éléments du plateau

Deux gestes structurent tout : **fusionner** deux objets identiques pour monter d'un palier, **incuber** deux abeilles différentes pour découvrir une espèce.

| Élément               | Rôle                                                                                                      | Comment l'obtenir                               | Énergie                 |
| --------------------- | --------------------------------------------------------------------------------------------------------- | ----------------------------------------------- | ----------------------- |
| Générateur de famille | Crée des larves de l'espèce de base de sa famille (Commune, Rocheuse…)                                    | Départ, puis récompenses de fin de journée      | Oui, à chaque larve     |
| Larve                 | 2 larves identiques fusionnées = 1 abeille de l'espèce de base                                            | Générateur de famille                           | Non                     |
| Abeille               | 2 abeilles identiques fusionnées = espèce de niveau supérieur de sa famille. Va en ruche ou en incubateur | Fusion de larves ou d'abeilles, incubateur      | Non                     |
| Incubateur            | Reçoit 2 abeilles d'espèces différentes et produit une nouvelle espèce si la paire forme une mutation     | Donné dès le début                              | Non                     |
| Ruche                 | Reçoit une abeille et devient un générateur de ressources jusqu'à épuisement de l'abeille                 | Donnée dès le début, d'autres en fin de journée | Oui, à chaque ressource |
| Ressource             | 2 ressources identiques fusionnées = 1 ressource de palier supérieur. Sert aux commandes                  | Ruche                                           | Non                     |

**Règles de la ruche**

- Chaque espèce produit 1 ou 2 types de ressources.
- L'abeille a une durée de vie exprimée en nombre de ressources produites. À zéro, elle disparaît et la ruche attend une nouvelle abeille.
- Chaque utilisation coûte de l'énergie ET une unité de durée de vie. Ce double coût est voulu.

**Règles de l'incubateur**

- Lancement possible uniquement si les deux abeilles forment une mutation. Aucune tentative ratée.
- Le résultat reste caché tant que l'espèce n'a pas été découverte, puis s'affiche avant le lancement.
- L'incubation dure quelques secondes, plus longtemps pour des parents de haut niveau.
- L'incubateur ne consomme pas d'énergie.

## Espèces et mutations

Les espèces mutées ne sortent d'aucun générateur au départ : pour en produire, le joueur refait la mutation, ce qui donne un sens répété à l'incubateur.

- Chaque famille a son générateur, qui ne crée que l'espèce de base.
- Une espèce mutée s'obtient uniquement par l'incubateur, sous forme d'abeille.
- Une mutation = deux espèces parentes, sans autre condition. Deux parents donnés donnent toujours la même espèce.
- Une fois découverte, la recette est connue. La refaire ne coûte que de l'énergie, de la place, deux abeilles et le temps d'incubation.

**Apidex et indices** : l'incubateur n'accepte que les paires valides (savoir qu'une paire fonctionne est un indice) ; les clients évoquent l'espèce recherchée (« un miel qui brille comme la roche ») ; l'Apidex montre silhouette et famille des espèces non découvertes.

Exemple : Commune + Rocheuse = abeille Cristal, qui produit du miel de cristal.

## Journées et commandes

Le jeu avance par journées : on en termine une en remplissant toutes ses commandes. Une journée ne peut pas échouer, seulement prendre plus de temps.

| Type       | Ce qu'elle demande                                             | Rôle                                 |
| ---------- | -------------------------------------------------------------- | ------------------------------------ |
| Disponible | Ressources déjà sur le plateau ou à 1 ou 2 fusions de distance | Nettoie le plateau persistant        |
| Objectif   | Ressources à atteindre, par exemple d'une espèce à découvrir   | Tire la progression et les mutations |

**Fin de journée** : récompense (nouveaux générateurs, nouvelles ruches…) et jauge d'énergie remplie entièrement.

**Risque connu** : une commande objectif ne doit jamais bloquer la journée. Pistes : indice clair livré avec la commande, commande bonus facultative, indice plus précis après plusieurs essais.

## Énergie

1 énergie par minute (app ouverte ou fermée), 100 au maximum, recharge complète à chaque journée terminée. Jauge vide : 1 h 40.

Consomment de l'énergie : taper un générateur de famille (une larve) ; taper une ruche (une ressource, plus une unité de durée de vie).

Ordres de grandeur (hypothèse : 1 énergie par larve et par ressource, durée de vie de 5) : 1 abeille = 2 larves = 2 énergie ; 1 ressource de palier 4 ≈ 12 énergie ; une jauge pleine couvre environ 8 commandes de palier 4. Point de départ pour calibrer la taille des journées (ex. 1,5 jauge au début, 2 plus tard).

## Plateau persistant et encombrement

Le plateau (grille 8×9, 72 cases) est conservé d'une journée à l'autre : on peut anticiper. Il reste jouable grâce aux commandes disponibles, à la place limitée et à un bouton de suppression d'une abeille ou d'une ressource.

## Progression

**Courbe des commandes** : espèces de base, puis espèces mutées (chaque mutation sert de tutoriel), puis ressources de deux espèces mutées ou mutations de mutations.

**Récompenses de fin de journée** : nouveaux générateurs de famille, nouvelles ruches, et plus tard des générateurs produisant directement une espèce mutée (raccourci mérité). À trancher : quelles mutations méritent un générateur, et à partir de quelle journée.

## Direction artistique

- **Pixel art**, confirmée (2026-10-24).
- **Résolution de référence : 240×480** (portrait), avec des assets fournis à ×2 (**480×960**) pour l'affichage sur écrans à forte densité, en conservant un rendu pixel-perfect (scaling entier uniquement, pas d'interpolation floue).
- Conséquence directe sur le plateau : la grille 8×9 tient en largeur avec des cases de **30×30 px** en résolution de référence (8 × 30 = 240), soit 270 px de haut pour la grille et 210 px restants pour les commandes et le HUD (énergie, Apidex…).
- Cette DA réoriente le choix du moteur de rendu vers **Flame** plutôt que des widgets Flutter classiques — voir `CLAUDE.md` et `docs/STACK.md`. Le pixel art tire nativement parti d'un moteur à sprites/tilesets (scaling entier, tilesets pour la grille du plateau, gestion de caméra/viewport, animations frame par frame des abeilles et des ruches).
- Univers visuel précis, palette, ton, références : encore à définir.

## Chantiers à part

Tutoriel, équilibrage (tables d'espèces, recettes, durées de vie, paliers), univers visuel (palette, références, ton — la DA elle-même est fixée, voir [Direction artistique](#direction-artistique)).
