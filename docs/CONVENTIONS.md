# Conventions de code

> Règles et patterns à respecter dans le code d'Apiary, pour les humains comme pour Claude. Mis en place le 2026-10-24. Ce document dit **comment écrire le code** ; les choix techniques et leur justification sont dans `docs/STACK.md`, la stratégie de tests dans `docs/TESTING.md`, les commandes dans `CLAUDE.md`.
>
> Une règle qui ne convient plus se change **ici d'abord**, puis dans le code : pas d'exception silencieuse.

## Principes

1. **Les règles du jeu vivent dans `domain/`, en Dart pur.** Tout le reste (Flame, Riverpod, Drift, Firebase) est de la plomberie autour.
2. **Déterministe par construction.** Le temps passe par `clock`, le hasard par un `Random` injecté. Une même entrée donne toujours la même sortie (c'est aussi un pilier du design : pas de hasard dans les mutations).
3. **Immuable par défaut.** Les données du jeu sont des valeurs `freezed` ; on produit un nouvel état plutôt que de modifier l'ancien.
4. **Dépendances explicites.** Une classe reçoit ce dont elle a besoin par son constructeur. Les singletons globaux (`getIt`, `FirebaseX.instance`) ne s'appellent qu'aux points d'assemblage.
5. **Suivre l'existant.** Avant d'écrire un nouveau fichier, regarder son voisin le plus proche et en reprendre la forme.

## Langues

| Quoi | Langue |
| --- | --- |
| Code : identifiants, commentaires, messages de log, descriptions de tests | **anglais** |
| Documentation (`docs/`, `CLAUDE.md`) | **français** |
| Messages de commit | **anglais** |
| Textes affichés au joueur | **jamais en dur** : clé `easy_localization`, traduite dans `fr.json` **et** `en.json` |

## Architecture en couches

```
lib/
├── core/          # infra transverse : DI, logging, crash reporting, auth, thème
├── domain/        # règles du jeu : modèles, logique pure, interfaces de repositories
├── data/          # implémentations : Drift, Firestore, repositories
└── presentation/  # Flame : game, scènes, composants
```

### Qui peut importer qui

| Couche | Peut importer | Ne doit **jamais** importer |
| --- | --- | --- |
| `domain/` | Dart SDK, `freezed_annotation`, `clock`, `meta`, `collection` | Flutter, Flame, Riverpod, Drift, Firebase, `core/`, `data/`, `presentation/` |
| `data/` | `domain/`, `core/`, Drift, Firebase | `presentation/`, Flame |
| `presentation/` | `domain/`, `core/`, Flame, Riverpod | Drift, Firestore directement (passer par un repository) |
| `core/` | packages d'infra | `presentation/`, `data/` (sauf `core/di/` qui assemble tout) |

Repère rapide : un `import 'package:flutter/…'` ou `'package:flame/…'` dans `lib/domain/` est un bug d'architecture. Les tests de domaine le révèlent d'eux-mêmes : ils n'importent que `glados` (voir `docs/TESTING.md`).

### Organisation des fichiers

- Un fichier = **un concept public** (une classe et ses éventuels helpers privés). Nom de fichier en `snake_case` reprenant le nom de la classe : `BeeSpecies` → `bee_species.dart`.
- Sous-dossiers par **notion métier** à l'intérieur de chaque couche : `domain/board/`, `domain/orders/`, `data/board/`… Pas de dossiers fourre-tout `utils/` ou `helpers/` dans `lib/`.
- Pas de fichiers barils (`index.dart` qui réexporte) : on importe le fichier précis.

## Style Dart

Le lint (`very_good_analysis`) et `dart format` tranchent l'essentiel ; `fvm flutter analyze` doit rester **à zéro avertissement**. Au-delà :

- **Imports** : toujours en `package:apiary/…` dans `lib/`. Dans `test/`, seuls les helpers de test (`test/helpers/`) s'importent en relatif. L'ordre et les commentaires emoji sont gérés par `import_sorter` : ne pas les écrire à la main, lancer l'outil.
- **Nommage** : `UpperCamelCase` pour les types, `lowerCamelCase` pour le reste, y compris les constantes (`routeName`, `cellSize`), `_` pour tout ce qui n'est pas utilisé hors du fichier. Noms du **vocabulaire du design** (`Larva`, `Hive`, `Incubator`, `Order`, `Queen`, `Day`, `Energy`), pas de synonymes concurrents.
- **Immutabilité locale** : `final` par défaut, `const` dès que possible, `var` seulement quand la variable est réaffectée.
- **Constantes de classe** : regroupées dans une classe non instanciable, sur le modèle d'`AppColors` (`const AppColors._();` + `static const`).
- **Pas de nombres magiques** : une valeur de gameplay (énergie max, durée de vie) ou de mise en page (taille de case) a un nom. Les valeurs d'équilibrage sont centralisées pour pouvoir passer plus tard en remote config (voir `docs/STACK.md`).
- **Commentaires** : expliquer le **pourquoi** (contrainte, décision, piège), pas le quoi. Commentaire `///` sur une classe ou un membre public quand son rôle ou ses contraintes ne se lisent pas dans la signature (voir `AuthService`, `AppDatabase`). Renvoyer vers la doc (`see docs/STACK.md`) plutôt que dupliquer une justification.
- **Pas de code mort** ni de code commenté : git s'en souvient.
- **`TODO`** : uniquement avec un contexte, `// TODO(scope): what and why`. Ce qui dépasse quelques lignes va dans le backlog, pas dans le code.

## Domaine

### Modèles

- **`freezed`** pour toute donnée du jeu : espèces, objets du plateau, commandes, état d'une journée.
- **Unions scellées** (`sealed class` freezed) pour les familles d'objets, puis `switch` exhaustif plutôt que des `is` en cascade ou des booléens `isHive`/`isBee` :

  ```dart
  @freezed
  sealed class BoardItem with _$BoardItem {
    const factory BoardItem.larva({required Species species}) = Larva;
    const factory BoardItem.bee({required Species species}) = Bee;
    const factory BoardItem.resource({required ResourceType type, required int tier}) = Resource;
  }

  final label = switch (item) {
    Larva(:final species) => …,
    Bee(:final species) => …,
    Resource(:final type, :final tier) => …,
  };
  ```

- Les catalogues fixes (espèces, familles, recettes de mutation) sont des **données**, pas des `if` dispersés : une table unique fait foi.
- Les invariants (niveau ≥ 1, durée de vie ≥ 0) sont vérifiés à la construction (`assert` dans un constructeur privé, ou fabrique qui refuse les valeurs invalides).

### Logique

- Fonctions et classes **pures** : elles prennent un état et renvoient un nouvel état ou un résultat, sans effet de bord ni I/O.
- `clock.now()`, **jamais** `DateTime.now()`. Un `Random` passé en paramètre, **jamais** `Random()` en dur.
- **Une issue attendue du jeu n'est pas une exception.** « Ces deux objets ne fusionnent pas », « cette paire n'est pas une mutation », « pas assez d'énergie » sont des résultats normaux : les modéliser par un type de retour (`null` quand l'absence suffit, sinon une union scellée de résultats). Les exceptions sont réservées aux bugs et aux pannes d'infrastructure.
- Le domaine définit les **interfaces** des repositories dont il a besoin (`abstract interface class BoardRepository`) ; `data/` les implémente.

