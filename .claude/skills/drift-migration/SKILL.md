---
name: drift-migration
description: Change Apiary's local Drift schema safely — export the current schema, edit tables, bump schemaVersion, write the step-by-step migration and its generated tests. Use for any change to a drift table or to AppDatabase (new table, new or changed column, index).
disable-model-invocation: true
argument-hint: <schema change to make>
---

Apply this schema change to `AppDatabase` (`lib/data/local/app_database.dart`): $ARGUMENTS

A failed migration wipes a player's progress: per `docs/CONVENTIONS.md` ("Données"), every schema change bumps `schemaVersion` and ships with a migration **and** its test. Follow the steps in order; the export in step 2 has to happen **before** any table is edited.

## 1. One-time setup (skip if `build.yaml` already declares the database)

`drift_dev make-migrations` needs the database declared in `build.yaml` at the project root. Create or extend it:

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/data/local/app_database.dart
          schema_dir: drift_schemas/
          test_dir: test/data/local/migrations/
```

`test_dir` follows the rule that `test/` mirrors `lib/`. Mention to the user that `build.yaml` and `drift_schemas/` are new and must be committed.

## 2. Export the current schema

With the tables still unchanged:

```bash
fvm dart run drift_dev make-migrations
```

This writes `drift_schemas/app_database/drift_schema_v<current>.json`. If it already exists and matches, nothing changes — that's fine.

## 3. Make the change

- Tables go next to the database in `lib/data/local/` (one table per file, `snake_case` names), registered in `@DriftDatabase(tables: [...])`.
- Increment `schemaVersion` by exactly 1.
- Drift row types never leave `data/`: if a domain model is involved, the repository converts between them.

**Exception:** if no build of the app has ever been released with the current schema, the user may prefer to edit version 1 in place instead of adding a migration. Ask before doing that — never assume it.

## 4. Generate the migration helpers

```bash
fvm dart run build_runner build --delete-conflicting-outputs
fvm dart run drift_dev make-migrations
```

This exports the new schema, generates `lib/data/local/app_database.steps.dart` and test scaffolding in `test/data/local/migrations/`.

## 5. Write the migration

In `AppDatabase`, use the generated step-by-step helper:

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: stepByStep(
    from1To2: (m, schema) async {
      await m.createTable(schema.hives);
    },
  ),
);
```

- Keep each step minimal and use the `schema` argument (the versioned schema), never the current table classes, inside a step.
- Data transformations (renamed column, split table) copy the data explicitly; a column that becomes non-null gets a default for existing rows.
- Log failures through `talker`, never `print`.

## 6. Test it

- Complete the generated tests in `test/data/local/migrations/`: the schema-validation test for every `from → to` pair, and a **data integrity** test for this step that inserts realistic rows at the old version, migrates, and checks they are still there and correct.
- Run them: `fvm flutter test test/data/local/`.
- Keep `test/data/local/app_database_test.dart` in sync (`schemaVersion` expectation).

## 7. Check

```bash
fvm flutter analyze
fvm flutter test test/data/
```

Report in French: the schema change, the version bump (`vN → vN+1`), the files created (schemas, steps, tests), and the test results. Don't commit.
