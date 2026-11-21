#if canImport(UIKit)
import SwiftUI

/// The Hive apps' vertical page scroll: a `ScrollView` whose content matches its own allocated width, so one
/// over-wide line, image or row can never let the page drift sideways (Noah, 2026-11-18, HiveScore: "it allows you
/// to veer from center") and narrower containers like `HiveSideMenu` (272 pt) never stretch to screen width
/// (Noah, 2026-11-21). Over-wide content wraps or is cut at the edge instead. Use it for every vertical page.
public struct HMScroll<Content: View>: View {
    var content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                content
                    .frame(width: geo.size.width)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
    }
}
#endif
