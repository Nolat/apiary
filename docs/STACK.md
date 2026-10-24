# Stack technique

> Document de référence sur l'infrastructure technique du jeu (au-delà du socle déjà en place — voir `CLAUDE.md` pour l'existant : routing, DI, thème). Liste les décisions retenues et les points d'attention concrets à traiter au fil de l'implémentation de chaque brique.

## Stack retenue

| Domaine                      | Choix                                                                     |
| ---------------------------- | ------------------------------------------------------------------------- |
| Moteur de rendu / jeu        | **Flame** — 100% de l'architecture app (Flutter ne sert que d'hôte via `GameWidget`) |
| Navigation                   | **Flame `RouterComponent`**                                               |
| State management             | **Riverpod** (déjà en place, à ponter vers les composants Flame)          |
| Stockage local               | **Drift** (SQLite typé)                                                   |
| Stockage cloud               | **Firestore** (cache local + mode offline)                                |
| Authentification             | **Firebase Auth** lié au Game Service (Game Center / Play Games Services) |
| Achats in-app                | **RevenueCat**                                                            |
| Médiation publicitaire       | **LevelPlay**                                                             |
| Crash reporting / monitoring | **Firebase Crashlytics** + **Sentry** (en parallèle)                      |
| Animations                   | **Flame** (sprites/animations natives) + **Rive** en complément pour animations riches (via `flame_rive`) |
| Audio (musique & effets)     | **audioplayers**                                                          |

---

## Moteur de rendu — Flame (décision inversée le 2026-10-24)

