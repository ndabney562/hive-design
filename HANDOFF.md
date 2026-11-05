# Handoff: hive-design

- **Goal:** One Swift package with the Hive apps' look, used by HiveMind and HiveScore, so they can't drift apart. Colours come from HiveMind's `integrations/ui/app.css`.
- **Done:** 2026-11-04 package written from HiveMind's `Theme.swift` and HiveScore's `Shared/Theme.swift` (the same views plus HiveScore's highlight card and HMCardTitle), HiveMind's 19 line icons as a package asset catalog, `Hexagon`, `HiveMenuShell` (the ☰ overlay both apps wrote separately) and `HiveMenuRow`. `swift test` 4/4 (tokens complete, tokens equal app.css when a HiveMind clone is next door, hexagon, every icon name has an image set); iOS build succeeds.
- **In progress:** first push.
- **Next step (exact):** [Claude Code] Create the public repo, push, tag 1.0.0; then switch HiveScore (phase 2) in a branch: add the package, delete `Shared/Theme.swift`'s copies and HealthScoreKit's `ThemeTokens` + its test, keep app-only pieces (AppLogo, ScoreRing), compare UI-test screenshots. Then HiveMind (phase 3) in its own worktree (another session works in `~/AI.Stuff/HiveMind`).
- **Blockers:** none.
- **Last test result:** `swift test` 4/4 passed; iOS simulator build succeeded (2026-11-04).
- **Last commit hash:** see `git log -1`.
- **Model + timestamp:** Claude Code (Opus 5.5), 2026-11-04.
