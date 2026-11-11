# Hive guide ("How to use") design

Date: 2026-11-11. Agreed with Noah in chat (answers 1, 4, 4, then "yes" to the design). Status: approved; next is the implementation plan.

## What it is

Every Hive app (HiveMind, HiveScore, HiveTempo, HiveRounds, HiveBeat and every future one) gets a "How to use" guide, built once in hive-design.

## Decisions

1. **Place (answer 1):** a "How to use" row at the top of the ☰ side menu, not a tab. Tab bars stay free (iPhone shows 5 tabs before "More"; HiveBeat already has 5).
2. **Content (answer 4):** "How do I…?" cards now; an "Ask" box later.
3. **Opening by itself (answer 4):** "What's new" once after an update in every app; a 3-card welcome on first launch only in apps meant for other people (HiveRounds, HiveBeat).

## Parts

### hive-design 1.7.0
- `GuideCard` (Codable): `id`, `title` ("How do I …?"), `steps` (3-5 strings), `screen` (screen id), `changed` (build number, e.g. `20261111.0814`), `welcome` (Bool, default false).
- `Guide` loader: reads `Guide.json` from the app bundle; a missing or broken file means no guide row (never a crash).
- `HiveGuideView`: search field (matches title and steps), card list, card detail with numbered steps. hive-design theme, light, dark, largest Dynamic Type.
- `HiveSideMenu`: shows "How to use" as the top row when the app has a guide.
- `WhatsNew`: on launch, cards with `changed` newer than the last build the user saw show once in a sheet; then the stored build updates. First launch of an app stores the build without showing anything (except the welcome below).
- Welcome: on first launch, if the app opts in (`HiveGuideOptions(welcome: true)`), show the cards marked `welcome` (at most 3) once.

### Each app
- `Guide.json` in the app target, cards written by Claude from the real screens; Noah reads them in the app (~5 min per app).
- Screen ids: each top-level screen sets an id the tests can list.

## Tests
- hive-design: loader (valid, missing, broken file), search, What's new (first launch shows nothing; newer build shows only changed cards, once), welcome (opt-in only, max 3).
- Shared check `GuideCoverage`, run in each app's tests: every listed screen id has at least 1 card; every card has 3-5 steps; titles start "How do I"; ids unique.
- Codex review checks that cards match the screens they describe (a test cannot judge that).

## Rollout
1. hive-design PR, tag 1.7.0.
2. One PR per app: HiveMind iPhone, HiveScore, HiveTempo, HiveRounds. HiveBeat adds its cards in its milestone 2 PR.
3. Later: "Ask" box answering only from that app's cards, with hive-kit `HiveAI` (lands in HiveBeat plan Task 2).

## Out of scope
Videos or screenshots in cards (they go stale), web help pages, a guide for the Mac hub.
