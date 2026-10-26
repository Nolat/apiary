# Stratégie de tests

> Document de référence sur les tests d'Apiary : quoi tester, à quel niveau, avec quels outils, et comment les lancer. Mis en place le 2026-10-24. Voir aussi `docs/STACK.md` (stack technique) et `CLAUDE.md` (commandes).

## Principe directeur : l'UI est un canvas

Toute l'app est rendue par **Flame** (voir `docs/STACK.md`). Le jeu est **peint sur un canvas** : l'arbre de widgets Flutter ne contient qu'un `GameWidget`, et l'arbre d'accessibilité est quasiment vide. Conséquences :

- les outils qui pilotent l'app via les widgets ou l'accessibilité (**Maestro**, `find.text(...)`, finders Patrol) **ne voient pas** le plateau, les abeilles, les boutons dessinés en pixel art ;
- on teste donc le jeu **par le code** : en parlant directement à `ApiaryGame` et à ses composants, ou en comparant des **images** (goldens) ;
- la valeur des tests se concentre dans la **logique pure** (`lib/domain/`), qui ne dépend ni de Flame ni de Flutter.

Maestro a été écarté pour cette raison : sur un canvas, il ne reste que des taps par coordonnées et des captures d'écran, ce qui est fragile.

## La pyramide

| Couche | Outils | Part visée | Vitesse |
| --- | --- | --- | --- |
| **Domaine** — règles du jeu (fusion, croisements, commandes, récolte) | `package:test` via **glados** (tests par propriétés), `clock`, `Random` injecté | ~60 % | ms |
| **Données / état** — repositories, Drift, Firebase, providers Riverpod | `drift/native.dart` (SQLite en mémoire), `firebase_auth_mocks`, `mocktail`, `ProviderContainer.test()` | ~20 % | ms |
| **Présentation Flame** — scènes, composants, interactions | **flame_test** (`testWithGame`), goldens pixel-perfect (`testGameGolden`) | ~15-20 % | 10-100 ms |
| **E2E sur appareil** — parcours critiques de bout en bout | **Patrol** | quelques smoke tests | minutes |

## Arborescence

```
test/                         # tests rapides, sans appareil (`flutter test`)
├── helpers/                  # utilitaires partagés (pas de *_test.dart ici)
│   ├── game_golden.dart      #   testGameGolden() + goldenTag
│   └── pump_app.dart         #   tester.pumpApiaryApp() + setUpApiaryApp()
├── app_test.dart             # ↔ lib/app.dart
├── core/auth/…               # ↔ lib/core/auth/…
├── data/local/…              # ↔ lib/data/local/…
├── domain/…                  # ↔ lib/domain/… (à créer avec la première règle de jeu)
└── presentation/
    ├── game/…
    └── scenes/
        ├── board_scene_test.dart
        └── goldens/          # PNG de référence, versionnés
patrol_test/                  # E2E sur appareil (`patrol test`)
├── common.dart               # launchApiary($), gameOf($)
└── launch_test.dart
dart_test.yaml                # déclaration des tags (golden)
```

**Conventions :**

