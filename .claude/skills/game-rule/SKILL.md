---
name: game-rule
description: Implement a game rule from docs/DESIGN.md (merge, incubation/mutation, hive production and lifespan, energy, daily orders…) in lib/domain as pure Dart — freezed models, a pure function returning a result, and glados property tests. Use whenever gameplay logic is added or changed.
argument-hint: <rule, e.g. "fusion de deux larves">
---

Implement this game rule in Apiary's domain layer: $ARGUMENTS

The rules of the game live in `lib/domain/`, in pure Dart, deterministic by construction (`docs/CONVENTIONS.md`, "Principes" and "Domaine"). Everything else is plumbing around them — this skill does not touch Flame, Riverpod, Drift or Firebase.

## 1. Pin the rule down

- Find the rule in `docs/DESIGN.md` and quote the lines it comes from. Use its vocabulary exactly (`Larva`, `Bee`, `Hive`, `Incubator`, `Resource`, `Queen`, `Order`, `Day`, `Energy`, `Species`, `Family`, `Mutation`) — no competing synonyms.
- List every invariant the text implies, e.g. for incubation: only valid pairs are accepted, no failed attempt, two given parents always give the same species, the result is a bee.
- If DESIGN.md is silent or ambiguous on something the code must decide (a number, an edge case, an ordering), **stop and ask** rather than inventing it. Once answered, propose the matching line for DESIGN.md.
- Look at what already exists in `lib/domain/` and reuse its models: don't duplicate a type.

## 2. Models — `lib/domain/<notion>/`

- `freezed` values; families of objects as a `sealed` union, consumed by exhaustive `switch` (see the `BoardItem` example in CONVENTIONS.md).
- Fixed catalogues (species, families, mutation recipes, resource types) are **data**: one table that is the single source of truth, not `if`s scattered in code.
- Invariants checked at construction (`assert` in a private constructor, or a factory that refuses invalid values).
- Balancing values (energy cost, lifespan, max energy, incubation time) are named constants grouped in one balancing class (`const X._()` + `static const`), so they can move to remote config later (`docs/STACK.md`).
- Allowed imports only: Dart SDK, `freezed_annotation`, `clock`, `meta`, `collection`.

## 3. Logic

- A pure function or class: state in, new state or result out. No I/O, no mutation of its input.
- Time via `clock.now()`, randomness via an injected `Random` — never `DateTime.now()` or `Random()`.
- Expected game outcomes ("these don't merge", "not a mutation", "not enough energy") are return values (`null` when absence is enough, otherwise a sealed result union), never exceptions.
- If the rule needs persistence, declare the repository **interface** here (`abstract interface class XRepository`); the implementation belongs to `data/` and is out of scope.

Run `fvm dart run build_runner build --delete-conflicting-outputs` after adding `@freezed` files (the Stop hook also does it).

## 4. Tests — `test/domain/<notion>/<file>_test.dart`

- Import `package:glados/glados.dart` **alone**.
- One property per invariant from step 1 (`Glados`, `Glados2`…; `ExploreConfig(numRuns: 500)` for critical rules). Generators as `extension … on Any`, moved to `test/helpers/generators.dart` once reused.
- Plain tests next to them for the examples given in DESIGN.md (e.g. "Commune + Rocheuse = Cristal") and the edge cases (max tier, empty lifespan, energy at 0 and at max).
- `withClock(Clock.fixed(...))` for anything time-based.

## 5. Check

```bash
fvm flutter analyze
fvm flutter test test/domain/
```

Then run the `architecture-reviewer` subagent on the change. Report in French: the rule implemented (with the DESIGN.md lines), the models and functions created, the properties tested, and any open design question raised along the way. Don't commit.
