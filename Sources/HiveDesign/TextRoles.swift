import Foundation

/// The nine text styles (design review 2026-11-07, Noah: "I like it all"). Sizes are at the default text size and
/// grow with Dynamic Type along `style`; `lineHeight` is the baseline-to-baseline target for wrapped text.
public enum HMTextRole: String, CaseIterable, Sendable {
    /// Screen title, date or greeting: one per page.
    case page
    /// Section and card headings, an article's title.
    case heading
    /// List and task titles, button labels.
    case emphasis
    /// Reading text, field values, required help.
    case body
    /// Helper text, descriptions, timestamps, secondary values.
    case support
    /// Chips, field labels, segment labels.
    case label
    /// Short badges, freshness, small numeric notes.
    case caption
    /// The app's name in the header and menu.
    case brand
    /// A hero number such as the score (digits all one width).
    case metric

    public enum Weight: Sendable { case regular, medium, semibold, bold }
    /// Dynamic Type curve the role scales along (mirrors Font.TextStyle).
    public enum Style: Sendable { case largeTitle, title1, title3, headline, body, subheadline, footnote }

    public struct Spec: Equatable, Sendable {
        public let size: Double
        public let lineHeight: Double
        public let weight: Weight
        public let rounded: Bool
        public let style: Style
        public let color: ThemeToken
    }

    public var spec: Spec {
        switch self {
        case .page: Spec(size: 28, lineHeight: 36, weight: .bold, rounded: true, style: .title1, color: .ink)
        case .heading: Spec(size: 20, lineHeight: 26, weight: .semibold, rounded: false, style: .title3, color: .ink)
        case .emphasis: Spec(size: 17, lineHeight: 22, weight: .semibold, rounded: false, style: .headline, color: .ink)
        case .body: Spec(size: 17, lineHeight: 22, weight: .regular, rounded: false, style: .body, color: .ink)
        case .support: Spec(size: 15, lineHeight: 20, weight: .regular, rounded: false, style: .subheadline, color: .muted)
        case .label: Spec(size: 15, lineHeight: 20, weight: .semibold, rounded: false, style: .subheadline, color: .ink)
        case .caption: Spec(size: 13, lineHeight: 17, weight: .medium, rounded: false, style: .footnote, color: .faint)
        case .brand: Spec(size: 17, lineHeight: 22, weight: .bold, rounded: true, style: .headline, color: .ink)
        case .metric: Spec(size: 44, lineHeight: 56, weight: .bold, rounded: true, style: .largeTitle, color: .ink)
        }
    }
}

/// The slide-to-confirm control's maths, kept apart from SwiftUI so it is tested on any platform.
public enum SlideToConfirm {
    /// How far the thumb must travel (share of its run) before letting go fires the action.
    public static let threshold = 0.85

    /// The thumb's run: the track width minus the thumb and its inset on both sides.
    public static func run(trackWidth: Double, thumb: Double, inset: Double) -> Double {
        max(0, trackWidth - thumb - 2 * inset)
    }

    /// 0...1 progress for a drag of `translation` points along a run of `run` points.
    public static func progress(translation: Double, run: Double) -> Double {
        guard run > 0 else { return 0 }
        return min(1, max(0, translation / run))
    }

    public static func fires(progress: Double) -> Bool { progress >= threshold }
}
