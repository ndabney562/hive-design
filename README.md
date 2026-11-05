# HiveDesign

The shared look of the Hive apps (HiveMind and HiveScore) as one Swift package, so they can't drift apart.

- **Colours:** `ThemeTokens` (light and dark) copied from HiveMind's dashboard CSS, `integrations/ui/app.css`, which stays the one source. HiveMind's `ThemeTokensTests` fail when its copy drifts; this package's test does the same when a HiveMind clone sits next to it.
- **SwiftUI (iOS):** `Color.hm(_:)`, `LinearGradient.hmAccent` / `.hmHighlight`, `HMFont`, `HMCard(highlight:)`, `HMSection`, `HMCardTitle`, `HMRow`, `PrimaryButtonStyle`, `GhostButtonStyle`, `RoundButtonStyle`, `HMIcon` (the line icons, `IconNames.all`), `Hexagon`, and the ☰ menu: `HiveMenuShell` and `HiveMenuRow`.

## Use it

Xcode › File › Add Package Dependencies… › `https://github.com/ndabney562/hive-design` › Up to Next Major from `1.0.0`, then `import HiveDesign`.

## Change the look

1. Change the colour in HiveMind's `integrations/ui/app.css` first, then copy it into `Sources/HiveDesign/ThemeTokens.swift`.
2. `swift test` (macOS) and `xcodebuild -scheme HiveDesign -destination 'generic/platform=iOS Simulator' build`.
3. Tag a new version (`git tag 1.0.1 && git push --tags`) and update both apps' package version.
