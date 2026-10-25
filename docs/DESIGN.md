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
- L'incubation dure quelques secondes, plus longtemps pour des parents de haut niveau. Elle peut être terminée immédiatement en gemmes (voir [Gemmes](#gemmes)).
- L'incubateur ne consomme pas d'énergie.

## Espèces et mutations

Les espèces mutées ne sortent d'aucun générateur au départ : pour en produire, le joueur refait la mutation, ce qui donne un sens répété à l'incubateur.

- Chaque famille a son générateur, qui ne crée que l'espèce de base.
- Une espèce mutée s'obtient uniquement par l'incubateur, sous forme d'abeille.
- Une mutation = deux espèces parentes, sans autre condition. Deux parents donnés donnent toujours la même espèce.
- Une fois découverte, la recette est connue. La refaire ne coûte que de l'énergie, de la place, deux abeilles et le temps d'incubation.

**Apidex et indices** : l'incubateur n'accepte que les paires valides (savoir qu'une paire fonctionne est un indice) ; les clients évoquent l'espèce recherchée (« un miel qui brille comme la roche ») ; l'Apidex montre silhouette et famille des espèces non découvertes ; un indice plus précis s'achète en pièces (voir [Pièces](#pièces)), la recette complète en gemmes (voir [Gemmes](#gemmes)).

Exemple : Commune + Rocheuse = abeille Cristal, qui produit du miel de cristal.

## Journées et commandes

Le jeu avance par journées : on en termine une en remplissant toutes ses commandes. Une journée ne peut pas échouer, seulement prendre plus de temps.

| Type       | Ce qu'elle demande                                             | Rôle                                 |
| ---------- | -------------------------------------------------------------- | ------------------------------------ |
| Disponible | Ressources déjà sur le plateau ou à 1 ou 2 fusions de distance | Nettoie le plateau persistant        |
| Objectif   | Ressources à atteindre, par exemple d'une espèce à découvrir   | Tire la progression et les mutations |

Chaque commande remplie rapporte des **pièces** (voir [Pièces](#pièces)).

**Fin de journée** : récompense (nouveaux générateurs, nouvelles ruches…) et jauge d'énergie remplie entièrement.

**Risque connu** : une commande objectif ne doit jamais bloquer la journée. Pistes : indice clair livré avec la commande, commande bonus facultative, indice plus précis après plusieurs essais, indice de mutation acheté en pièces (voir [Pièces](#pièces)).

## Énergie

1 énergie par minute (app ouverte ou fermée), 100 au maximum, recharge complète à chaque journée terminée. Jauge vide : 1 h 40. De l'énergie supplémentaire s'achète en gemmes (voir [Gemmes](#gemmes)).

Consomment de l'énergie : taper un générateur de famille (une larve) ; taper une ruche (une ressource, plus une unité de durée de vie).

Ordres de grandeur (hypothèse : 1 énergie par larve et par ressource, durée de vie de 5) : 1 abeille = 2 larves = 2 énergie ; 1 ressource de palier 4 ≈ 12 énergie ; une jauge pleine couvre environ 8 commandes de palier 4. Point de départ pour calibrer la taille des journées (ex. 1,5 jauge au début, 2 plus tard).

## Plateau persistant et encombrement

Le plateau (grille 7×9, 63 cases) est conservé d'une journée à l'autre : on peut anticiper. Il reste jouable grâce aux commandes disponibles, à la place limitée et à un bouton de suppression d'une abeille ou d'une ressource. Un stockage hors plateau, acheté en pièces, donne un peu de marge (voir [Pièces](#pièces)).

## Pièces

Monnaie courante du jeu, gagnée en remplissant les commandes. Les pièces servent à **mieux produire**, à **comprendre** et à **s'organiser**, jamais à produire ou à découvrir à la place du joueur.

**Usages**

1. **Améliorer les générateurs et les ruches (dépense principale)** : chaque générateur de famille et chaque ruche a des niveaux, achetés en pièces à prix croissant. Un niveau améliore le rendement, pas le coût : le double coût énergie + durée de vie de la ruche reste intact. Pistes d'effets : un générateur amélioré peut produire deux larves pour le prix d'une, ou plus tard une abeille de l'espèce de base ; une ruche améliorée peut produire une ressource de palier 2. C'est la dépense qui ne s'épuise pas : chaque générateur ou ruche reçu en fin de journée ouvre une nouvelle série d'améliorations, et les autres usages ci-dessous finissent par être tous achetés.
2. **Indices de mutation** : dans l'Apidex ou l'incubateur, le joueur achète un indice sur une espèce non découverte, par paliers (par exemple une espèce parente, puis la seconde). L'indice est déterministe et donne de l'information, jamais l'abeille : le joueur doit toujours faire la mutation lui-même (pilier « Découvrir »). C'est aussi la parade de dernier recours au risque de blocage par une commande objectif.
3. **Stockage hors plateau** : des emplacements de réserve, hors de la grille, achetés un par un, à prix croissant. Un objet stocké n'occupe plus de case mais ne peut ni fusionner ni produire tant qu'il n'est pas reposé sur le plateau. Le plateau de 63 cases reste la contrainte principale (pilier « Arbitrer ») ; le stockage n'en desserre qu'une partie, de plus en plus chère.

**Ce que les pièces n'achètent pas** : de l'énergie (elle rythme les journées ; elle s'achète en gemmes, voir [Gemmes](#gemmes)), des abeilles mutées (elles court-circuiteraient l'incubateur), de la durée de vie pour une abeille en ruche (le double coût énergie + durée de vie est voulu), des générateurs ou des ruches (ils restent des récompenses de fin de journée).

**À trancher**

- Gains : pièces rapportées par une commande, selon le palier des ressources demandées et le type de commande (disponible ou objectif).
- Améliorations : effets de chaque niveau, certains ou probables (le hasard n'est exclu que des mutations) ; nombre de niveaux et progression des prix ; niveau d'un générateur ou d'une ruche reçu en récompense (niveau 1, ou celui des existants) ; achat depuis l'encart d'informations de l'objet sélectionné ou ailleurs. L'effet sur l'énergie et la taille des journées est à simuler.
- Indices : découpage en paliers (ce que révèle chaque palier), prix de chaque palier, espèces concernées (toutes les non découvertes, ou seulement celles visées par une commande).
- Stockage : prix du premier emplacement et progression, nombre maximal d'emplacements, objets stockables (larves, abeilles, ressources ; générateurs et ruches ?), place à l'écran.
- Déblocage : dès le départ ou après quelques journées, pour ne pas surcharger le début (lien avec le tutoriel).

**Piste pour plus tard : la méta « Rucher »** : un lieu à restaurer ou décorer avec les pièces, qui fait avancer une petite histoire, à la manière de Gossip Harbor, Travel Town ou Love & Pies. Dépense sans fin et gratification à long terme, mais elle demande tout un contenu graphique et narratif : à envisager une fois le cœur du jeu en place, en complément des améliorations.

## Gemmes

Monnaie premium (nom provisoire), achetable avec de l'argent réel et parfois donnée en récompense. Là où les pièces aident à comprendre et à s'organiser, les gemmes font **gagner du temps** : elles raccourcissent une attente ou une recherche, sans jamais faire l'action à la place du joueur.

**Usages**

1. **Énergie** : acheter de l'énergie quand la jauge est vide, au lieu d'attendre la recharge.
2. **Finir une incubation** : terminer immédiatement une incubation en cours.
3. **Solution d'une mutation** : révéler la recette complète d'une espèce non découverte (ses deux parents), au lieu d'un indice partiel acheté en pièces. Le joueur doit encore réunir les deux abeilles et lancer l'incubation lui-même (pilier « Découvrir »).

**À trancher**

- Sources gratuites : quelles récompenses donnent des gemmes (fin de journée, première découverte d'une espèce, jalons…) et à quel rythme.
- Énergie : quantité par achat, prix, et si l'achat peut dépasser le plafond de 100.
- Prix d'une fin d'incubation (fixe ou selon le temps restant) et d'une solution de mutation.
- Autres usages éventuels (stockage, conversion en pièces…) et ce que les gemmes n'achètent jamais.
- Nom définitif de la monnaie.

## Progression

**Courbe des commandes** : espèces de base, puis espèces mutées (chaque mutation sert de tutoriel), puis ressources de deux espèces mutées ou mutations de mutations.

**Récompenses de fin de journée** : nouveaux générateurs de famille, nouvelles ruches, et plus tard des générateurs produisant directement une espèce mutée (raccourci mérité). À trancher : quelles mutations méritent un générateur, et à partir de quelle journée.

## Direction artistique

- **Pixel art**, confirmée (2026-10-24).
- **Largeur de jeu : 224 px** (7 cases de 32), hauteur variable (portrait), avec des assets fournis à ×2 pour l'affichage sur écrans à forte densité, sans interpolation floue (rendu « nearest »). Sur tous les iPhone, l'écran fait exactement 224 px de jeu de large, bord à bord, au prix d'une échelle fractionnaire (quelques pixels de jeu 1 pixel physique plus larges que les autres) ; la hauteur sûre varie de ~398 px (iPhone SE) à ~470 px. **Minimum garanti : 224×398 px de zone sûre** ; sur iPad et pliables, l'écran s'élargit (jusqu'à ~310 px) — voir `docs/STACK.md`.
- **Plateau : grille 7×9, cases de 32×32 px** (sprites 32×32, 64×64 en ×2), soit 224×288 px. Il **remplit toujours la largeur sur iPhone** (la taille des cases à l'écran s'adapte : ~172 pixels physiques sur un iPhone 18 Pro, ~107 sur un SE) ; sur iPad et pliables, il est aussi grand que la hauteur le permet, centré, décor sur les côtés.
- **Mise en page en bandes, à la Flambé** : HUD (16 px) et commandes (56 px) accrochés en haut de la zone sûre, barre du bas (32 px) en bas, plateau juste au-dessus, et un espace libre (≥ 6 px) qui absorbe la différence de hauteur entre appareils. Il reste ~110 px au minimum (iPhone SE) pour le HUD, les commandes et la barre du bas. Le décor couvre tout l'écran, y compris sous la Dynamic Island. Les hauteurs des bandes autres que le plateau sont provisoires, en attendant le design du HUD et des commandes.
- Cette DA réoriente le choix du moteur de rendu vers **Flame** plutôt que des widgets Flutter classiques — voir `CLAUDE.md` et `docs/STACK.md`. Le pixel art tire nativement parti d'un moteur à sprites/tilesets (scaling entier, tilesets pour la grille du plateau, gestion de caméra/viewport, animations frame par frame des abeilles et des ruches).
- Univers visuel précis, palette, ton, références : encore à définir.

## Chantiers à part

Tutoriel, équilibrage (tables d'espèces, recettes, durées de vie, paliers, gains et prix en pièces et en gemmes), univers visuel (palette, références, ton — la DA elle-même est fixée, voir [Direction artistique](#direction-artistique)).
