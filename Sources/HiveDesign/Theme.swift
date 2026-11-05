#if canImport(UIKit)
import SwiftUI
import UIKit

/// The Hive look (HiveMind's dashboard, integrations/ui/app.css at phone width), for SwiftUI.
public extension Color {
    /// A token's colour, light or dark with the phone's appearance.
    /// nonisolated: UIKit resolves dynamic colours off the main thread too (animations, a ProgressView); this only reads constants.
    nonisolated static func hm(_ t: ThemeToken) -> Color {
        Color(UIColor { traits in
            let hex = (traits.userInterfaceStyle == .dark ? ThemeTokens.dark : ThemeTokens.light)[t] ?? 0
            return UIColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255,
                           blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
        })
    }
}

public extension LinearGradient {
    /// The icons' cyan→violet (`--accent-grad`): primary buttons, bars, the score ring.
    static let hmAccent = LinearGradient(colors: [Color.hm(.accent2), Color.hm(.accent)], startPoint: .topLeading, endPoint: .bottomTrailing)
    /// The highlight card's tint: the accent gradient, faintly, over the panel (HiveMind's Energy card).
    static let hmHighlight = LinearGradient(colors: [Color.hm(.accent2).opacity(0.14), Color.hm(.accent).opacity(0.10)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing)
}

/// The dashboard's sizes, scaled with Dynamic Type.
public enum HMFont {
    public static func body() -> Font { .system(size: 15, relativeTo: .body) }
    /// Fields and the composer: 16 pt at phone width.
    public static func field() -> Font { .system(size: 16, relativeTo: .body) }
    public static func heading() -> Font { .system(size: 24, weight: .semibold, relativeTo: .title2) }
    public static func meta() -> Font { .system(size: 13, relativeTo: .footnote) }
    public static func brand() -> Font { .system(size: 17, weight: .semibold, relativeTo: .headline) }
    /// The menu's app name.
    public static func menuBrand() -> Font { .system(size: 24, weight: .semibold, relativeTo: .title2) }
    /// A page's big title and an empty screen's greeting.
    public static func greeting() -> Font { .system(size: 28, weight: .semibold, relativeTo: .title1) }
    public static func menuRow() -> Font { .system(size: 16, relativeTo: .body) }
    public static func pill() -> Font { .system(size: 13, relativeTo: .footnote) }
    public static func small() -> Font { .system(size: 12, relativeTo: .caption1) }
    public static func strong() -> Font { .system(size: 15, weight: .semibold, relativeTo: .body) }
}

private extension Font {
    /// SF Pro at the dashboard's size, scaled by the reader's text size like `style`.
    static func system(size: CGFloat, weight: UIFont.Weight = .regular, relativeTo style: UIFont.TextStyle) -> Font {
        Font(UIFontMetrics(forTextStyle: style).scaledFont(for: .systemFont(ofSize: size, weight: weight)))
    }
}

/// One of the Hive line icons (`IconNames.all`), tinted by the text colour.
public struct HMIcon: View {
    let name: String
    @ScaledMetric private var size: CGFloat

    public init(_ name: String, size: CGFloat = 18) {
        self.name = name
        _size = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    public var body: some View {
        Image("i-" + name, bundle: .module).renderingMode(.template).resizable().scaledToFit().frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// The dashboard's `.card`: panel fill, a quiet border, 14 pt corners. `highlight`: the accent gradient faintly over
/// the panel (HiveMind's Energy card), for the one card on a page that matters most.
public struct HMCard<Content: View>: View {
    var highlight: Bool
    var content: Content

    public init(highlight: Bool = false, @ViewBuilder content: () -> Content) {
        self.highlight = highlight
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 14).fill(Color.hm(.panel))
                if highlight { RoundedRectangle(cornerRadius: 14).fill(LinearGradient.hmHighlight) }
            }
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.hm(.line)))
    }
}

/// A card's heading (the dashboard's `h3`): 12 pt semibold, uppercase, muted; VoiceOver reads it as written.
public struct HMCardTitle: View {
    let title: String
    public init(_ title: String) { self.title = title }

    public var body: some View {
        Text(title.uppercased()).font(HMFont.small().weight(.semibold)).tracking(0.4).foregroundStyle(Color.hm(.muted))
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A Settings-style card: `HMCard` with its heading and an optional note below.
public struct HMSection<Content: View>: View {
    let title: String
    var note: String?
    var content: Content

    public init(title: String, note: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.note = note
        self.content = content()
    }

    public var body: some View {
        HMCard {
            HMCardTitle(title)
            content
            if let note { Text(note).font(HMFont.meta()).foregroundStyle(Color.hm(.muted)) }
        }
    }
}

/// A card row: a name on the left, a value on the right (Form's LabeledContent, in the card look).
public struct HMRow: View {
    let name: String
    let value: String
    public init(name: String, value: String) { self.name = name; self.value = value }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(name).font(HMFont.body()).foregroundStyle(Color.hm(.ink))
            Spacer(minLength: 12)
            Text(value).font(HMFont.meta()).foregroundStyle(Color.hm(.muted)).multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The dashboard's `.btn.primary`: the accent gradient, a pill, touch-sized.
public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HMFont.strong().weight(.semibold))
            .foregroundStyle(Color.hm(.accentInk))
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(LinearGradient.hmAccent.opacity(configuration.isPressed ? 0.85 : 1), in: Capsule())
            .contentShape(Capsule())
    }
}

/// The dashboard's `.btn.ghost`: no border, muted text, a raised fill while pressed; touch-sized.
public struct GhostButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HMFont.body())
            .foregroundStyle(configuration.isPressed ? Color.hm(.ink) : Color.hm(.muted))
            .padding(.horizontal, 10)
            .frame(minWidth: 44, minHeight: 40)
            .background(configuration.isPressed ? Color.hm(.raise) : .clear, in: RoundedRectangle(cornerRadius: 8))
            .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// The round icon buttons (☰, ✎, search, share): a 44 pt circle, panel fill, a quiet border and the card shadow.
public struct RoundButtonStyle: ButtonStyle {
    var size: CGFloat
    public init(size: CGFloat = 44) { self.size = size }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.hm(.ink))
            .frame(width: size, height: size)
            .background(configuration.isPressed ? Color.hm(.raise) : Color.hm(.panel), in: Circle())
            .overlay(Circle().strokeBorder(Color.hm(.line)))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
            .contentShape(Circle())
    }
}
#endif
