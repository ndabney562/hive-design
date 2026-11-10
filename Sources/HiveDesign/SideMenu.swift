#if canImport(UIKit)
import SwiftUI

/// The ☰ menu every Hive app shows inside `HiveMenuShell` (Noah, 2026-11-07: one Hive framework): the app's mark and
/// name at the top, its pages as `HiveMenuRow`s, and an optional footer such as `HiveMenuFooter`.
/// HiveMind, HiveScore and HiveTempo each wrote this layout by hand before.
public struct HiveSideMenu<Rows: View, Footer: View>: View {
    let name: String
    let mark: Image?
    let rows: Rows
    let footer: Footer

    public init(name: String, mark: Image? = nil, @ViewBuilder rows: () -> Rows, @ViewBuilder footer: () -> Footer) {
        self.name = name
        self.mark = mark
        self.rows = rows()
        self.footer = footer()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                HiveAppMark(mark, size: 30)
                Text(name).font(HMFont.menuBrand()).tracking(-0.4).foregroundStyle(Color.hm(.ink))
                    .lineLimit(1).minimumScaleFactor(0.6)
            }
            .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 16)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            ScrollView {
                VStack(alignment: .leading, spacing: 2) { rows }
                    .padding(.horizontal, 8)
            }

            footer
        }
        .background(Color.hm(.side).ignoresSafeArea())
        // The menu is at most 272 pt wide: its type stops growing at the largest standard size, as a sidebar does,
        // so the largest accessibility sizes never break a name mid-word ("HiveRo|unds"). VoiceOver reads it in full.
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}

extension HiveSideMenu where Footer == EmptyView {
    public init(name: String, mark: Image? = nil, @ViewBuilder rows: () -> Rows) {
        self.init(name: name, mark: mark, rows: rows) { EmptyView() }
    }
}

/// The menu's foot, as HiveMind's quota bar: one line of text over a 5 pt bar. Tapping it runs `action`.
public struct HiveMenuFooter: View {
    let label: String
    let fraction: Double
    let fill: AnyShapeStyle
    let accessibility: String
    let action: () -> Void

    /// `fraction` is clamped to 0…1; `fill` defaults to the accent gradient.
    public init(_ label: String, fraction: Double, fill: AnyShapeStyle = AnyShapeStyle(LinearGradient.hmAccent),
                accessibilityLabel: String? = nil, action: @escaping () -> Void) {
        self.label = label
        self.fraction = min(max(fraction.isFinite ? fraction : 0, 0), 1)
        self.fill = fill
        self.accessibility = accessibilityLabel ?? label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label).font(HMFont.small()).foregroundStyle(Color.hm(.muted)).lineLimit(1)
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.hm(.bar))
                        Capsule().fill(fill).frame(width: g.size.width * fraction)
                    }
                }
                .frame(height: 5)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibility)
        .padding(.horizontal, 18).padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .top) { Rectangle().fill(Color.hm(.line)).frame(height: 1) }
    }
}

/// The round ☰ button at the top left of each app's main page.
public struct HiveMenuButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) { self.action = action }

    public var body: some View {
        Button(action: action) { HMIcon("menu", size: 20) }
            .buttonStyle(RoundButtonStyle())
            .accessibilityLabel("Open menu")
            .accessibilityIdentifier("openMenu")
    }
}

/// The app's mark (its icon without the home-screen mask). With no image yet, the Hive hexagon in the accent gradient.
public struct HiveAppMark: View {
    let image: Image?
    let size: CGFloat

    public init(_ image: Image? = nil, size: CGFloat = 36) {
        self.image = image
        self.size = size
    }

    public var body: some View {
        Group {
            if let image {
                image.resizable().interpolation(.high)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
            } else {
                Hexagon().fill(LinearGradient.hmAccent).frame(width: size, height: size)
            }
        }
        .accessibilityHidden(true)
    }
}
#endif
