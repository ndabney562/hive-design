# Handoff: hive-design

- **Goal:** One Swift package with the Hive apps' look, used by HiveMind and HiveScore, so they can't drift apart. Colours come from HiveMind's `integrations/ui/app.css`.
- **Done:** 2026-11-04 public repo, CI green (macOS, free on a public repo), PR #1 merged, tag 1.0.0. HiveScore switched (health-score PR #20), HiveMind switched (hivemind PR #270, 6ffe928; its ThemeTokensTests check this package's tokens against app.css); before/after screenshots identical in both apps. 2026-11-04 package written from HiveMind's `Theme.swift` and HiveScore's `Shared/Theme.swift` (the same views plus HiveScore's highlight card and HMCardTitle), HiveMind's 19 line icons as a package asset catalog, `Hexagon`, `HiveMenuShell` (the ☰ overlay both apps wrote separately) and `HiveMenuRow`. `swift test` 4/4 (tokens complete, tokens equal app.css when a HiveMind clone is next door, hexagon, every icon name has an image set); iOS build succeeds.
- **In progress:** nothing.
- **Next step (exact):** none. When the look changes: app.css in HiveMind, then `ThemeTokens.swift` here, tag a new version, bump both apps (README › Change the look).
- **Blockers:** none.
- **Last test result:** `swift test` 4/4 passed; iOS simulator build succeeded (2026-11-04).
- **Last commit hash:** see `git log -1`.
- **Model + timestamp:** Claude Code (Opus 5.5), 2026-11-04.
