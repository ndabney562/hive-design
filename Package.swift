// swift-tools-version: 6.0
import PackageDescription

// The Hive apps' shared look (HiveMind, HiveScore, HiveTempo, HiveRounds): colour tokens from HiveMind's dashboard (integrations/ui/app.css),
// fonts, cards, buttons, line icons, the hexagon and the ☰ menu (shell, side menu, footer, button, app mark).
let package = Package(
    name: "HiveDesign",
    platforms: [.iOS("27.0"), .macOS("27.0")],
    products: [
        .library(name: "HiveDesign", targets: ["HiveDesign"]),
    ],
    targets: [
        .target(name: "HiveDesign", resources: [.process("Resources/Icons.xcassets")]),
        .testTarget(name: "HiveDesignTests", dependencies: ["HiveDesign"]),
    ]
)
