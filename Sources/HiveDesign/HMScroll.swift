#if canImport(UIKit)
import SwiftUI

/// The Hive apps' vertical page scroll: a `ScrollView` whose content matches its own allocated width, so one
/// over-wide line, image or row can never let the page drift sideways (Noah, 2026-11-18, HiveScore: "it allows you
/// to veer from center") and narrower containers like `HiveSideMenu` (272 pt) never stretch to screen width
/// (Noah, 2026-11-21). Over-wide content wraps or is cut at the edge instead. Use it for every vertical page.
public struct HMScroll<Content: View>: View {
    var content: Content
    @State private var width: CGFloat?

    public init(@ViewBuilder content: () -> Content) { self.content = content() }

    public var body: some View {
        ScrollView(.vertical) {
            content
                .frame(width: width)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .frame(maxWidth: .infinity)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { newWidth in
            if newWidth > 0 { width = newWidth }
        }
    }
}
#endif
