# Project: hive-design

The Hive apps' shared look as a Swift package (Noah, 2026-11-04: "standardize the aesthetics of the Hive apps"; chose a public repo, with HiveMind's `integrations/ui/app.css` as the one colour source).

- **Hive family:** one connected system with the other Hive apps (global rule "Hive family" in `~/agent-rules/AGENTS.md`).
- **Repo URL:** https://github.com/ndabney562/hive-design (public)
- **Branch:** main
- **Test command:** `swift test && ~/agent-rules/scripts/heavy-guard hive-design-ui -- xcodebuild -scheme HiveDesign -destination 'generic/platform=iOS Simulator' build` (from the repo root) The xcodebuild part runs through agent-rules `heavy-guard` (one heavy job on the Mac at a time, waits out load spikes, never skips; 2026-11-13).
- **Stack:** Swift 6 package, SwiftUI and UIKit (iOS 27); tokens and `Hexagon` also build on macOS for `swift test`.

## Milestones
- [x] Package with tokens, fonts, cards, buttons, icons, hexagon and the ☰ menu shell; tests pass
- [x] Public repo with CI and tag 1.0.0
- [x] HiveScore uses the package (its own copies removed)
- [x] HiveMind uses the package (its own copies removed; its app.css drift test kept)
- [x] Both apps' screenshots match the ones before the switch
- [x] 1.3.0: design review roles, colours and components (text roles, secondary button, chip, status, slide to confirm)
- [x] Every Hive app on the 1.3.0 look (HiveRounds, HiveScore with the Optimize slider, HiveTempo, HiveMind), screenshots before and after
- [x] 1.7.0: "How to use" guide views (guide sheet with search, card steps, What's new / welcome sheet, top ☰ row)
- [ ] Every Hive app ships its How to use cards (HiveScore, HiveTempo, HiveRounds, HiveMind; HiveBeat in its milestone 2)