## Données

- **Injection par constructeur** de la source (`AppDatabase`, `FirebaseFirestore`, `FirebaseAuth`), comme `AuthService(this._auth)` : c'est ce qui permet de tester avec Drift en mémoire ou un faux Firebase.
- Les repositories **convertissent** entre les types de stockage (lignes Drift, documents Firestore) et les modèles du domaine. Aucun type Drift ou Firestore ne sort de `data/`.
- **Drift** : tout changement de schéma incrémente `schemaVersion` et s'accompagne d'une migration **et** de son test. Une migration ratée efface la progression d'un joueur.
- **Firestore** : documents par utilisateur, clés par UID Firebase. Le client **n'écrit jamais** de valeur économique (monnaie, déblocages payants) : ça passe par une Cloud Function. Toute nouvelle collection arrive avec ses règles dans `firestore.rules` dans le même changement.

## État et injection

Deux outils, deux rôles, sans recouvrement :

| | `get_it` | Riverpod |
| --- | --- | --- |
| Pour | services et singletons d'infra (logging, base, repositories, SDK) | état consommé par le jeu (partie en cours, progression) |
| Déclaré dans | `configureDependencies()` (`lib/core/di/injection.dart`) | à côté de son usage, via `@riverpod` |
| Durée de vie | celle de l'app | gérée par Riverpod |

