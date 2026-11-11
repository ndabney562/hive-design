import Foundation
import SwiftUI
import Testing
@testable import HiveDesign
import HiveKit

struct ThemeTokensTests {
    @Test func bothSchemesAreComplete() {
        #expect(Set(ThemeTokens.light.keys) == Set(ThemeToken.allCases))
        #expect(Set(ThemeTokens.dark.keys) == Set(ThemeToken.allCases))
    }

    /// HiveMind's dashboard CSS is the one source of the colours. Its own ThemeTokensTests guard HiveMind's copy;
    /// this guards ours whenever a HiveMind clone sits next to this one (skipped in CI, which has none).
    @Test func matchesHiveMindAppCSSWhenPresent() throws {
        let here = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let css = here.deletingLastPathComponent().appendingPathComponent("HiveMind/integrations/ui/app.css")
        guard let text = try? String(contentsOf: css, encoding: .utf8) else { return }
        let tokens = CSSTokens.parse(text)
        for t in ThemeToken.allCases {
            #expect(ThemeTokens.light[t] == tokens.light[t.rawValue], "light \(t.rawValue)")
            #expect(ThemeTokens.dark[t] == tokens.dark[t.rawValue], "dark \(t.rawValue)")
        }
    }
}

/// `--name: #rrggbb` pairs from app.css's first `:root { }` (light) and the `:root { }` in the dark media query.
enum CSSTokens {
    static func parse(_ css: String) -> (light: [String: UInt32], dark: [String: UInt32]) {
        func block(after marker: String, in text: Substring) -> Substring {
            let start = text.range(of: marker)!.upperBound
            let open = text[start...].firstIndex(of: "{")!
            let close = text[open...].firstIndex(of: "}")!
            return text[text.index(after: open)..<close]
        }
        func pairs(_ s: Substring) -> [String: UInt32] {
            var out: [String: UInt32] = [:]
            for m in s.matches(of: /--([a-z0-9-]+):\s*#([0-9a-fA-F]{6})/) { out[String(m.1)] = UInt32(m.2, radix: 16)! }
            return out
        }
        let all = Substring(css)
        let dark = all[all.range(of: "@media (prefers-color-scheme: dark)")!.upperBound...]
        return (pairs(block(after: ":root", in: all)), pairs(block(after: ":root", in: dark)))
    }
}

struct HexagonTests {
    @Test func sixCornersInsideItsFrame() {
        let r = CGRect(x: 0, y: 0, width: 20, height: 17.3)
        let box = Hexagon().path(in: r).boundingRect
        #expect(abs(box.width - 20) < 0.01 && abs(box.height - 17.3) < 0.01)
        #expect(Hexagon().path(in: r).contains(CGPoint(x: 10, y: 8.65)))
        #expect(!Hexagon().path(in: r).contains(CGPoint(x: 0.5, y: 0.5)), "corners are cut")
    }
}

struct IconTests {
    /// Every name HMIcon lists has an image set in the package's catalog.
    @Test func everyIconIsInTheCatalog() throws {
        let catalog = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/HiveDesign/Resources/Icons.xcassets")
        let sets = Set(try FileManager.default.contentsOfDirectory(atPath: catalog.path).filter { $0.hasSuffix(".imageset") })
        #expect(sets == Set(IconNames.all.map { "i-\($0).imageset" }))
    }
}

struct TextRoleTests {
    /// The design review's scale: nine roles, a 17 pt reading baseline, nothing under 13 pt, no two roles alike.
    @Test func nineDistinctRolesFromThirteenUp() {
        #expect(HMTextRole.allCases.count == 9)
        #expect(HMTextRole.body.spec.size == 17)
        #expect(HMTextRole.allCases.allSatisfy { $0.spec.size >= 13 && $0.spec.lineHeight > $0.spec.size })
        let shapes = HMTextRole.allCases.map { "\($0.spec.size)-\($0.spec.weight)-\($0.spec.rounded)-\($0.spec.color)" }
        #expect(Set(shapes).count == shapes.count)
    }

