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
    /// The main action's bright cyan→violet (`--accent-grad`), the same in both modes, with `onGrad` text on it.
    static let hmAction = LinearGradient(colors: [Color.hm(.gradA), Color.hm(.gradB)], startPoint: .leading, endPoint: .trailing)
    /// The icons' cyan→violet in the theme's accent colours: bars, the score ring, the hexagon.
    static let hmAccent = LinearGradient(colors: [Color.hm(.accent2), Color.hm(.accent)], startPoint: .topLeading, endPoint: .bottomTrailing)
    /// The highlight card's tint. Deprecated look: cards are flat now (design review 2026-11-07).
    @available(*, deprecated, message: "Cards are flat now; no gradient behind text.")
    /// The highlight card's tint: the accent gradient, faintly, over the panel (HiveMind's Energy card).
    static let hmHighlight = LinearGradient(colors: [Color.hm(.accent2).opacity(0.14), Color.hm(.accent).opacity(0.10)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing)
}

/// The dashboard's sizes, scaled with Dynamic Type.
/// Two faces (Noah, 2026-11-04: "Rounded display"): SF Pro Rounded, bold, for names, headings and numbers;
/// SF Pro for reading text. Every size follows the reader's text size.
/// Older per-size API; new code uses `HMTextRole` (`.hmText(.body)`, `HMType.font(.body)`). Kept while apps migrate.
public enum HMFont {
    public static func body() -> Font { .system(size: 15, relativeTo: .body) }
    /// Fields and the composer: 16 pt at phone width.
    public static func field() -> Font { .system(size: 16, relativeTo: .body) }
    public static func heading() -> Font { .system(size: 22, weight: .bold, design: .rounded, relativeTo: .title2) }
    public static func meta() -> Font { .system(size: 13, relativeTo: .footnote) }
    public static func brand() -> Font { .system(size: 17, weight: .bold, design: .rounded, relativeTo: .headline) }
    /// The menu's app name.
    public static func menuBrand() -> Font { .system(size: 24, weight: .bold, design: .rounded, relativeTo: .title2) }
    /// A page's big title and an empty screen's greeting.
    public static func greeting() -> Font { .system(size: 28, weight: .bold, design: .rounded, relativeTo: .title1) }
    public static func menuRow() -> Font { .system(size: 16, weight: .medium, relativeTo: .body) }
    public static func pill() -> Font { .system(size: 13, weight: .medium, relativeTo: .footnote) }
    public static func small() -> Font { .system(size: 12, relativeTo: .caption1) }
    public static func strong() -> Font { .system(size: 15, weight: .semibold, relativeTo: .body) }
    /// Card and section titles, in capitals with 0.6 pt tracking (HMCardTitle).
    public static func label() -> Font { .system(size: 11, weight: .semibold, relativeTo: .caption2) }
    /// A big number (a score, a count): rounded, bold, digits all one width.
    public static func number(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded, relativeTo: .largeTitle).monospacedDigit()
    }
    /// Fixed-size faces for widgets, which have no room to grow with the text size.
    public static func fixed(_ size: CGFloat, _ weight: Font.Weight = .regular, rounded: Bool = false) -> Font {
        .system(size: size, weight: weight, design: rounded ? .rounded : .default)
    }
}

private extension Font {
    /// SF Pro (or SF Pro Rounded) at the dashboard's size, scaled by the reader's text size like `style`.
    static func system(size: CGFloat, weight: UIFont.Weight = .regular, design: UIFontDescriptor.SystemDesign = .default,
                       relativeTo style: UIFont.TextStyle) -> Font {
        var font = UIFont.systemFont(ofSize: size, weight: weight)
        if let d = font.fontDescriptor.withDesign(design) { font = UIFont(descriptor: d, size: size) }
        return Font(UIFontMetrics(forTextStyle: style).scaledFont(for: font))
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

/// A section card: flat panel, quiet border, 20 pt corners, 16 pt inside (design review 2026-11-07).
/// `highlight` is kept for older callers and no longer tints the card: no gradient behind text.
public struct HMCard<Content: View>: View {
    var content: Content

    public init(highlight: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.hm(.panel), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Color.hm(.line)))
    }
}