- `test/` **reproduit l'arborescence de `lib/`** : `lib/x/y.dart` → `test/x/y_test.dart`.
- Un fichier de test se termine par `_test.dart` (sinon il n'est pas exécuté).
- Les descriptions de test sont en **anglais**, comme le code, et forment une phrase avec le `group` : `group('AuthService.ensureSignedIn')` + `test('keeps the existing user when already signed in')`.
- Structure **arrange / act / assert**, séparée par des lignes vides.
- Les helpers partagés vont dans `test/helpers/` (ou `patrol_test/common.dart`), jamais copiés d'un fichier à l'autre.

## Commandes

```bash
fvm flutter test                               # tous les tests rapides (goldens compris)
fvm flutter test --exclude-tags golden         # sans les goldens (ce que fait la CI Linux)
fvm flutter test --tags golden                 # seulement les goldens
fvm flutter test --update-goldens --tags golden  # régénérer les goldens après un changement visuel voulu
fvm flutter test test/core/auth/auth_service_test.dart   # un fichier
fvm flutter test --plain-name "opens on the board scene" # un test par nom
fvm flutter test --coverage                    # couverture → coverage/lcov.info

patrol test -t patrol_test/launch_test.dart    # un test E2E (appareil/émulateur démarré)
patrol test                                     # tous les tests E2E
patrol develop -t patrol_test/launch_test.dart # E2E avec hot restart, pour écrire un test
```

`patrol` est la CLI `patrol_cli`, à installer une fois : `fvm dart pub global activate patrol_cli` (puis `~/.pub-cache/bin` dans le `PATH`). Elle détecte FVM toute seule (`patrol doctor` affiche « Flutter command: fvm flutter »).

---

## 1. Domaine — tests unitaires et par propriétés

C'est ici que se trouve l'essentiel de la valeur : les règles du jeu doivent vivre dans `lib/domain/` en **Dart pur** (aucun import Flutter ni Flame), pour être testables en millisecondes.

### Rendre le code déterministe

Deux sources de non-déterminisme sont au cœur du design (commandes quotidiennes, croisements, mutations) : **le temps** et **le hasard**. Elles ne doivent jamais être appelées en dur.

- **Temps** : utiliser `clock.now()` (package `clock`, dépendance du projet) et **jamais** `DateTime.now()`. En test, on fige l'heure :

  ```dart
  withClock(Clock.fixed(DateTime(2026, 10, 24, 8)), () {
    expect(dailyOrders().first.expiresAt, DateTime(2026, 10, 25));
  });
  ```

- **Hasard** : passer un `Random` en paramètre (ou l'injecter), jamais `Random()` en dur dans la logique. En test, un `Random(42)` rend un tirage reproductible. C'est aussi ce qui permettra de rejouer un scénario en debug et le mode « simulation » prévu dans `docs/STACK.md`.

### Tests par propriétés avec glados

Un test classique vérifie un exemple ; un test par propriétés vérifie une **règle sur des centaines d'entrées générées**, et en cas d'échec, **réduit** l'entrée au plus petit contre-exemple. Il est fait pour un merge game : les règles de fusion et de croisement sont des invariants.

Bonnes propriétés à viser :

- une fusion de deux éléments identiques donne toujours l'élément de niveau supérieur ;
- une fusion ne crée ni ne détruit de ressources (conservation) ;
- un croisement donne toujours une espèce existante du catalogue ;
- une commande générée est toujours réalisable avec les générateurs débloqués ;
- sérialiser puis désérialiser un état redonne le même état (aller-retour).

```dart
// test/domain/merge_test.dart
import 'package:glados/glados.dart'; // ⚠️ seul : glados réexporte package:test

import 'package:apiary/domain/…';

// Générateurs pour les types du domaine : une extension sur `Any`,
// à mettre dans test/helpers/generators.dart dès qu'ils sont réutilisés.
extension AnyBee on Any {
  Generator<Species> get species => choose(Species.values);
  Generator<Bee> get bee => combine2(species, intInRange(1, 10), Bee.new);
}

void main() {
  Glados(any.bee).test('merging a bee with its twin levels it up', (bee) {
    expect(merge(bee, bee.copyWith())!.level, bee.level + 1);
  });

  // Deux entrées, et plus d'essais pour une règle critique.
  Glados2(any.bee, any.bee, ExploreConfig(numRuns: 500))
      .test('merging never lowers the level', (a, b) {
    final result = merge(a, b);
    if (result != null) expect(result.level, greaterThan(a.level));
  });
}
```

Points d'attention :

- **N'importer que `package:glados/glados.dart`** dans ces fichiers : il réexporte `package:test`, et l'importer avec `flutter_test` crée des conflits sur `test`/`expect`/`group`. C'est aussi un garde-fou : un test de domaine qui aurait besoin de `flutter_test` signale une dépendance Flutter qui n'a rien à faire dans `domain/`.
- glados utilise une graine fixe (`Random(42)`) par défaut : les runs sont reproductibles, la CI n'est pas instable.
- Les cas limites connus (niveau max, inventaire vide…) restent en tests classiques à côté : glados complète les exemples, il ne les remplace pas.

## 2. Données et état

### Drift — SQLite réel, en mémoire

Pas de mock pour la base : `AppDatabase` accepte un `QueryExecutor`, on lui passe une base **en mémoire**, neuve à chaque test (voir `test/data/local/app_database_test.dart`) :

```dart
setUp(() => database = AppDatabase(NativeDatabase.memory()));
tearDown(() => database.close());
```

Quand des tables et des migrations arriveront : exporter les schémas avec `fvm dart run drift_dev make-migrations` et tester chaque migration (voir la doc Drift « Testing migrations »). Une migration ratée fait perdre la progression d'un joueur, c'est le test le plus important de cette couche.

### Firebase

- **Auth** : `firebase_auth_mocks` (`MockFirebaseAuth`, `MockUser`) — voir `test/core/auth/auth_service_test.dart`.
- **Firestore** : ajouter `fake_cloud_firestore` (dev) quand la première collection apparaîtra. Il n'est pas encore installé, faute de code à tester. Les repositories reçoivent `FirebaseFirestore` par constructeur (comme `AuthService` reçoit `FirebaseAuth`), ce qui permet d'y injecter le fake.
- **Règles de sécurité** (`firestore.rules`) : dès qu'elles s'ouvriront (aujourd'hui deny-all), les tester contre l'**émulateur Firebase** avec `@firebase/rules-unit-testing` (Node). Ce sont les seuls tests qui protègent réellement l'économie du jeu, puisque le client ne doit jamais pouvoir écrire de monnaie (voir `docs/STACK.md`).
- Tout autre service : mocker avec **mocktail** (`class MockX extends Mock implements X {}`), sans génération de code.

### Riverpod

Tester les providers **sans widget** avec `ProviderContainer.test()` (Riverpod 3), qui se dispose tout seul à la fin du test :

```dart
final container = ProviderContainer.test(
  overrides: [boardRepositoryProvider.overrideWithValue(FakeBoardRepository())],
);
expect(container.read(boardProvider).cells, isEmpty);
```

Pour un `AsyncNotifier`, attendre `container.read(provider.future)`.

## 3. Présentation Flame

### Tests de comportement : `testWithGame`

`flame_test` monte un vrai `ApiaryGame` (sans widget ni rendu), sur lequel on peut naviguer, ajouter des composants et avancer le temps. Voir `test/presentation/game/apiary_game_test.dart` :

```dart
testWithGame<ApiaryGame>('opens on the board scene', ApiaryGame.new, (game) async {
  await game.ready(); // les enfants d'une route se montent aux ticks suivants

  expect(game.router.currentRoute.name, BoardScene.routeName);
});
```

- `await game.ready()` après tout ajout ou toute navigation, sinon les composants ne sont pas encore montés.
- `game.update(dt)` fait avancer le temps de jeu (animations, timers, effets).
- Entrées (tap, drag d'une abeille vers une autre) : appeler les handlers des composants avec les faux événements de `flame_test` (`createTapDownEvents`, `createDragUpdateEvents`…), ou passer par `tester.tapAt`/`tester.dragFrom` dans un test widget avec un `GameWidget`.
- Lire l'état métier (via le domaine ou les providers) plutôt que des propriétés de rendu : un test qui vérifie `component.position` casse à chaque ajustement de mise en page.

### Goldens pixel-perfect : `testGameGolden`

Le pixel art se prête très bien aux goldens : images petites, aucune police système, différences lisibles à l'œil. Le helper `testGameGolden` (`test/helpers/game_golden.dart`) rend l'`ApiaryGame` complet **à sa taille minimale, 140×246 (la mise en page la plus serrée, celle de l'iPhone SE), avec un device pixel ratio de 1** : **un pixel du PNG = un pixel du jeu**. Les autres tailles d'écran sont couvertes par les tests de `ScreenLayout` (les 7 appareils et un balayage de tailles) et par `tool/screenshots/ios.sh`.

```dart
testGameGolden(
  'renders the empty board',
  goldenFile: 'goldens/board_scene_empty.png',
  arrange: (game, tester) async {
    // optionnel : naviguer, poser des abeilles, game.update(dt)…
  },
);
```

Règles :

- **Plateforme de référence : macOS.** Les goldens sont générés et vérifiés sur macOS : le rendu (anti-aliasing, Impeller/Skia) peut différer d'un pixel sous Linux. Ils portent le tag `golden` : la CI Linux les exclut, un job macOS dédié les exécute.
- Un golden qui change, c'est une **revue visuelle** : ouvrir le PNG dans le diff de la PR avant de valider. On ne régénère jamais pour « faire passer » sans regarder.
- En cas d'échec, Flutter écrit `failures/*_masterImage.png`, `*_testImage.png` et `*_isolatedDiff.png` à côté du test (ignorés par git ; en CI, publiés en artefact `golden-failures`).
- Un golden par **état visuel significatif** (plateau vide, plateau plein, abeille sélectionnée, commande remplie…), pas un par test.
- Les animations : figer le temps avec `game.update(dt)` à un instant précis avant la capture.

### Mise en page multi-écrans : `tool/screenshots/ios.sh`

Les goldens tournent à 140×246 / DPR 1, où le viewport est trivial (×1). Pour vérifier le `GameViewport` et `ScreenLayout` sur de vrais écrans, `tool/screenshots/ios.sh` compile l'app pour simulateur avec `--dart-define=APIARY_LAYOUT_DEBUG=true`, qui affiche une mire par-dessus les scènes (`LayoutDebugOverlay` : contour de chaque bande, miel pour le plateau, damier de pixels de jeu dessiné comme un sprite, échelle). Le script la lance sur des simulateurs extrêmes (iPhone SE 16:9 à DPR 2, mini, Pro, Pro Max, pliable, iPad mini, iPad Pro 13"), qu'il crée et démarre au besoin. Puis `tool/screenshots/check_layout.py` mesure chaque capture, pour une échelle s : plateau de 140s×180s pixels physiques, bord à bord sur iPhone, centré sur les écrans marqués `centered` (iPad, pliable) ; contours des bandes rencontrés dans l'ordre (HUD, commandes, plateau, barre du bas) sans chevauchement ; damier à ⌊s⌋ ou ⌈s⌉ px par pixel de jeu (rendu « nearest », sans flou) ; aucune bande de la couleur de fond du jeu sur les côtés.

```bash
tool/screenshots/ios.sh                                # tous les appareils (~10 min)
tool/screenshots/ios.sh "iPhone SE (3rd generation)"   # seulement ceux nommés
```

Captures dans `build/screenshots/ios/` ; code de sortie 1 si une vérification échoue. Deux cas ne sont que des avertissements (⚠) : un plateau décentré sur un écran `centered` (la zone sûre le décale quand la zone sûre l'exige, ce qu'une capture ne dit pas — la règle est couverte par les tests du viewport) et le damier des écrans **réduits par iOS** (marqués `downsampled` dans le script : iPhone mini, modèles « Plus »), que la réduction brouille. À relancer après tout changement du viewport ou de la mise en page des scènes.

### Shell Flutter

Le seul widget à tester est l'hôte `ApiaryApp`. `test/app_test.dart` vérifie qu'il monte bien le `GameWidget`, via `tester.pumpApiaryApp()` (`test/helpers/pump_app.dart`), qui reproduit l'enrobage de `bootstrap()` (localisation, Riverpod) sans Firebase ni Sentry.

**Ne jamais appeler `pumpAndSettle()`** avec un `GameWidget` à l'écran : la boucle de jeu demande des frames en continu, il expire toujours. Utiliser `pump()`.

## 4. E2E sur appareil — Patrol

Patrol lance **la vraie app** (`bootstrap()` complet : Sentry, Firebase, connexion anonyme) sur un émulateur ou un appareil, et sait en plus piloter l'OS (dialogues de permission, notifications, Game Center plus tard), ce que `integration_test` seul ne fait pas.

Comme le jeu est un canvas, les finders Patrol (`$('texte')`) ne servent qu'aux éléments natifs ou Flutter. Le jeu se pilote **par `ApiaryGame`**, récupéré avec `gameOf($)` (`patrol_test/common.dart`) :

```dart
patrolTest('cold start signs in anonymously and opens the board', ($) async {
  final game = await launchApiary($);

  expect(getIt<AuthService>().currentUserId, isNotNull);
  expect(game.router.currentRoute.name, BoardScene.routeName);
});
```

**Quoi tester en E2E** : uniquement ce qui ne peut pas l'être plus bas, c'est-à-dire l'intégration réelle avec la plateforme et les services. Candidats : démarrage à froid et connexion, persistance après redémarrage de l'app, permission de notifications pour les commandes du jour, achat in-app en sandbox, liaison Game Center / Play Games. Une règle de jeu testée en E2E est une règle mal placée.

### Configuration en place

- `pubspec.yaml` : section `patrol:` (nom de l'app, `package_name`/`bundle_id` `fr.nolat.apiary`).
- **Android** (opérationnel, vérifié sur émulateur) :
  - `android/app/build.gradle.kts` : runner `pl.leancode.patrol.PatrolJUnitRunner`, `clearPackageData`, **Android Test Orchestrator** (chaque test démarre dans un process neuf, données effacées) ;
  - `android/app/src/androidTest/java/fr/nolat/apiary/MainActivityTest.java` : point d'entrée JUnit qui liste et lance les tests Dart.
- **iOS** (opérationnel, vérifié sur simulateur iPhone 16 Pro) :
  - cible de tests UI `RunnerUITests` dans `ios/Runner.xcodeproj`, en Objective-C, point d'entrée `ios/RunnerUITests/RunnerUITests.m` (macro `PATROL_INTEGRATION_TEST_IOS_RUNNER`) ;
  - liée au paquet **`FlutterGeneratedPluginSwiftPackage`** : le projet utilise Swift Package Manager, pas CocoaPods, et Patrol y arrive comme les autres plugins ;
  - mêmes xcconfig que `Runner` pour chaque configuration (`Debug` → `Flutter/Debug.xcconfig`, `Release`/`Profile` → `Flutter/Release.xcconfig`), iOS 15.0, *User Script Sandboxing* à `NO` ;
  - phases de build `xcode_backend build` (en premier) et `xcode_backend embed_and_thin` (en dernier), qui compilent et embarquent le code Flutter dans le bundle de test ;
  - ajoutée au scheme `Runner` avec `parallelizable = "NO"` (l'exécution parallèle clone le simulateur et casse Patrol).

### Comment la cible iOS a été créée

La cible a été générée par script avec la gem Ruby **`xcodeproj`** (celle qu'utilisent CocoaPods et fastlane) plutôt que dans l'interface de Xcode, en suivant la [procédure officielle Patrol](https://patrol.leancode.co/documentation) (variante SPM) et le projet d'exemple de Patrol. Si elle devait être recréée (projet iOS régénéré par `flutter create`, par exemple), deux options :

- **Xcode** : *File → New → Target… → UI Testing Bundle* (`RunnerUITests`, Objective-C, cible testée `Runner`), supprimer `RunnerUITestsLaunchTests.m`, puis appliquer chaque point de la liste ci-dessus (*General → Frameworks and Libraries* pour le paquet SPM, *Build Phases* pour les deux scripts, *Build Settings* pour le sandboxing et le deployment target, *Edit Scheme → Test* pour désactiver le parallélisme) ;
- **script** : `ruby -rxcodeproj`, avec `project.new_target(:ui_test_bundle, …)`. Attention : `xcodeproj` lie `Foundation.framework` par défaut avec un chemin de SDK figé (`iPhoneOS26.0.sdk`), à retirer.

Vérification : `fvm flutter build ios --config-only --simulator patrol_test/launch_test.dart`, puis `patrol test -t patrol_test/launch_test.dart` avec un simulateur démarré.

### Points d'attention

- **Après un `patrol test` iOS**, `ios/Flutter/Generated.xcconfig` (ignoré par git) pointe vers `patrol_test/test_bundle.dart` (`FLUTTER_TARGET`) : un *Run* lancé directement depuis Xcode démarrerait les tests au lieu de l'app. `fvm flutter run` le régénère ; sinon `fvm flutter build ios --config-only`.
- **Un `bootstrap()` par test.** `bootstrap()` initialise des singletons de process (Firebase, `get_it`). Sur Android, l'orchestrator donne un process neuf à chaque test ; **sur iOS, les tests d'un même run partagent le process** : en attendant de rendre l'initialisation réentrante, garder **un seul test par fichier** côté iOS.
- **Vrais services.** Les E2E parlent au **projet Firebase `fr-nolat-apiary`** (chaque run crée un utilisateur anonyme) et envoient d'éventuelles erreurs à **Sentry** (environnement `development`). Acceptable tant que la base est vide ; à terme, prévoir un projet Firebase de test ou l'émulateur Firebase (`useAuthEmulator`/`useFirestoreEmulator` activés par un `--dart-define`).
- **Pas en CI pour l'instant** : il faut un émulateur. Piste quand le besoin se fera sentir : **Firebase Test Lab** (Patrol le documente) sur les branches principales ou en nightly, plutôt qu'à chaque PR.
- `patrol test` génère `patrol_test/test_bundle.dart` (ignoré par git).

---

## Intégration continue

`.github/workflows/ci.yml` :

| Job | Runner | Étapes |
| --- | --- | --- |
| `analyze-and-test` | ubuntu | `pub get`, `build_runner`, `flutter analyze`, `flutter test --exclude-tags golden` |
| `goldens` | macos | `pub get`, `build_runner`, `flutter test --tags golden` ; images d'échec publiées en artefact `golden-failures` |

Les minutes macOS sont décomptées ×10 par GitHub sur un dépôt privé. Si le coût devient gênant, on peut lancer le job `goldens` uniquement sur les PR qui touchent `lib/presentation/`, `assets/` ou `test/` (filtre `paths`).

## Dépendances de test

| Paquet | Type | Rôle |
| --- | --- | --- |
| `flutter_test` | dev (SDK) | socle des tests Flutter |
| `clock` | **runtime** | horloge injectable (`clock.now()`), utilisée par le code de l'app |
| `glados` | dev | tests par propriétés, réduction des contre-exemples |
| `mocktail` | dev | mocks sans génération de code |
| `flame_test` | dev | `testWithGame`, faux événements d'entrée, matchers Flame |
| `firebase_auth_mocks` | dev | faux `FirebaseAuth` |
| `patrol` | dev | E2E sur appareil (+ CLI `patrol_cli`, installée globalement) |
| `fake_cloud_firestore` | dev, **à ajouter** | faux Firestore, dès la première collection |

Note : `glados`, `flame_test` et `firebase_auth_mocks` tirent `package:test`, dont la version est bornée par le `test_api` du SDK Flutter. Cela contraint `analyzer` et a fait redescendre `freezed` de 4.0.3 à 4.0.1 (patch). Sans impact aujourd'hui ; à garder en tête si une montée de version de freezed ou de riverpod_generator bloque à la résolution.

## Reste à faire

- [ ] Premiers tests de domaine (glados) avec la première règle de jeu, et `test/helpers/generators.dart`.
- [ ] `fake_cloud_firestore` + tests des règles Firestore sur émulateur à la première collection.
- [ ] Tests de migrations Drift à la première table.
- [ ] Environnement Firebase isolé pour les E2E (émulateur ou projet de test).
- [ ] E2E en CI (Firebase Test Lab).
- [ ] Mode « simulation » headless (voir `docs/STACK.md`), qui s'appuiera sur le domaine déterministe (`clock` + `Random` injecté).