    /// Rounded only for the brand, the page title and the hero number.
    @Test func roundedOnlyForDisplay() {
        #expect(Set(HMTextRole.allCases.filter { $0.spec.rounded }) == [.page, .brand, .metric])
    }
}

struct ContrastTests {
    static func luminance(_ hex: UInt32) -> Double {
        func ch(_ v: UInt32) -> Double { let c = Double(v) / 255; return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4) }
        return 0.2126 * ch(hex >> 16 & 0xFF) + 0.7152 * ch(hex >> 8 & 0xFF) + 0.0722 * ch(hex & 0xFF)
    }
    static func ratio(_ a: UInt32, _ b: UInt32) -> Double {
        let (x, y) = (luminance(a), luminance(b))
        return (max(x, y) + 0.05) / (min(x, y) + 0.05)
    }

    /// Every text colour is at least 4.5:1 on bg, panel and raise; the control outline (edge) at least 3:1.
    @Test(arguments: [ThemeTokens.light, ThemeTokens.dark])
    func textAndOutlinesPass(_ t: [ThemeToken: UInt32]) {
        for surface in [ThemeToken.bg, .panel, .raise] {
            for text in [ThemeToken.ink, .muted, .faint, .accent, .good, .bad, .warn] {
                #expect(Self.ratio(t[text]!, t[surface]!) >= 4.5, "\(text) on \(surface)")
            }
            #expect(Self.ratio(t[.edge]!, t[surface]!) >= 3, "edge on \(surface)")
        }
        #expect(Self.ratio(t[.onGrad]!, t[.gradA]!) >= 4.5 && Self.ratio(t[.onGrad]!, t[.gradB]!) >= 4.5)
    }
}

struct SlideToConfirmTests {
    @Test func runLeavesRoomForTheThumb() {
        #expect(SlideToConfirm.run(trackWidth: 362, thumb: 48, inset: 4) == 306)
        #expect(SlideToConfirm.run(trackWidth: 40, thumb: 48, inset: 4) == 0)
    }

    @Test func firesOnlyNearTheEnd() {
        #expect(SlideToConfirm.progress(translation: -20, run: 300) == 0)
        #expect(SlideToConfirm.progress(translation: 900, run: 300) == 1)
        #expect(SlideToConfirm.progress(translation: 10, run: 0) == 0)
        #expect(!SlideToConfirm.fires(progress: SlideToConfirm.progress(translation: 240, run: 300)))
        #expect(SlideToConfirm.fires(progress: SlideToConfirm.progress(translation: 260, run: 300)))
    }
}

struct HiveAppLinkTests {
    @Test func readsNameStatusAndWhatATapDoes() {
        let l = HiveAppLink(name: "HiveScore", status: "99 · Good", url: URL(string: "hivescore://")!)
        #expect(l.accessibilityLabel == "HiveScore, 99, Good")
        #expect(l.accessibilityHint == "Opens HiveScore")
        #expect(l.shown(missing: false) == "99 · Good")
        #expect(l.shown(missing: true) == "Not on this iPhone")
        // HiveMind's phone has no feed access yet: the row is just the name.
        #expect(HiveAppLink(name: "HiveTempo", status: "", url: URL(string: "hivetempo://")!).accessibilityLabel == "HiveTempo")
    }
}

#if canImport(UIKit)
struct PressStyleTests {
    /// HMPressStyle is public and builds a row (HiveTempo's Next card and timeline rows use it).
    @MainActor @Test func pressStyleWrapsARow() {
        let row = Button {} label: { Text("Next") }.buttonStyle(HMPressStyle())
        _ = row.body
    }
}
#endif

#if canImport(UIKit)
struct GuideViewsTests {
    static let sample = Data(#"{"cards":[{"id":"a","title":"How do I add a repo?","steps":["Open the menu","Tap Repos","Tap Add"],"screen":"repos","changed":"20261111.0814","welcome":true}]}"#.utf8)

    /// The ☰ menu takes the app's guide: none means no "How to use" row; older call sites still compile.
    @MainActor @Test func sideMenuHasGuideParameter() throws {
        let guide = try #require(Guide.load(Self.sample))
        _ = HiveSideMenu(name: "X", guide: nil) { EmptyView() }
        _ = HiveSideMenu(name: "X", guide: guide) { EmptyView() }
        _ = HiveSideMenu(name: "X") { EmptyView() }
        _ = HiveGuideView(guide: guide)
        _ = HiveGuideCardView(card: guide.cards[0])
        #expect(HiveGuideOptions().welcome == false)
        #expect(HiveGuideOptions(welcome: true).welcome)
    }
}
#endif