- La DA du jeu est désormais fixée en **pixel art** (224 px de jeu de large, grille 7×9 de cases 32 px, assets ×2 — voir `docs/DESIGN.md`), ce qui favorise un moteur à sprites/tilesets plutôt que des widgets Flutter hand-rolled.
- **Flame est adopté pour 100% de l'architecture de l'app** : ce n'est pas limité au plateau, toute l'app (Apidex, Settings, écrans de fin de journée compris) est censée vivre dans Flame plutôt que dans l'arbre de widgets Flutter/Material.
- Cela **inverse** la décision précédente (Flame évalué puis écarté au profit de `Draggable`/`DragTarget`/`AnimationController` sur widgets) — cette décision avait été prise avant que la DA soit tranchée ; elle ne tient plus.
- Conséquences à travailler au fil de la migration :
  - **En place** : `ApiaryApp` (`lib/app.dart`) est un `MaterialApp` réduit au rôle d'hôte (délégués de localisation, plumbing plateforme) dont le `home` est un `GameWidget<ApiaryGame>`. `ApiaryGame` (`lib/presentation/game/apiary_game.dart`) est l'unique `FlameGame`, piloté par un `RouterComponent` pour la navigation entre scènes (plateau, Apidex, Settings, etc.).
  - Le design system actuel (`lib/core/theme/app_theme.dart`/`app_colors.dart`, pensé pour `ThemeData`) doit être reporté vers des équivalents Flame (palettes/styles de texte consommés directement par les composants).
  - `easy_localization` reste a priori valable comme wrapper Flutter au sommet de l'app (host shell), mais l'accès aux traductions depuis des composants Flame reste à valider.
  - Rive n'est plus un simple widget ajouté à l'arbre Flutter : à intégrer via `flame_rive` si des animations riches sont nécessaires (voir [Rive](#rive)).
  - **En place (2026-10-24)** : caméra avec un `GameViewport` plein écran (`lib/presentation/game/game_viewport.dart`). Les coordonnées de jeu partent du coin haut-gauche de l'écran ; l'échelle est la plus grande à laquelle la zone sûre contient encore **224×398 px de jeu** (`ApiaryGame.minimumSize`). Sur tous les iPhone, c'est la largeur qui limite : l'écran fait **exactement 224 px de jeu de large**, et la **grille 7×9 (224×288) le remplit bord à bord** (décision 2026-10-24 : la grille est toujours en « fitWidth » sur iPhone) ; la hauteur varie (~398 à ~470 px sûrs). Sur iPad et pliables, c'est la hauteur : la grille est aussi grande que possible en laissant la place aux autres bandes, centrée, et l'écran s'élargit (jusqu'à ~310 px) — une grille pleine largeur y prendrait 96 % de la hauteur (iPad Pro) voire plus que l'écran (pliable). **Mise en page en bandes, inspirée de Flambé** : `ScreenLayout` (`lib/presentation/game/screen_layout.dart`, fonction pure lue via `ApiaryGame.layout` dans `onGameResize`) place HUD (16) et commandes (56) en haut de la zone sûre, barre du bas (32) en bas, grille juste au-dessus, et un espace libre (≥ 6) qui absorbe la différence de hauteur ; le décor couvre tout l'écran (`ApiaryGame.visibleArea`), y compris sous la Dynamic Island. Les panneaux s'élargiront en 9-slice (`NineTileBoxComponent`) sur les écrans de plus de 224 px ; le décor se dessine à la taille maximale (~310×560) et l'écran le recadre.
  - **Décision (2026-10-24) : échelle fractionnaire, rendu « nearest ».** Première version à facteur entier (pixel-perfect strict) abandonnée : elle laissait jusqu'à 20 % de la largeur en marges (960 px sur 1206 sur un iPhone 18 Pro). L'échelle vaut désormais largeur ÷ 224 sur iPhone (×5,38 sur 18 Pro, ×5,89 sur Pro Max, ×3,35 sur SE) : certains pixels de jeu font 1 pixel physique de plus que d'autres — invisible aux densités d'iPhone, à surveiller avec les vrais sprites. Si l'irrégularité se voit avec les vrais sprites, passer au **« sharp bilinear »** : rendu au facteur entier inférieur dans une image hors écran, puis agrandissement lissé du petit reste (×1,08 sur 18 Pro) — net et régulier, plus coûteux. **Conséquence pour le dessin** : à échelle fractionnaire, Impeller anti-aliase toujours la géométrie (MSAA, `Paint.isAntiAlias` ignoré) — un `drawRect` a des bords flous d'1 pixel physique. Le pixel art passe donc par des **images** (sprites, `FilterQuality.none`), dont les pixels restent nets ; pas de formes dessinées pour les éléments pixel art. Vérifié sur simulateurs par `tool/screenshots/ios.sh` (voir `docs/TESTING.md`). Le viewport pilote l'ancre et la position du viewfinder. Le plateau est une scène Flame (`lib/presentation/scenes/board_scene.dart`, vide pour l'instant).
  - Reste à définir : structure précise des composants Flame par écran, choix des assets ×1/×2 selon `GameViewport.pixelScale`, gestion des cas où un widget Flutter natif reste nécessaire (champs de texte, permissions systèmes, etc. via overlays `GameWidget`).

## Navigation — Flame `RouterComponent`

