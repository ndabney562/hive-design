#if canImport(UIKit)
import SwiftUI

/// The Hive apps' ☰ layout: the main page fills the screen; the menu slides in from the left over a dimmed page.
/// A swipe from the left edge opens it (only while `canOpen`, so it never fights swipe-back on pushed pages);
/// tapping the dim, swiping left or VoiceOver's escape closes it.
public struct HiveMenuShell<Content: View, Menu: View>: View {
    @Binding var open: Bool
    var canOpen: Bool
    var content: Content
    var menu: Menu

    public init(open: Binding<Bool>, canOpen: Bool = true, @ViewBuilder content: () -> Content, @ViewBuilder menu: () -> Menu) {
        _open = open
        self.canOpen = canOpen
        self.content = content()
        self.menu = menu()
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                content
                    .accessibilityHidden(open)
                    .gesture(DragGesture(minimumDistance: 20).onEnded { g in
                        if canOpen, g.startLocation.x < 24, g.translation.width > 60 { withAnimation(.snappy) { open = true } }
                    })
                if open {
                    Color.black.opacity(0.35).ignoresSafeArea()
                        .onTapGesture { withAnimation(.snappy) { open = false } }
                        .accessibilityHidden(true)
                        .transition(.opacity)
                    menu
                        .frame(width: Self.width(geo.size.width))
                        .accessibilityAddTraits(.isModal)
                        .accessibilityAction(.escape) { open = false }
                        .transition(.move(edge: .leading))
                        .gesture(DragGesture(minimumDistance: 20).onEnded { g in
                            if g.translation.width < -60 { withAnimation(.snappy) { open = false } }
                        })
                }
            }
            .animation(.snappy, value: open)
        }
    }

    /// 272 pt, or 82% of a narrow screen.
    static func width(_ screen: CGFloat) -> CGFloat { min(272, screen * 0.82) }
}

/// A page in the ☰ menu: a line icon and its name, a full-width 44 pt target.
public struct HiveMenuRow: View {
    let title: String
    let icon: String
    let action: () -> Void

    public init(_ title: String, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                HMIcon(icon, size: 20)
                Text(title).font(HMFont.menuRow()).lineLimit(2).minimumScaleFactor(0.8)
            }
                .foregroundStyle(Color.hm(.ink))
                .padding(.horizontal, 10).frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#endif
