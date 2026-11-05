# Project: hive-design

The Hive apps' shared look as a Swift package (Noah, 2026-11-04: "standardize the aesthetics of the Hive apps"; chose a public repo, with HiveMind's `integrations/ui/app.css` as the one colour source).

- **Repo URL:** https://github.com/ndabney562/hive-design (public)
- **Branch:** main
- **Test command:** `swift test && xcodebuild -scheme HiveDesign -destination 'generic/platform=iOS Simulator' build` (from the repo root)
- **Stack:** Swift 6 package, SwiftUI and UIKit (iOS 27); tokens and `Hexagon` also build on macOS for `swift test`.

## Milestones
- [x] Package with tokens, fonts, cards, buttons, icons, hexagon and the ☰ menu shell; tests pass
- [x] Public repo with CI and tag 1.0.0
- [x] HiveScore uses the package (its own copies removed)
- [x] HiveMind uses the package (its own copies removed; its app.css drift test kept)
- [x] Both apps' screenshots match the ones before the switch
