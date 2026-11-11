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
    dependencies: [
        // The "How to use" guide's data and rules (Guide, GuideLaunch); its views live here.
        .package(url: "https://github.com/ndabney562/hive-kit", from: "1.8.0"),
    ],
    targets: [
        .target(name: "HiveDesign", dependencies: [.product(name: "HiveKit", package: "hive-kit")],
                resources: [.process("Resources/Icons.xcassets")]),
        .testTarget(name: "HiveDesignTests", dependencies: ["HiveDesign", .product(name: "HiveKit", package: "hive-kit")]),
    ]
)
