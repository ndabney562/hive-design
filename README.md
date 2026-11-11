# HiveDesign

The shared look of the Hive apps (HiveMind, HiveScore, HiveTempo, HiveRounds) as one Swift package, so they can't drift apart.

- **Colours:** `ThemeTokens` (light and dark) copied from HiveMind's dashboard CSS, `integrations/ui/app.css`, which stays the one source. HiveMind's `ThemeTokensTests` fail when its copy drifts; this package's test does the same when a HiveMind clone sits next to it.
- **Text (1.3.0, design review 2026-11-07):** nine roles in `HMTextRole` (page, heading, emphasis, body, support, label, caption, brand, metric); style text with `.hmText(.body)` (a token: `color: .warn`; a run-time colour: `tint:`). Set the colour there, not in a `.foregroundStyle` after it, which the role colour overrides. `HMFont` stays for older code.
- **SwiftUI (iOS):** `Color.hm(_:)`, `LinearGradient.hmAction` (main action, bright in both modes, `onGrad` text) / `.hmAccent`, `SecondaryButtonStyle`, `HMChip`, `HMStatus`, `HMSlideToConfirm` (slide to run; a button under VoiceOver and the largest text), `HMFont`, `HMCard(highlight:)`, `HMSection`, `HMCardTitle`, `HMRow`, `PrimaryButtonStyle`, `GhostButtonStyle`, `RoundButtonStyle`, `HMIcon` (the line icons, `IconNames.all`), `Hexagon`, and the ☰ menu: `HiveMenuShell`, `HiveMenuRow`, `HiveSideMenu` (mark, name, rows, footer), `HiveMenuFooter` (the 5 pt progress bar), `HiveMenuButton` (the round ☰ button) and `HiveAppMark` (the app's mark, or the hexagon until it has one). Shared logic (HTTP, GitHub, TestFlight) is in [hive-kit](https://github.com/ndabney562/hive-kit).

## Use it

Xcode › File › Add Package Dependencies… › `https://github.com/ndabney562/hive-design` › Up to Next Major from `1.0.0`, then `import HiveDesign`.

"How to use" guide (1.7.0, data from hive-kit 1.8.0): put `Guide.json` in the app target and the ☰ menu shows "How to use" as its top row by itself (`HiveSideMenu(guide:)` defaults to `Guide.main`). Add `.hiveGuideOnLaunch()` to the root view for a one-time "What's new" after an update; apps for other people pass `options: .init(welcome: true)` for a 3-card welcome on first launch. UI tests: `guideRow`, the sheet's search field, `guideCard-<id>`, `guideDone`, `whatsNewDone`; launch with `-hive.guide.lastBuild 20261101.0000` to see What's new.

## Change the look

1. Change the colour in HiveMind's `integrations/ui/app.css` first, then copy it into `Sources/HiveDesign/ThemeTokens.swift`.
2. `swift test` (macOS) and `xcodebuild -scheme HiveDesign -destination 'generic/platform=iOS Simulator' build`.
3. Tag a new version (`git tag 1.0.1 && git push --tags`) and update both apps' package version.
