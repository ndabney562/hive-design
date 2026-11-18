#if canImport(UIKit)
import SwiftUI

/// The Hive apps' vertical page scroll: a `ScrollView` whose content is always exactly the screen's width, so one
/// over-wide line, image or row can never let the page drift sideways (Noah, 2026-11-18, HiveScore: "it allows you
/// to veer from center"). Over-wide content wraps or is cut at the edge instead. Use it for every vertical page.
public struct HMScroll<Content: View>: View {
    var content: Content

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        ScrollView(.vertical) {
            content.containerRelativeFrame(.horizontal)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    }
}
#endif
