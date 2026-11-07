# HiveDesign

The shared look of the Hive apps (HiveMind, HiveScore, HiveTempo, HiveRounds) as one Swift package, so they can't drift apart.

- **Colours:** `ThemeTokens` (light and dark) copied from HiveMind's dashboard CSS, `integrations/ui/app.css`, which stays the one source. HiveMind's `ThemeTokensTests` fail when its copy drifts; this package's test does the same when a HiveMind clone sits next to it.
- **SwiftUI (iOS):** `Color.hm(_:)`, `LinearGradient.hmAccent` / `.hmHighlight`, `HMFont`, `HMCard(highlight:)`, `HMSection`, `HMCardTitle`, `HMRow`, `PrimaryButtonStyle`, `GhostButtonStyle`, `RoundButtonStyle`, `HMIcon` (the line icons, `IconNames.all`), `Hexagon`, and the ☰ menu: `HiveMenuShell`, `HiveMenuRow`, `HiveSideMenu` (mark, name, rows, footer), `HiveMenuFooter` (the 5 pt progress bar), `HiveMenuButton` (the round ☰ button) and `HiveAppMark` (the app's mark, or the hexagon until it has one). Shared logic (HTTP, GitHub, TestFlight) is in [hive-kit](https://github.com/ndabney562/hive-kit).

## Use it

Xcode › File › Add Package Dependencies… › `https://github.com/ndabney562/hive-design` › Up to Next Major from `1.0.0`, then `import HiveDesign`.

## Change the look

1. Change the colour in HiveMind's `integrations/ui/app.css` first, then copy it into `Sources/HiveDesign/ThemeTokens.swift`.
2. `swift test` (macOS) and `xcodebuild -scheme HiveDesign -destination 'generic/platform=iOS Simulator' build`.
3. Tag a new version (`git tag 1.0.1 && git push --tags`) and update both apps' package version.