- `getIt<T>()` ne s'appelle que dans `configureDependencies()`, `bootstrap()` et les providers qui exposent un service à l'état. Jamais au fond d'une classe métier.
- Enregistrement en `registerLazySingleton`, typé explicitement (`registerLazySingleton<AuthService>(…)`).
- Providers **toujours générés** (`@riverpod`) : `Notifier`/`AsyncNotifier`, pas de `StateNotifier` ni de `Provider(…)` écrit à la main. Un notifier délègue les règles au domaine : il orchestre (lire l'état, appeler une fonction pure, persister), il ne décide pas.
- Séparer l'état de la **partie en cours** (plateau, local) de la **progression méta** (espèces découvertes, reines, synchronisée) : voir `docs/STACK.md`.
- Le pont Riverpod → composants Flame n'est pas encore tranché (`docs/STACK.md`). Le premier composant qui en a besoin fixe le pattern, et ce document est mis à jour avec.
  - En attendant, l'état purement visuel d'une scène (l'objet sélectionné du plateau, APY-9) est un `ValueNotifier` porté par le composant concerné (`BoardComponent.selection`) ; la scène l'écoute pour mettre à jour les autres composants (l'encart d'informations). La règle de sélection elle-même reste au domaine (`Board.selectionAfterTap`). À migrer vers Riverpod avec le premier état partagé avec le domaine ou persisté.

## Présentation Flame

- **Une scène par écran** : un `Component` dans `lib/presentation/scenes/`, avec `static const routeName`, enregistré dans les `routes` d'`ApiaryGame`. Navigation par `game.router.pushNamed(...)`/`pop()`.
- Les **composants réutilisables** vont dans `lib/presentation/components/`, rangés par notion (`components/board/`, `components/hud/`).
- **Coordonnées en pixels de jeu**, (0, 0) au coin haut-gauche de l'écran, positions entières : on raisonne en pixels du pixel art, jamais en pixels physiques. L'écran fait au moins 140×248 px de zone sûre (`ApiaryGame.minimumSize`), plus selon l'appareil : **ne jamais supposer une taille d'écran**. Chaque scène se place dans les bandes de `ApiaryGame.layout` (`ScreenLayout`), relues dans `onGameResize` ; le contenu interactif reste dans la zone sûre, seul le décor déborde sur tout l'écran. Les grandeurs de mise en page (case de 32 px, hauteurs des bandes) sont des constantes nommées de `ScreenLayout`.
- **Le pixel art est en images** (sprites, `FilterQuality.none`), jamais en formes dessinées (`drawRect`…) : à l'échelle fractionnaire, Impeller adoucit les bords des formes, pas les pixels d'une image. Seule exception admise : un `drawRect` rempli par un `ImageShader` en `FilterQuality.none` dont les bords sont hors écran, pour répéter une tuile de décor (voir `DecorComponent`).
- **Un composant affiche et transmet, il ne décide pas.** Il lit l'état, se dessine, et convertit une entrée (tap, drag) en intention envoyée à la couche d'état. La question « ces deux abeilles fusionnent-elles ? » se pose au domaine, jamais dans un `onDragEnd`.
- Construction des enfants dans `onLoad()` avec `await add(...)`, comme `BoardScene`. Pas de travail lourd dans `update()` ni `render()` : aucune allocation (`Paint`, `Vector2`, listes) par frame, les créer une fois et les réutiliser.
- **Couleurs** depuis `AppColors`, jamais de `Color(0x…)` dans un composant. **Textes** via les clés de traduction.
- Les sprites se chargent par le cache d'images de Flame, une seule fois, pas à chaque création de composant.
- Pas de widget Flutter pour l'UI du jeu : un besoin qui semble l'exiger (champ texte, dialogue système) passe par un overlay `GameWidget`, à discuter avant de l'introduire.

## Erreurs et logs

- **`talker`** pour tout log (`talker.info`, `talker.warning`, `talker.error`, `talker.handle(e, st)`), jamais `print` ni `debugPrint`, jamais `FirebaseCrashlytics`/`Sentry` en direct : l'observer branché par `CrashReportingService` s'en charge.
- Ne pas avaler une exception : la gérer réellement ou la logger avec sa stack trace.
- Les opérations asynchrones lancées sans `await` sont marquées `unawaited(...)` (le lint l'exige), et seulement quand l'échec ne doit pas bloquer l'appelant.
- Jamais de donnée personnelle dans un log (les logs partent en breadcrumbs vers Crashlytics et Sentry) ; l'UID Firebase suffit.

## Localisation

- Clés hiérarchiques en `snake_case`, rangées par écran ou notion : `board.enter`, `orders.daily_title`, `apidex.unknown_species`.
- Toute clé ajoutée l'est dans **les deux** fichiers (`assets/translations/fr.json` et `en.json`) dans le même changement. Le français est la langue de repli.
- Pas de concaténation de chaînes traduites : utiliser les arguments nommés et le pluriel d'`easy_localization`.

## Code généré

- Fichiers `*.g.dart` et `*.freezed.dart` : **ne jamais les modifier à la main**, ils sont **versionnés** et régénérés par `build_runner` (voir `CLAUDE.md`).
- Un changement sur un fichier `@freezed`, `@riverpod` ou une table Drift est accompagné de ses fichiers générés à jour.

## Dépendances

- Ajouter un paquet avec `fvm flutter pub add`, jamais en éditant les versions à la main sans résoudre.
- Avant d'ajouter : vérifier qu'aucun paquet déjà présent ne couvre le besoin, que le paquet est maintenu, et noter le choix (et ce qu'il remplace) dans `docs/STACK.md`.
- Les paquets de test vont en `dev_dependencies` (sauf `clock`, utilisé par l'app).

## Workflow

### Avant de considérer un changement terminé

- [ ] `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] `fvm dart run import_sorter:main`
- [ ] `fvm flutter analyze` : zéro avertissement
- [ ] `fvm flutter test` : tout passe ; un golden modifié a été **regardé** avant d'être régénéré
- [ ] tests ajoutés ou mis à jour pour le comportement modifié (voir `docs/TESTING.md`)
- [ ] docs à jour si une décision, une commande ou une convention a changé (`CLAUDE.md`, `docs/STACK.md`, ce fichier)

### Commits

- Format **Conventional Commits**, en anglais : `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`, avec une portée facultative (`feat(board): merge two identical larvae`).
- Un commit = un changement cohérent, qui compile et passe les tests.
- Claude ne commite pas : il prépare le changement, le commit reste à l'humain.

### Décisions

- Une décision d'architecture ou de stack se note dans `docs/STACK.md` **avec sa date** et sa raison, y compris quand elle en inverse une précédente (voir le passage à Flame).
- Quand le code et la doc divergent, on ne laisse pas traîner : soit on corrige le code, soit on met la doc à jour.

## Pour Claude en particulier

- Lire ce fichier et `docs/TESTING.md` avant d'écrire du code ou des tests.
- Quand une règle d'ici ne couvre pas un cas, suivre l'exemple le plus proche dans le code, puis proposer d'ajouter la règle ici.
- Quand une demande contredit une règle, le signaler avant de l'appliquer, plutôt que d'enfreindre la règle en silence ou de refuser.
- Ne pas introduire de nouveau pattern structurant (nouvelle couche, nouveau paquet, nouveau mécanisme d'état) sans en parler d'abord.
