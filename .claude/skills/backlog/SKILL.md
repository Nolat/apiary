---
name: backlog
description: Create and maintain Apiary's prioritized product backlog in Linear (team Apiary, key APY) — user stories as issues grouped by epic (one Linear project per epic). Initialise it, frame new stories one at a time with the user, mark them done, reprioritise. Use when the user talks about the backlog, user stories, priorities or "what's next", and to close a story once the work it describes is finished.
argument-hint: "[init | add <besoin> | done <APY-N> | prioritize | <question>]"
---

Manage Apiary's product backlog in **Linear**. Request: $ARGUMENTS

The backlog is documentation, so it is written in **French** (`docs/CONVENTIONS.md`, "Langues"). It is built **user story by user story, in a framing session with the user**: never generate a batch of stories on your own, frame one, have it validated, then move to the next.

## Where it lives

- Linear workspace **Nolat**, team **Apiary** (key `APY`). Access goes through the Linear MCP tools (`list_projects`, `list_issues`, `get_issue`, `save_issue`, `save_project`, `get_document`, `save_document`, `save_comment`…). Their prefix depends on how Linear is connected (`.mcp.json` server `linear` or an app connector): find them with `ToolSearch` ("linear issue") rather than guessing a name. If no Linear tool is available, say so and tell the user to authenticate (`/mcp` → `linear` in an interactive `claude` terminal) — don't fall back to a markdown file.
- **Epic = Linear project** of team APY, named `<rang>. <Nom de l'épopée>` (e.g. `1. Plateau et fusion`); the numeric prefix is the epic's priority. Its `summary` holds the framing sentence (what it covers, what stays out, reference prototype if any).
- **Story = Linear issue** of team APY, in its epic's project, label `Feature`, status `Backlog` (or `Todo` for the next ones to build). Its identifier (`APY-N`) is assigned by Linear and permanent — use it in links and commits, never renumber or recreate an issue to change its ID.
- **"À définir avant de poursuivre le backlog"**: a team document of APY with that title. It lists the design decisions and numeric values that block upcoming stories, and ends with a "Prochaine story à cadrer" section.
- Writing to Linear publishes to the user's workspace: only create or edit what the user validated in this framing session (the validated story, its links, the "À définir" update). Anything else — deleting, archiving, editing other stories — needs an explicit go-ahead.

## Story format

Title: `<Titre à l'infinitif>` (no `US-NNN`, the Linear ID replaces it). Description, in Markdown:

```markdown
**En tant que** joueuse ou joueur,
**je veux** <action ou information, du point de vue du joueur>,
**afin de** <bénéfice pour le joueur>.

## Contexte

- Ce que la story couvre **et ce qu'elle ne couvre pas**, avec la story qui traite le reste (APY-5).
- Hypothèses sur l'état du jeu (« On suppose qu'au moins une larve est déjà sur le plateau »).
- Valeurs encore ouvertes : « … reste à définir (voir [DESIGN.md § Section](https://github.com/Nolat/apiary/blob/main/docs/DESIGN.md#section)) ; cette story couvre le mécanisme, pas ces valeurs. »
- Source : [DESIGN.md § Section](https://github.com/Nolat/apiary/blob/main/docs/DESIGN.md#section) (et le code de référence s'il existe).

## Critères d'acceptation

- Étant donné <état>, quand <action du joueur>, alors <résultat observable>.
- <Règle invariante, ex. « L'énergie ne dépasse jamais son plafond. »>

## Assets

- <Sprite, bouton, police… que la story introduit, avec sa taille en pixels de jeu (ex. « Larve de la famille Commune, 16×16 »)>
  (ou « - Aucun. »)

## Dépendances

- APY-X — pourquoi elle est nécessaire.
  (ou « - Aucune. »)
```

### Writing rules

