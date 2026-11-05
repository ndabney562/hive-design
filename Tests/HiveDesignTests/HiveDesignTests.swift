import Foundation
import SwiftUI
import Testing
@testable import HiveDesign

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
