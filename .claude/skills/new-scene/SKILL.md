---
name: new-scene
description: Scaffold a new Flame scene (screen) in Apiary — the scene component, its route in ApiaryGame, translation keys in fr/en, a testWithGame navigation test and a golden. Use when the user asks for a new screen such as the Apidex, Settings or the shop.
disable-model-invocation: true
argument-hint: <SceneName> [short description of the screen]
---

Create the Flame scene `$ARGUMENTS` in Apiary. Every screen is a Flame scene registered in `ApiaryGame`'s router — there are no Flutter widget screens (see `CLAUDE.md`, "Rendering").

## 0. Clarify

From the arguments, derive the class name (`UpperCamelCase` ending in `Scene`, e.g. `ApidexScene`), the file name (`apidex_scene.dart`) and the route name (`lowerCamelCase` without the suffix, e.g. `apidex`). Use the design vocabulary from `docs/DESIGN.md` — no competing synonyms. If the name or the purpose of the screen is unclear, ask before writing anything.

Read `docs/CONVENTIONS.md` ("Présentation Flame") and the reference files below before writing; copy their shape.

## 1. The scene — `lib/presentation/scenes/<name>_scene.dart`

Model it on `lib/presentation/scenes/board_scene.dart`:

- `class <Name>Scene extends Component` with `static const routeName = '<route>';`.
- Children built in `onLoad()` with `await add(...)`.
- Coordinates in reference-resolution pixels (`ApiaryGame.referenceResolution`, 240×480), integers only; layout sizes as named constants.
- Colours from `AppColors`, never `Color(0x…)`. No allocation in `update()`/`render()`.
- The scene displays and forwards input; it never decides game rules.
- Reusable pieces go to `lib/presentation/components/<notion>/`, not into the scene file.

## 2. The route — `lib/presentation/game/apiary_game.dart`

Add `<Name>Scene.routeName: Route(<Name>Scene.new),` to the `routes` map of the `RouterComponent`. Leave `initialRoute` alone unless the user asked for it. Wire the way in (e.g. a tap that calls `game.router.pushNamed(<Name>Scene.routeName)`) only if the user described it.

## 3. Translations — `assets/translations/fr.json` and `en.json`

Every player-facing string of the scene gets a key under a `<route>` object (`snake_case` keys, e.g. `apidex.title`), added to **both** files in the same change, French first (fallback locale). Check both files still have the same key set:

```bash
diff <(jq -c '[paths(scalars)]' assets/translations/fr.json) <(jq -c '[paths(scalars)]' assets/translations/en.json)
```

## 4. Tests

Mirror `lib/` (see `docs/TESTING.md`):

- **Navigation** — add a case to `test/presentation/game/apiary_game_test.dart` (copy its existing test): push the route, `await game.ready()`, assert `game.router.currentRoute.name == <Name>Scene.routeName`, then `pop()` returns to the previous scene.
- **Golden** — `test/presentation/scenes/<name>_scene_test.dart`, modelled on `board_scene_test.dart`: `testGameGolden('renders the <state>', goldenFile: 'goldens/<name>_scene_<state>.png', arrange: (game, tester) async { game.router.pushNamed(<Name>Scene.routeName); })`. One golden per meaningful visual state.
- Generate the golden on macOS with `fvm flutter test --update-goldens --tags golden test/presentation/scenes/<name>_scene_test.dart`, then **open the PNG** and describe to the user what it shows.

## 5. Check

```bash
fvm flutter analyze
fvm flutter test test/presentation/
```

Then run the `architecture-reviewer` subagent on the change. Report in French: the files created or modified, the route name, the translation keys added, and the test results. Don't commit.