/// A section or card heading: `heading` role (20 pt semibold, ink), sentence case as written, a VoiceOver heading.
/// Replaces the 11 pt uppercase label (design review 2026-11-07).
public struct HMCardTitle: View {
    let title: String
    public init(_ title: String) { self.title = title }

    public var body: some View {
        Text(title).hmText(.heading)
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
            if let note { Text(note).hmText(.support).padding(.top, 4) }
        }
    }
}

/// A card row: a name on the left, a value on the right; stacked when they don't fit or at accessibility text sizes.
public struct HMRow: View {
    let name: String
    let value: String
    @Environment(\.dynamicTypeSize) private var typeSize
    public init(name: String, value: String) { self.name = name; self.value = value }

    public var body: some View {
        Group {
            if typeSize.isAccessibilitySize {
                stacked
            } else {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(name).hmText(.body)
                        Spacer(minLength: 12)
                        Text(value).hmText(.support).multilineTextAlignment(.trailing)
                    }
                    stacked
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var stacked: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name).hmText(.body)
            Text(value).hmText(.support)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// The one main action in a group: bright cyan→violet, dark label, 14 pt corners, at least 48 pt tall.
/// Pressed: a 2 pt inner outline, no shrinking. Disabled: raised fill, muted label.
public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        configuration.label
            .hmText(.emphasis, color: isEnabled ? .onGrad : .muted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16).padding(.vertical, 13)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background { if isEnabled { shape.fill(LinearGradient.hmAction) } else { shape.fill(Color.hm(.raise)) } }
            .overlay { if configuration.isPressed { shape.strokeBorder(Color.hm(.onGrad), lineWidth: 2) } }
            .contentShape(shape)
    }
}

/// A secondary action that looks tappable: raised fill, a 1 pt outline at 3:1, accent label, at least 48 pt tall.
/// `destructive` uses the bad colour. Replaces plain muted text buttons (design review 2026-11-07).
public struct SecondaryButtonStyle: ButtonStyle {
    var destructive: Bool
    var fullWidth: Bool
    @Environment(\.isEnabled) private var isEnabled
    public init(destructive: Bool = false, fullWidth: Bool = false) {
        self.destructive = destructive
        self.fullWidth = fullWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        configuration.label
            .hmText(.emphasis, color: !isEnabled ? .muted : destructive ? .bad : .accent)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16).padding(.vertical, 13)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 48)
            .frame(minWidth: 44)
            .background(Color.hm(.raise), in: shape)
            .overlay(shape.strokeBorder(configuration.isPressed ? Color.hm(.accent) : Color.hm(.edge),
                                        lineWidth: configuration.isPressed ? 2 : 1))
            .contentShape(shape)
    }
}

/// A whole card or list row that opens something: it dims and shrinks a little while held, and gives a light tap
/// on the iPhone, so every press visibly lands (Noah, HiveTempo 2026-11-11). Put it on a Button around the row.
public struct HMPressStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, pressed in pressed }
    }
}

/// Older plain-text button. New code uses `SecondaryButtonStyle`, which looks tappable.
@available(*, deprecated, message: "Use SecondaryButtonStyle: actions must look tappable.")
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

/// The round icon buttons (☰, ✎, search, share): a 44 pt circle, panel fill, a 3:1 outline, no shadow.
public struct RoundButtonStyle: ButtonStyle {
    var size: CGFloat
    public init(size: CGFloat = 44) { self.size = size }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.hm(.ink))
            .frame(width: size, height: size)
            .background(configuration.isPressed ? Color.hm(.raise) : Color.hm(.panel), in: Circle())
            .overlay(Circle().strokeBorder(Color.hm(.edge)))
            .contentShape(Circle())
    }
}
#endif