- **Epics** group stories by game system (plateau et fusion, ruches et ressources, commandes, fin de journée, énergie, incubateur et mutations, Apidex, sauvegarde…). Epic order = the projects' numeric prefix.
- **Order inside an epic**: Linear's manual order, which the MCP can't set. Express priority through dependencies (`blockedBy`) and the "Prochaine story à cadrer" line; when the order matters beyond that, tell the user which issue to drag where in the project view.
- **One thin, player-visible slice per story**: one behaviour, testable on its own. The first story of a system is often "just display it, empty"; interactions, edge cases, monetisation, haptics come as separate stories that extend it. When a story grows past ~5 criteria or mixes two behaviours, split it.
- **Rules are written generically**: describe a behaviour for any family, species or level ("une larve de l'espèce de base de la famille du générateur", "deux abeilles de la même espèce"), not for the one example at hand. Name a specific family or species only when it is a content decision (e.g. "au départ, un seul générateur, de la famille Commune") or as an explicit example. Say what "identical" means when a rule depends on it.
- **Contexte always states the scope boundary** — what is deliberately left out and which story (existing or to come) handles it — and when a story extends or overrides a simplification made by an earlier one ("Étend APY-5, qui supposait…").
- **Acceptance criteria** are observable from the player's side, in "Étant donné / quand / alors" form or as invariant rules, with concrete values when DESIGN.md has them (e.g. plateau 8×9, 72 cases). No implementation details (classes, providers, components) — those belong to the code.
- **Unknown values don't block a story**: cover the mechanism, say the value is "à définir", link DESIGN.md, and add the point to the "À définir" document.
- **Assets** list only the art the story is the first to need — sprites (with their size in game pixels; every sprite is also supplied at ×2), button states (normal / pressed), 9-slice panels, fonts — not art an earlier story already brought. Only the families, species or levels the story actually shows (e.g. the Commune generator, not one per family). Undecided art (form, count of levels) is noted as "à définir", like any other open value.
- **Dependencies** list only the stories strictly required, each with a short reason, and are also set as `blockedBy` relations on the issue.
- **Links**: other stories by their bare identifier (`APY-5`, Linear links it); DESIGN.md and other repo docs by their GitHub URL on `main` (`https://github.com/Nolat/apiary/blob/main/docs/DESIGN.md#anchor`). Anchors: lowercase, punctuation removed (apostrophes, guillemets, em dash, `:`, `«»`), each space becomes `-`, accents kept — check each one against the actual heading.
- The player is "joueuse ou joueur" in the story statement, "le joueur" in criteria.
- The backlog holds player-facing stories. Technical work (persistence, Firebase sync, analytics, ads/RevenueCat) is not a story of its own: mention it in the Contexte of the story that first needs it, or as a story phrased from the player's side when it has visible behaviour (e.g. "Retrouver sa partie après réinstallation").

## Actions

**`init`** (or team APY has no projects): read DESIGN.md (all sections, including "À trancher", "Risque connu", "Chantiers à part") and the code (what is already implemented). Propose to the user a list of epics in priority order, core loop first (plateau → fusion larves/abeilles → ruches/ressources → commandes → fin de journée → énergie → incubateur/mutations → Apidex), and get it validated. Create one project per epic (numeric prefix, framing sentence in `summary`) and the "À définir" document filled from DESIGN.md's open questions. Then frame the first story as with `add`.

**`add <besoin>`** — frame one story:
1. Locate the need in DESIGN.md (grep the section, don't read the whole file) and in the existing issues of its epic only (which epic, what it extends, what it depends on) — see "Token economy". If it is really two behaviours, propose the split.
2. Ask the user the questions the docs don't answer (exact behaviour, edge cases, values, scope boundary) — with `AskUserQuestion` when there are clear options. Don't invent game rules: anything undecided becomes "à définir".
3. Show the drafted story in full, adjust it with the user, then create the issue in its epic's project, with its `blockedBy` relations, without re-printing the story afterwards. Update the stories it extends (a mention in their Contexte, e.g. "précisée par APY-N") and the "À définir" document only when something actually changed there.
4. Say where it went and why (with the issue's URL), and suggest the next story to frame (update the "Prochaine story à cadrer" section).

**`done <APY-N>`**: check the work is really there (code, tests covering the acceptance criteria) before closing it. Then set the issue's status to `Done` and add a comment listing what covers each criterion. If only some criteria are met, say which, and propose splitting off the remainder as a new story instead of closing it.

**`prioritize`**: re-read DESIGN.md, the backlog and the code, propose a new order (of epics, and of stories within an epic) with a one-line reason per move, and apply it after the user agrees: rename projects to change their prefix, adjust `blockedBy` relations, and tell the user which issues to drag in the Linear view. Moving stories never changes their IDs; check that no story now comes before one it depends on.

**A question** ("qu'est-ce qui vient ensuite ?"): answer from Linear — the first story of the highest-priority epic that is not done and whose dependencies are all done; don't edit anything unless asked.

## Token economy

The Linear tools return full issue descriptions and every call re-sends the whole conversation, so keep reads and writes small:

- **Never list the whole team.** `list_issues` always with `project` (the epic), a small `limit` (≤ 15) and no description needed when only titles/IDs matter; `get_issue` only for the few stories actually extended or depended on. `list_projects` once per session, reuse the result.
- **Read DESIGN.md by section** (grep the heading, read that range), except for `init`.
- **Fetch the "À définir" document once per session**, and when updating it, do it once at the end of a batch of stories, not after each one.
- **Don't re-display** a story already shown and validated: create it, then report only the identifier and URL.
- **Batch**: when the user validates several stories in a session, create them back to back; one `save_comment` or one Contexte edit per extended story, not several.
- **Keep sessions short**: after about 3–4 stories, or when changing epic, suggest the user run `/clear` (the state lives in Linear, the next session rebuilds it from the epic's issues). This skill needs no memory of earlier stories.
- The skill needs no big model: suggest `/model sonnet` for backlog sessions.

Never commit; end with a summary in French of what changed in Linear, with the URLs of the issues, projects or documents touched.