- **En place** : le `RouterComponent` appartient à `ApiaryGame` (`game.router`) et est ajouté à son `world`, pour que les scènes soient rendues à travers la caméra en résolution de référence.
- Chaque écran est une scène : un `Component` dans `lib/presentation/scenes/`, exposant une constante `routeName`, enregistré dans la map `routes` du `RouterComponent`. Naviguer via `game.router.pushNamed(...)`/`pop()`.
- À définir : routes de type overlay/dialog (`OverlayRoute`) pour les pop-ups (Apidex, détails d'une commande), et transitions entre scènes.

## State management — Riverpod

- En place (`flutter_riverpod` + `riverpod_generator`, voir `CLAUDE.md`).
- Préférer les `AsyncNotifier`/`Notifier` (codegen `@riverpod`) aux anciens `StateNotifier`.
- Séparer clairement :
  - un provider **état de partie en cours** (grille du plateau — local, éphémère, pas besoin de Firestore)
  - un provider **progression méta** (générateurs débloqués, espèces découvertes, monnaie — synchronisé, persistant)
- Avec le passage à Flame, ces providers devront être consommés depuis des composants Flame plutôt que des widgets — pont exact (ex. `flame_riverpod` ou accès manuel au container) encore à définir.

## Stockage local — Drift

- SQLite typé, migrations prévisibles.
- Usage prévu : état de la grille du plateau en cours, préférences UI (volume, langue), cache éventuel avant sync.

## Stockage cloud — Firestore

- **En place** : projet Firebase dédié `fr-nolat-apiary`, apps Android et iOS `fr.nolat.apiary`, configurées via `flutterfire configure` (`lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `firebase.json`). Pour régénérer : supprimer d'abord `lib/firebase_options.dart` (sinon la CLI tente de patcher le fichier existant et échoue avec « `UnsupportedError` not found in iOS »). `uploadDebugSymbols` est à `false` dans `firebase.json` pour que la CLI n'ajoute pas sa propre phase d'upload dSYM en doublon de « Upload Crashlytics Symbols ». `Firebase.initializeApp()` est appelé dans `bootstrap()` et `FirebaseFirestore` est enregistrée dans `get_it` (`lib/core/di/injection.dart`) ; pas encore de collections/schéma.
- **En place (2026-10-24)** : base `(default)` en mode natif, édition standard, région **`eur3`** (multi-région Europe), créée depuis la console, protection contre la suppression activée (`firestore:databases:update "(default)" --delete-protection DISABLED` pour la lever avant une suppression volontaire). La région ne peut plus changer : une autre région impose de supprimer puis recréer la base (le nom `(default)` reste indisponible environ 5 minutes après une suppression). Projet par défaut de la CLI fixé dans `.firebaserc`.
- Cache local persistant activé par défaut sur mobile + support offline natif.
- Répartition :
  - **Drift** : état de la grille du plateau en cours, préférences UI
  - **Firestore** : tout ce qui doit survivre à une réinstall / se synchroniser entre appareils (générateurs débloqués, espèces découvertes, monnaie, cosmétiques achetés)

### Sécurité Firestore

- **En place** : règles deny-all (`allow read, write: if false`) actives sur la base tant qu'aucune collection n'est définie ; `firestore.rules` est la source de vérité, déclarée avec `firestore.indexes.json` dans la section `firestore` de `firebase.json`. Redéployer après modification via `npx -y firebase-tools@15.34.1 deploy --only firestore:rules` (vérifier d'abord avec `--dry-run`, qui compile les règles ; attention, sur un projet sans base, ce dry-run active l'API et crée la base `(default)` en `nam5`).
- Écrire les règles de sécurité dès le début du projet, pas à la fin.
- Ne jamais laisser le client écrire directement des valeurs à valeur économique (monnaie, déblocages payants) — passer par des Cloud Functions ; le client ne doit que lire.
- Règles basées sur l'UID Firebase Auth comme clé de document par utilisateur.

## Authentification — Firebase Auth + Game Service

- **État actuel** : auth anonyme (`FirebaseAuth.instance.signInAnonymously()`) câblée dans `lib/bootstrap.dart`, `FirebaseAuth` enregistrée dans `get_it`. Le lien Game Center / Play Games Services n'est pas encore fait — pas de compte développeur Apple/Google configuré pour l'instant.
- Cible à terme : lier l'UID anonyme existant au credential Game Service (`linkWithCredential`) plutôt que créer un nouvel utilisateur, pour ne pas perdre la progression déjà associée.
- Points d'attention à traiter le moment venu :
  - Play Games Services ne fournit pas de credential Firebase natif — passage par `serverAuthCode` + échange via Cloud Function.
  - Prévoir un flux de fallback si le joueur refuse/n'a pas de compte Game Service (progression locale via Drift, ou auth anonyme avec liaison ultérieure).
  - Tester le scénario changement d'appareil / réinstallation : la reconnexion doit retrouver le même UID Firebase.
  - Politique claire pour un joueur avec deux comptes Game Service sur deux appareils.
  - L'authentification Game Center doit rester silencieuse/non-bloquante au lancement (exigence Apple).
  - Partir sur Play Games Services **v2** pour un nouveau projet.

## RevenueCat

- Configurer les entitlements dès le début, même avec un seul produit.
- Envisager un webhook RevenueCat → Cloud Functions/Firestore pour garder le backend au courant des achats sans dépendre uniquement du SDK client.
- Prévoir les écrans obligatoires exigés par les stores : restauration des achats, conditions d'utilisation, politique de confidentialité liée depuis l'app.

## LevelPlay (médiation pub)

- Isoler la logique pub dans une couche dédiée (interface abstraite + implémentation LevelPlay) pour pouvoir changer de médiation sans toucher au reste du code.
- Intégrer les rewarded ads dans la boucle de jeu dès la conception (ex. recharger l’énergie, doubler une récompense de fin de journée).
- Prévoir un écran de consentement RGPD / App Tracking Transparency (iOS) avant d'initialiser le SDK publicitaire.

## Crash reporting / monitoring — Firebase Crashlytics

- **En place** : `firebase_crashlytics`, initialisation dans `CrashReportingService` (`lib/core/crash_reporting/crash_reporting_service.dart`, enregistrée en DI, appelée depuis `bootstrap()` juste après `configureDependencies()`). Capture les erreurs Flutter fatales et non gérées.
- **En place** : `setCrashlyticsCollectionEnabled(kReleaseMode)` — activé seulement en release.
- **En place** : `setUserIdentifier` avec l'UID Firebase, appelé juste après `AuthService.ensureSignedIn()`.
- **En place** : le logger centralisé Talker (`lib/core/logging/talker_service.dart`) est branché sur Crashlytics via un `TalkerObserver` custom — `talker.error(...)`/`talker.warning(...)` deviennent des `recordError`, et tout log Talker devient un breadcrumb Crashlytics. Passer par `talker`, jamais directement par Crashlytics.
- **En place (iOS)** : projet en Swift Package Manager (pas de Podfile) — upload des dSYM géré via une Run Script Build Phase "Upload Crashlytics Symbols" sur la cible `Runner`, variante SPM du script officiel Firebase.
- **En place (Android)** : plugins Gradle `com.google.firebase.crashlytics` 3.0.8 et `com.google.gms.google-services` 4.5.0 (`android/settings.gradle.kts`) — les versions posées par `flutterfire configure` (2.8.1 / 4.3.15) cassaient tout build release sous Gradle 9 (`groovy/util/XmlSlurper` dans `uploadCrashlyticsMappingFileRelease`).
- À faire plus tard : `setCustomKey` pour attacher le contexte de partie en cours au crash (aucune feature de gameplay n'a de state à exposer pour l'instant) ; Firebase Performance Monitoring si besoin de surveiller les temps de rendu/requêtes ; configurer les alertes Crashlytics dans la console Firebase.

## Monitoring — Sentry (en parallèle de Crashlytics, ajouté le 2026-10-24)

- **En place** : `sentry_flutter` (v10), projet Sentry `apiary` dans l'org `fr-nolat-apiary` (région EU, `de.sentry.io`). Options dans `lib/core/crash_reporting/sentry_config.dart` (DSN en dur — il ne permet que l'envoi d'événements). `SentryFlutter.init()` est appelé en tout premier dans `bootstrap()` (après `SentryWidgetsFlutterBinding.ensureInitialized()`, qui active le suivi des frames lentes/gelées), et l'app est enveloppée dans `SentryWidget` (screenshots, tracing des interactions).
- **En place** : erreurs + tracing (`tracesSampleRate` 1.0 en debug, 0.2 en release), screenshot joint aux erreurs, `release` (`fr.nolat.apiary@<version>+<build>`) auto, `environment` = `production` en release / `development` sinon. Contrairement à Crashlytics, Sentry reçoit aussi les erreurs des builds debug (filtrer par environnement).
- **En place** : cohabitation avec Crashlytics — Sentry installe ses handlers globaux (`FlutterError.onError`, `PlatformDispatcher.onError`) à l'init ; `CrashReportingService.initialize()` pose ensuite les handlers Crashlytics en **chaînant** vers ceux de Sentry (ne pas les écraser). L'observer Talker envoie erreurs/exceptions aux deux (`recordError` + `Sentry.captureException`) et les logs en breadcrumbs aux deux. `CrashReportingService.setUserIdentifier()` pose l'UID Firebase sur les deux.
- **En place (Android)** : `minSdk = 26` imposé par `sentry_flutter` 10.
- Les deux SDK natifs installent leurs handlers de crash natifs (signaux/Mach sur iOS, NDK sur Android) ; ils chaînent en général, mais si des crashs natifs manquent d'un côté, c'est la piste à creuser.
- **En place** : builds release via fastlane — lane `release` dans `ios/fastlane/Fastfile` et `android/fastlane/Fastfile` (`cd ios && bundle exec fastlane release`, idem pour `android` ; un `Gemfile`/`Gemfile.lock` par plateforme, `bundle install` au préalable ; les gems s'installent dans `vendor/bundle/` à la racine, partagé par les deux plateformes et ignoré par git, via `ios/.bundle/config` et `android/.bundle/config` — l'installation dans le Ruby Homebrew échoue, `rdoc` y tentant de réécrire un fichier en lecture seule du Cellar) : `flutter build ipa|appbundle --release --split-debug-info=build/debug-info`, puis `sentry_dart_plugin` (config dans le bloc `sentry:` de `pubspec.yaml` : symboles Dart, dSYM iOS trouvés dans `build/ios/archive`, sources, création/finalisation de la release `fr.nolat.apiary@<version>+<build>` — même nom que celui envoyé par le SDK), puis `firebase crashlytics:symbols:upload` (avec `--split-debug-info`, Crashlytics a lui aussi besoin des symboles Dart). Ne plus faire de build release sans passer par ces lanes, sinon les stack traces Dart seront illisibles sur les deux services. Pas d'`--obfuscate` : Crashlytics ne sait pas désobfusquer les noms Dart.
- **En place** : les lanes exigent `SENTRY_AUTH_TOKEN` (token d'**organisation** Sentry, scope release/upload), exporté ou dans `.env.sentry` à la racine (gitignoré) — jamais dans `pubspec.yaml`. Elles échouent avant le build si le token manque. En CI, le mettre dans les secrets GitHub Actions.
- À faire : mapping ProGuard/R8 Java/Kotlin Android (nécessite le Sentry Android Gradle Plugin ; peu de code natif propre pour l'instant) ; brancher le repo GitHub sur l'org Sentry pour les suspect commits (`commits: "false"` dans `pubspec.yaml` en attendant) ; session replay (désactivé — à évaluer vu le rendu canvas Flame) ; `sentry_drift` pour tracer les requêtes Drift ; alertes Sentry.

## Rive

- Fallback pour micro-animations riches (pas encore utilisé) — DA désormais fixée en pixel art (voir `docs/DESIGN.md`) ; usage probablement plus restreint qu'envisagé initialement, le pixel art se prêtant surtout à des sprite-sheets/animations frame par frame gérées nativement par Flame.
- Avec le passage à Flame, l'intégration se fait via `flame_rive` plutôt qu'en widget Flutter autonome dans l'arbre Material.
- Utiliser au moins la version `0.15.0-dev.1` du package `rive` (gain de perf constaté sur Android).
- Si plusieurs éléments animés simultanés (ex. ruches actives, incubateurs) : regrouper dans un seul artboard avec plusieurs state machines plutôt que plusieurs widgets Rive séparés.
- Piloter les transitions via les inputs des State Machines plutôt que de recharger des animations à chaque changement d'état.
- Éviter de multiplier les `RiveAnimation`/artboards simultanés à l'écran (perf Android).

## Audio — audioplayers (musique & effets)

`audioplayers` supporte nativement plusieurs instances simultanées, donc séparer musique et effets en deux pistes distinctes.

- Une instance `AudioPlayer` unique et persistante pour la **musique** (`ReleaseMode.loop`, jamais recréée entre navigations).
- Un **pool** de quelques instances dédiées aux **effets sonores** (les effets courts peuvent se chevaucher) — jamais de nouvel `AudioPlayer` par déclenchement.
- `PlayerMode.lowLatency` pour les effets courts (SoundPool sur Android), `PlayerMode.mediaPlayer` (par défaut) pour la musique.
- Précharger les effets fréquents via `AudioCache` au démarrage plutôt qu'à la première utilisation.
- Écouter les interruptions natives (appel entrant, casque débranché) pour mettre la musique en pause automatiquement ; respecter le mode silencieux du système pour les effets non critiques.
- Mettre la musique en pause (pas juste baisser le volume) pendant une pub rewarded, puis la reprendre à la fermeture.
- Deux curseurs de volume séparés dans les réglages (musique / effets), stockés comme préférence locale (Drift), chacun pouvant être coupé indépendamment.
- Pas de fade natif dans `audioplayers` : gérer les transitions douces entre musiques via des ajustements progressifs de volume (`setVolume` en boucle courte).

## Architecture générale

- Le passage à Flame (voir [Moteur de rendu](#moteur-de-rendu--flame-décision-inversée-le-2026-10-24)) change la couche `presentation/` (composants Flame plutôt que widgets Flutter) mais ne remet pas en cause la séparation par couches elle-même : `domain/`/`data/` restent du Dart pur, indépendant du moteur de rendu.
- Séparer la logique de jeu pure (Dart sans dépendance Flutter) dans `lib/domain/` — fusion, mutations, génération des commandes — testable unitairement sans UI (cohérent avec la séparation par couches déjà en place, voir `CLAUDE.md`).
- Isoler un `Random` seedable dans la logique pour pouvoir rejouer des scénarios en debug.
- CI basique dès le début (GitHub Actions) : lint + tests (job Linux) + goldens (job macOS) — voir `docs/TESTING.md`.
- Prévoir un flag de config (remote config Firebase ou JSON) pour ajuster l'équilibrage (durées de vie des abeilles, coûts d’énergie, taille des journées) sans recompiler.
- Tester tôt sur un appareil Android bas/moyen de gamme, pas seulement sur simulateur iOS ou appareil haut de gamme.

## Tests et QA

- **En place (2026-10-24)** — stratégie complète, outils et conventions dans **`docs/TESTING.md`**. En résumé : l'UI étant un canvas Flame, l'effort porte sur la logique pure (`domain/`, tests unitaires + tests par propriétés **glados**, temps via `clock` et `Random` injecté), puis données/état (Drift en mémoire, `firebase_auth_mocks`, `mocktail`, `ProviderContainer.test()`), puis scènes Flame (**`flame_test`** + goldens pixel-perfect à 224×398 (taille minimale), référence macOS), et quelques E2E **Patrol** sur appareil. Maestro écarté (aveugle sur un canvas).
- Envisager un mode "simulation" headless : lancer la logique de jeu en boucle des milliers de fois sans UI pour détecter les déséquilibres avant le playtest humain.

## Performance / build

- Activer `--split-debug-info` et `--obfuscate` pour les builds de release.
- Surveiller la taille de l'APK/IPA au fur et à mesure de l'ajout d'assets Rive (les fichiers `.riv` peuvent grossir vite).

## Analytics

- Firebase Analytics pour suivre où les joueurs abandonnent une partie et quelles commandes bloquent le plus — précieux pour l'équilibrage au fil des itérations.

## Outillage IA — MCP Dart/Flutter

- **En place** : configuré dans `.mcp.json` à la racine du repo (scope projet, partagé via git), lancé via `fvm dart mcp-server` pour rester sur le SDK pinné par FVM.
- Serveur MCP Dart/Flutter **officiel**, développé et maintenu par les équipes Dart et Flutter chez Google — à ne pas confondre avec des serveurs MCP tiers non officiels aux noms proches.
- Nécessite Dart SDK 3.9+ ou Flutter 3.35+ (le projet est pinné en 3.47.8 via FVM, donc compatible).
- Expose notamment : analyse et correction d'erreurs de code, interaction avec une application en cours d'exécution (hot reload, erreurs runtime), recherche de packages pub.dev, gestion des dépendances, exécution des tests.
- Statut : **expérimental**, évolue rapidement. Complète les outils déjà en place (CI, lint, tests), ne les remplace pas.
