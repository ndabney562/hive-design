import Foundation
#if canImport(UIKit)
import SwiftUI
#endif

/// One sibling app in the ☰ menu's "Hive apps" section (hive-kit docs/superpowers/specs/2026-11-09-hive-switcher-design.md).
/// Plain values so hive-design needs no hive-kit: each app maps hive-kit's `HiveStatus` to these.
public struct HiveAppLink: Identifiable, Equatable, Sendable {
    public var name: String
    public var status: String
    public var url: URL
    public var id: String { name }

    public init(name: String, status: String, url: URL) {
        self.name = name
        self.status = status
        self.url = url
    }

    /// VoiceOver reads the separator as a pause, not a word.
    public var accessibilityLabel: String { "\(name), " + status.replacingOccurrences(of: " · ", with: ", ") }
    public var accessibilityHint: String { "Opens \(name)" }

    /// After a tap found the app missing, the row says so instead of its status.
    public func shown(missing: Bool) -> String { missing ? "Not on this iPhone" : status }
}

#if canImport(UIKit)
/// The menu's "Hive apps" section: a header and one row per sibling app with its live status; a tap opens the app.
/// Put it at the end of `HiveSideMenu`'s rows. Never in HiveRounds (it runs on someone else's phone).
public struct HiveAppsSection: View {
    let links: [HiveAppLink]
    @Environment(\.openURL) private var openURL
    @State private var missing: Set<String> = []

    public init(_ links: [HiveAppLink]) { self.links = links }

    public var body: some View {
        if !links.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hive apps").font(HMFont.small()).foregroundStyle(Color.hm(.muted))
                    .padding(.horizontal, 10).padding(.top, 18).padding(.bottom, 4)
                    .accessibilityAddTraits(.isHeader)
                ForEach(links) { link in
                    Button {
                        openURL(link.url) { opened in if !opened { missing.insert(link.name) } }
                    } label: {
                        HStack(spacing: 14) {
                            HiveAppMark(nil, size: 20)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(link.name).font(HMFont.menuRow()).foregroundStyle(Color.hm(.ink))
                                Text(link.shown(missing: missing.contains(link.name)))
                                    .font(HMFont.small()).foregroundStyle(Color.hm(.muted)).lineLimit(2)
                            }
                        }
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(missing.contains(link.name) ? "\(link.name), not on this iPhone" : link.accessibilityLabel)
                    .accessibilityHint(link.accessibilityHint)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("hiveApp-\(link.name)")
                }
            }
        }
    }
}
#endif
