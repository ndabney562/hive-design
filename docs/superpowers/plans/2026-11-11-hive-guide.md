# Hive guide ("How to use") Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** every Hive app gets a "How to use" row at the top of its ☰ menu (searchable "How do I…?" cards), a one-time "What's new" sheet after an update, and (HiveRounds, HiveBeat) a 3-card welcome on first launch.

**Architecture:** the data and rules (card model, loader, search, What's new and welcome choice, the coverage check) are Foundation-only and go in **hive-kit 1.8.0** (`Sources/HiveKit/Guide.swift`), so every app's Kit tests can run the coverage check on Linux CI. The views (guide sheet, menu row, launch sheet) go in **hive-design 1.7.0**, which gains a dependency on hive-kit. Each app ships a `Guide.json` and a `GuideScreen` list in its Kit.

**Tech Stack:** Swift 6, SwiftUI (iOS 27 / macOS 27), Swift Testing, SPM.

**Spec:** `docs/superpowers/specs/2026-11-11-hive-guide-design.md` (this repo). One change from the spec, for testing only: the model, loader and checks live in hive-kit, not hive-design, because the apps' Kit packages (which run on Linux CI) depend on hive-kit and cannot build SwiftUI. Noah's 3 decisions (place, content, opening) are unchanged.

## Global Constraints

- Row label exactly `How to use`, the **top** row of `HiveSideMenu`; shown only when the app has a valid guide.
- Card fields: `id`, `title`, `steps`, `screen`, `changed`, `welcome` (default `false`). Titles start `How do I`; 3-5 steps; ids unique.
- `changed` is a build number in the apps' format `YYYYMMDD.HHMM` (e.g. `20261111.0814`).
- Missing or broken `Guide.json` → no row, no sheet, never a crash.
- First launch stores the build and shows nothing, except opt-in welcome: cards with `welcome: true`, at most 3, once.
- What's new: only cards with `changed` newer than the last build seen, once.
- hive-design theme; check light, dark and the largest Dynamic Type on rendered screens.
- Out of scope: Ask box, videos/screenshots in cards, web help, Mac hub guide.
- Versions: hive-kit **1.8.0**, hive-design **1.7.0** (minor bumps, tags on main after merge).
- Every PR: PROJECT.md test command passes, `~/agent-rules/scripts/codex-review.sh --pr <n>`, HANDOFF.md updated in the branch, then merge (rule 7).

## Review Focus

1. **An app built before its Guide.json exists** (HiveMind Mac hub, or an app mid-rollout) → no row, no sheet. Test: `bundledMissingFileIsNil` (Task 1), and the menu with `guide: nil` in Task 2.
2. **A build number in another format** (`CFBundleVersion` = `1`, or empty) → nothing shown and nothing stored, no crash. Test: `unparseableBuildShowsNothing` (Task 1).
3. **Relaunch on the same build, or a downgrade** (TestFlight lets testers install older builds) → nothing shown again. Test: `sameOrOlderBuildShowsNothing` (Task 1).
4. **Search typed with capitals, accents or extra spaces** ("  How DO i  expórt") → still matches. Test: `searchIgnoresCaseAccentsAndSpaces` (Task 1).
5. **An update that changed many cards** (first rollout, a big release) → the sheet scrolls and its Done button stays reachable at the largest text size. Checked in each app's screen walk (Tasks 3-6), with a demo of 8 changed cards in Task 2's preview.

---

### Task 1: hive-kit 1.8.0 — guide model, loader, search, launch choice, coverage

**Files:**
- Create: `~/AI.Stuff/hive-kit/Sources/HiveKit/Guide.swift`
- Create: `~/AI.Stuff/hive-kit/Tests/HiveKitTests/GuideTests.swift`
- Modify: `README.md` (one section "Guide"), `HANDOFF.md`, `PROJECT.md` milestones

**Interfaces (Produces, all `public`, `Sendable`):**
- `struct GuideCard: Codable, Hashable, Identifiable { id: String; title: String; steps: [String]; screen: String; changed: String; welcome: Bool }` — `welcome` decodes as `false` when absent.
- `struct Guide: Hashable { cards: [GuideCard] }`
  - `static func load(_ data: Data?) -> Guide?` — JSON shape `{"cards": [...]}`; nil for nil data, bad JSON or zero cards.
  - `static func bundled(_ bundle: Bundle = .main) -> Guide?` — reads `Guide.json` from `bundle`.
  - `static let main: Guide?` — `bundled(.main)`, read once.
  - `func search(_ query: String) -> [GuideCard]` — trims; empty query → all cards; otherwise every word of the query must appear (case- and diacritic-insensitive) in the title or a step; file order kept.
- `enum BuildNumber { static func parse(_ s: String) -> (day: Int, time: Int)? }` — `YYYYMMDD.HHMM` only (8 digits, dot, 4 digits); compare as tuples.
- `enum GuideLaunch`
  - `static func cards(guide: Guide, build: String, lastSeen: String?, welcome: Bool) -> [GuideCard]` — pure rules below.
  - `static let key = "hive.guide.lastBuild"`
  - `static func take(guide: Guide?, build: String, defaults: UserDefaults, welcome: Bool) -> (cards: [GuideCard], isWelcome: Bool)` — calls `cards`, then stores `build` under `key` when `build` parses; returns `([], false)` when `guide` is nil (and still stores the build).
- `enum GuideCoverage { static func problems(_ guide: Guide, screens: [String]) -> [String] }` — one readable line per problem; `[]` means good.

Rules for `GuideLaunch.cards`:
- `build` unparseable → `[]`.
- `lastSeen == nil` (first launch) → `welcome ? first 3 cards with welcome == true : []`.
- `lastSeen` unparseable → treat as first launch.
- else cards with `lastSeen < changed <= build` (a card whose `changed` does not parse is skipped).

`GuideCoverage.problems` reports exactly these, in this order:
- `screen <id> has no card` for each listed screen without one;
- `card <id>: unknown screen <screen>`;
- `card <id>: <n> steps, needs 3-5`;
- `card <id>: title must start "How do I"`;
- `card <id>: changed "<x>" is not a build number`;
- `duplicate card id <id>`.

- [ ] **Step 1: Write the failing tests** in `GuideTests.swift` (Swift Testing, `@Suite struct GuideTests`), with a helper `card(_ id: String, screen: String = "home", changed: String = "20261111.0814", welcome: Bool = false, steps: Int = 3)`:
  - `loadsValidFile`: `{"cards":[{"id":"a","title":"How do I add a repo?","steps":["1","2","3"],"screen":"repos","changed":"20261111.0814"}]}` → 1 card, `welcome == false`.
  - `missingOrBrokenFileIsNil`: `load(nil)`, `load(Data("{".utf8))`, `load(Data(#"{"cards":[]}"#.utf8))` are all nil.
  - `bundledMissingFileIsNil`: `Guide.bundled(Bundle(path: NSTemporaryDirectory())!) == nil`.
  - `searchMatchesTitleAndSteps`: query `repo` finds a card whose step says "Tap Repos"; `banana` finds none; `""` returns all.
  - `searchIgnoresCaseAccentsAndSpaces`: card title "How do I export?"; `"  How DO i  expórt "` matches.
  - `firstLaunchShowsNothing`: `cards(guide, build: "20261111.0814", lastSeen: nil, welcome: false) == []`.
  - `welcomeOptInMaxThree`: 5 cards marked welcome, `welcome: true` → first 3 ids; `welcome: false` → `[]`; with lastSeen set → no welcome cards unless changed.
  - `newerBuildShowsOnlyChangedCards`: cards changed `20261101.0900`, `20261111.0814`, `20261120.1000`; `build: "20261111.0814", lastSeen: "20261105.0000"` → only the middle card.
  - `sameOrOlderBuildShowsNothing`: `lastSeen == build` → `[]`; `lastSeen` newer than `build` → `[]`.
  - `unparseableBuildShowsNothing`: `build: "1"` and `build: ""` → `[]`; `take(...)` with `build: "1"` leaves `defaults` unset.
  - `takeShowsOnce`: `UserDefaults(suiteName: "guide-test-\(UUID())")!`; first `take` (lastSeen nil) → `[]` and stores build; a second `take` with a newer build → the changed cards; a third `take` with the same build → `[]`.
  - `coverageFindsEachProblem`: screens `["home","repos"]`, cards: one on `home` with 2 steps, one titled "Add a repo" on `ghost`, two with id `x` → `problems` contains exactly the lines `screen repos has no card`, `card <id>: unknown screen ghost`, `card <id>: 2 steps, needs 3-5`, `card <id>: title must start "How do I"`, `duplicate card id x` (assert with `#expect(p.contains(...))` per line and `p.count == 5`).
  - `coverageCleanGuideHasNoProblems`.

- [ ] **Step 2: Run** `cd ~/AI.Stuff/hive-kit && swift test --filter GuideTests` — Expected: FAIL (`Guide` not defined).

- [ ] **Step 3: Implement** `Guide.swift` with the interfaces above. Normalise text for search with `folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)` and split on whitespace.

- [ ] **Step 4: Run** the full test command: `swift test && sh scripts/testflight.test.sh && sh scripts/asc_check.test.sh && sh scripts/asc_public_link.test.sh` — Expected: all pass, on the Mac. CI (`linux`) must also go green.

- [ ] **Step 5: Docs + PR.** README "Guide" section (JSON shape, `GuideCoverage` use in a Kit test); PROJECT.md milestone line; HANDOFF Done entry. Branch `feat/guide`, PR, `codex-review.sh --pr <n>`, merge, then on main `git tag 1.8.0 && git push origin 1.8.0`.

---

### Task 2: hive-design 1.7.0 — guide sheet, menu row, launch sheet

**Files:**
- Modify: `~/AI.Stuff/hive-design/Package.swift` — add `.package(url: "https://github.com/ndabney562/hive-kit", from: "1.8.0")`; target `HiveDesign` depends on product `HiveKit` (no re-export: apps import both).
- Create: `Sources/HiveDesign/GuideViews.swift` (inside `#if canImport(UIKit)`)
- Modify: `Sources/HiveDesign/SideMenu.swift`
- Test: `Tests/HiveDesignTests/HiveDesignTests.swift`
- Modify: `README.md`, `HANDOFF.md`, `PROJECT.md`

**Interfaces:**
- Consumes: Task 1 `Guide`, `GuideCard`, `GuideLaunch.take`.
- Produces (`public`):
  - `struct HiveGuideView: View { init(guide: Guide) }` — its own `NavigationStack`; title "How to use"; `.searchable` (prompt "Search how-tos", id `guideSearch`); list of card titles (id `guideCard-<id>`) pushing `HiveGuideCardView`; "Done" at top right dismisses; empty search shows "No how-to matches \"<query>\"".
  - `struct HiveGuideCardView: View { init(card: GuideCard) }` — title as header, steps numbered 1…n in `HMFont` body text, hive-design card background.
  - `struct HiveGuideOptions: Sendable { var welcome: Bool = false; init(welcome: Bool = false) }`
  - `extension View { func hiveGuideOnLaunch(_ guide: Guide? = .main, options: HiveGuideOptions = .init(), defaults: UserDefaults = .standard) -> some View }` — on first appear calls `GuideLaunch.take(guide:build:defaults:welcome:)` with `build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""`; if cards are returned, shows a sheet: title "Welcome" when `isWelcome`, else "What's new"; each card's title and steps; "Done" button (id `whatsNewDone`); scrolls.
  - `HiveSideMenu` gains `guide: Guide? = .main` as a new trailing-default init parameter on both inits; when non-nil, the first row is `HiveMenuRow("How to use", icon: "info")` (id `guideRow`) presenting `HiveGuideView` in a sheet; when nil, no row. Existing call sites compile unchanged.

- [ ] **Step 1: Failing test** `sideMenuHasGuideParameter`: builds `HiveSideMenu(name: "X", guide: nil) { EmptyView() }` and `HiveSideMenu(name: "X", guide: Guide.load(sample)) { EmptyView() }` (compile-level), and `HiveGuideOptions().welcome == false`. Run `swift test` — Expected: FAIL to compile.
- [ ] **Step 2: Implement** the views and the menu change. Use `HMIcon`, `HMFont`, `Color.hm(...)` and the existing card styles in `Components.swift`; no new colours. Add `#Preview`s: guide with 4 cards; launch sheet with 8 changed cards (Review Focus 5).
- [ ] **Step 3: Run** `swift test && xcodebuild -scheme HiveDesign -destination 'generic/platform=iOS Simulator' build` — Expected: pass.
- [ ] **Step 4: Render check.** Render the two previews on iPhone 18 Pro and iPhone 17e simulators in light, dark and AX5 text (a throwaway host app or Xcode preview snapshots); save `docs/screens/guide-*.png`. Fix clipping before the PR.
- [ ] **Step 5: PR.** README section, PROJECT milestone, HANDOFF; branch `feat/guide-views`, `codex-review.sh --pr <n>`, merge, `git tag 1.7.0 && git push origin 1.7.0`.

---

### Tasks 3-6: one PR per app

Same steps in each app; the table pins what differs.

| Task | App (repo) | Kit (tests) | Menu file | `GuideScreen` cases (raw value = id) | Welcome |
|---|---|---|---|---|---|
| 3 | HiveScore (`~/AI.Stuff/health-score`) | `HealthScoreKit` | `HealthScore/SideMenu.swift` | `score, nextSteps, repos, settings` | no |
| 4 | HiveTempo (`~/AI.Stuff/hive-tempo`) | `HiveTempoKit` | `HiveTempo/SideMenu.swift` | `today, task, settings` | no |
| 5 | HiveRounds (`~/Desktop/AI.Stuff/Apps.Games/HiveRounds`) | `HiveRoundsKit` | `HiveRounds/HiveRoundsApp.swift` | `home, search, ask, compose, week, digest, readingLog, style` | **yes** (3 cards: find a paper, write a post, your style) |
| 6 | HiveMind iPhone (`~/AI.Stuff/HiveMind/apps/ios`) | `HiveMindKit` | `HiveMind/SideMenu.swift` | `home, usage, gemini, you, network, settings` | no |

**Files (per app):**
- Create: `<Kit>/Sources/<Kit>/GuideScreen.swift` — `public enum GuideScreen: String, CaseIterable, Sendable`.
- Create: `<App>/Guide.json` in the app target folder (if the target is not a synchronized folder, add it to Copy Bundle Resources in the pbxproj).
- Create: `<Kit>/Tests/<Kit>Tests/GuideCoverageTests.swift`.
- Modify: the app's `Route` file — `extension Route { var guideScreen: GuideScreen }` with an exhaustive `switch` (no `default`), so a new page cannot ship without a screen id (HiveRounds: `topic` → `.search`, `composed` → `.compose`).
- Modify: root view — `.hiveGuideOnLaunch()` (HiveRounds: `.hiveGuideOnLaunch(options: .init(welcome: true))`).
- Modify: `Package.swift` of the Kit (hive-kit `from: "1.8.0"`), the app's pbxproj `minimumVersion` for hive-kit 1.8.0 and hive-design 1.7.0, and `Package.resolved`.
- Modify: UI smoke test (`SmokeTests.swift` / `HiveRoundsUITests.swift` / `HiveMindUITests`) — new test `testHowToUse`.
- Modify: `PROJECT.md` (milestone "How to use guide" ticked in the same commit), `HANDOFF.md`.

- [ ] **Step 1: Failing test** `GuideCoverageTests.guideCoversEveryScreen`: load the file by path, `URL(filePath: #filePath)` up to the repo root + `<App>/Guide.json`; `#expect(Guide.load(try? Data(contentsOf: url)) != nil)` and `#expect(GuideCoverage.problems(guide, screens: GuideScreen.allCases.map(\.rawValue)) == [])`. Run the Kit's `swift test` — Expected: FAIL (no `GuideScreen`, no file).
- [ ] **Step 2: Screenshot every screen** in the `GuideScreen` list on the simulator (current build) before writing cards; the cards describe what is on screen, never what the code suggests.
- [ ] **Step 3: Write `Guide.json`**: at least 1 card per screen, the tasks a new user would ask ("How do I see why my score dropped?"), 3-5 steps naming the real labels and buttons, `changed` = the commit's date-time as `YYYYMMDD.HHMM`. No patient or personal data in HiveRounds cards.
- [ ] **Step 4: Wire** `GuideScreen`, `Route.guideScreen`, `.hiveGuideOnLaunch`, package bumps. `HiveSideMenu` picks up `Guide.main` with no call-site change.
- [ ] **Step 5: UI test** `testHowToUse`: open menu (`openMenu`), tap `guideRow`, type one word into `guideSearch`, open the first `guideCard-*`, assert its first step text exists, screenshot `docs/screens/how-to-use.png`.
- [ ] **Step 6: Run** the app's PROJECT.md test command and the UI tests on iPhone 18 Pro; screen-walk the guide and the What's new sheet (launch with defaults key `hive.guide.lastBuild` set to an older build via launch argument `-hive.guide.lastBuild 20261101.0000`) in light, dark and largest text on iPhone 18 Pro and 17e. Expected: all pass, nothing clipped.
- [ ] **Step 7: PR** on branch `feat/how-to-use`; `codex-review.sh --pr <n>` (Codex also checks the cards match the screens); merge; pull main; delete branch. A TestFlight build is not part of this task.

HiveBeat is not a task here: its milestone 2 plan (Apps.Games/HiveBeat, Tasks 10-11) adds its `Guide.json`, `GuideScreen` and welcome cards the same way.

---

### Task 7: Close-out

- [ ] Merge the spec PR (hive-design #16) once this plan is committed on its branch (`gh pr ready 16 && gh pr merge 16 --squash`).
- [ ] HiveTempo task for Noah: "Read the How to use cards in each app (~5 min per app)" as a planner item tagged `[Noah, ~20 min]` after Tasks 3-6 ship in TestFlight.
- [ ] GLOBAL-TODO: tick the guide line; add "Ask box (HiveAI) after HiveBeat Task 2" as a later item.
