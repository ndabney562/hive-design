#if canImport(UIKit)
import SwiftUI
import UIKit

// Text roles and the components added by the design review (2026-11-07; Noah: "I like it all").

extension HMTextRole.Style {
    var font: Font.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title1: .title
        case .title3: .title3
        case .headline: .headline
        case .body: .body
        case .subheadline: .subheadline
        case .footnote: .footnote
        }
    }
}

extension HMTextRole.Weight {
    var font: Font.Weight {
        switch self { case .regular: .regular; case .medium: .medium; case .semibold: .semibold; case .bold: .bold }
    }
    var uiFont: UIFont.Weight {
        switch self { case .regular: .regular; case .medium: .medium; case .semibold: .semibold; case .bold: .bold }
    }
}

/// A role's font at a given (already scaled) size.
public enum HMType {
    public static func font(_ role: HMTextRole, size: CGFloat) -> Font {
        let s = role.spec
        let f = Font.system(size: size, weight: s.weight.font, design: s.rounded ? .rounded : .default)
        return role == .metric ? f.monospacedDigit() : f
    }
}

/// Font, colour and line spacing for one text role, scaled with the reader's text size. Never shrinks text to fit.
struct HMTextModifier: ViewModifier {
    let role: HMTextRole
    let color: ThemeToken
    @ScaledMetric private var size: CGFloat
    @ScaledMetric private var interval: CGFloat

    init(role: HMTextRole, color: ThemeToken?) {
        self.role = role
        self.color = color ?? role.spec.color
        _size = ScaledMetric(wrappedValue: role.spec.size, relativeTo: role.spec.style.font)
        _interval = ScaledMetric(wrappedValue: role.spec.lineHeight, relativeTo: role.spec.style.font)
    }

    func body(content: Content) -> some View {
        var natural = UIFont.systemFont(ofSize: size, weight: role.spec.weight.uiFont)
        if role.spec.rounded, let d = natural.fontDescriptor.withDesign(.rounded) { natural = UIFont(descriptor: d, size: size) }
        return content
            .font(HMType.font(role, size: size))
            .foregroundStyle(Color.hm(color))
            .lineSpacing(max(0, interval - natural.lineHeight))
    }
}

public extension View {
    /// Style text as one of the nine roles; `color` overrides the role's colour token.
    func hmText(_ role: HMTextRole, color: ThemeToken? = nil) -> some View {
        modifier(HMTextModifier(role: role, color: color))
    }
}

/// A small flat chip for state or data (not a button): raised fill, 8 pt corners, `label` text.
public struct HMChip: View {
    let text: String
    var systemImage: String?
    var tint: ThemeToken?
    var compact: Bool

    /// `compact` uses the caption role (durations where space is tight); `tint` colours the text and symbol.
    public init(_ text: String, systemImage: String? = nil, tint: ThemeToken? = nil, compact: Bool = false) {
        self.text = text
        self.systemImage = systemImage
        self.tint = tint
        self.compact = compact
    }

    public var body: some View {
        HStack(spacing: 6) {
            if let systemImage { Image(systemName: systemImage).accessibilityHidden(true) }
            Text(text)
        }
        .hmText(compact ? .caption : .label, color: tint ?? (compact ? .muted : .ink))
        .padding(.horizontal, 10).padding(.vertical, 4)
        .frame(minHeight: 28)
        .background(Color.hm(.raise), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// A state, not a button: "Saved" with a check, "Saving…" with a spinner, a failure with a cross.
public struct HMStatus: View {
    public enum Kind: Sendable { case done, working, failed, info }
    let kind: Kind
    let text: String
    var emphasized: Bool

    public init(_ kind: Kind, _ text: String, emphasized: Bool = false) {
        self.kind = kind
        self.text = text
        self.emphasized = emphasized
    }

    public var body: some View {
        HStack(spacing: 8) {
            switch kind {
            case .done: symbol("checkmark.circle.fill", .good)
            case .failed: symbol("xmark.octagon.fill", .bad)
            case .info: symbol("info.circle", .muted)
            case .working: ProgressView().controlSize(.small)
            }
            Text(text).hmText(emphasized ? .emphasis : .support, color: emphasized ? .ink : .muted)
        }
        .accessibilityElement(children: .combine)
    }

    private func symbol(_ name: String, _ tint: ThemeToken) -> some View {
        Image(systemName: name).font(.system(size: 18)).foregroundStyle(Color.hm(tint)).accessibilityHidden(true)
    }
}

/// Slide to confirm (Noah, 2026-11-07: HiveScore's Optimize "should be a slider on mobile"): drag the thumb across
/// the track to run `action`, so a stray tap can't start it. With VoiceOver, Switch Control or the largest text sizes
/// it is a plain primary button instead, which is easier to use there.
public struct HMSlideToConfirm: View {
    let title: String
    var value: String?
    var workingTitle: String
    var isWorking: Bool
    let action: () -> Void

    @State private var drag: CGFloat = 0
    @State private var fired = 0
    @ScaledMetric(relativeTo: .headline) private var height: CGFloat = 56
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @Environment(\.accessibilitySwitchControlEnabled) private var switchControl
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.isEnabled) private var isEnabled

    /// `title` e.g. "Slide to optimize"; `value` e.g. "+0.8"; `workingTitle` shows with a spinner while `isWorking`.
    public init(_ title: String, value: String? = nil, workingTitle: String = "Working…", isWorking: Bool = false,
                action: @escaping () -> Void) {
        self.title = title
        self.value = value
        self.workingTitle = workingTitle
        self.isWorking = isWorking
        self.action = action
    }

    private let inset: CGFloat = 4

    public var body: some View {
        if voiceOver || switchControl || typeSize.isAccessibilitySize {
            Button(action: action) {
                if isWorking { HStack(spacing: 8) { ProgressView(); Text(workingTitle) } } else { buttonLabel }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isWorking)
        } else {
            slider
        }
    }

    private var buttonLabel: some View {
        HStack(spacing: 8) {
            Text(title.replacingOccurrences(of: "Slide to ", with: "").capitalizedFirst)
            if let value { Text(value) }
        }
    }

    private var slider: some View {
        GeometryReader { geo in
            let thumb = height - 2 * inset
            let run = SlideToConfirm.run(trackWidth: geo.size.width, thumb: thumb, inset: inset)
            let progress = SlideToConfirm.progress(translation: drag, run: run)
            ZStack(alignment: .leading) {
                Capsule().fill(Color.hm(.raise))
                Capsule().fill(LinearGradient.hmAction)
                    .frame(width: thumb + 2 * inset + drag)
                    .opacity(isEnabled ? 0.35 + 0.65 * progress : 0)
                Capsule().strokeBorder(Color.hm(.edge))
                Group {
                    if isWorking {
                        HStack(spacing: 8) { ProgressView(); Text(workingTitle).hmText(.emphasis) }
                    } else {
                        HStack(spacing: 8) {
                            Text(title).hmText(.emphasis, color: isEnabled ? .ink : .muted)
                            if let value { Text(value).hmText(.emphasis, color: isEnabled ? .accent : .muted).monospacedDigit() }
                        }
                        .opacity(1 - min(1, progress * 1.6))
                    }
                }
                .lineLimit(1)
                .padding(.leading, thumb + 2 * inset + 8).padding(.trailing, 16)
                .frame(maxWidth: .infinity)
                Circle().fill(isEnabled ? AnyShapeStyle(LinearGradient.hmAction) : AnyShapeStyle(Color.hm(.edge)))
                    .frame(width: thumb, height: thumb)
                    .overlay(Image(systemName: "chevron.right.2").font(.system(size: thumb * 0.36, weight: .bold))
                        .foregroundStyle(Color.hm(.onGrad)))
                    .offset(x: inset + drag)
                    .opacity(isWorking ? 0 : 1)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { g in drag = min(run, max(0, g.translation.width)) }
                        .onEnded { _ in
                            if SlideToConfirm.fires(progress: SlideToConfirm.progress(translation: drag, run: run)) {
                                drag = run
                                fired += 1
                                action()
                                if !isWorking { settle() }
                            } else {
                                settle()
                            }
                        })
                    .allowsHitTesting(isEnabled && !isWorking)
            }
        }
        .frame(height: height)
        .contentShape(Capsule())
        .sensoryFeedback(.success, trigger: fired)
        .onChange(of: isWorking) { _, working in if !working { settle() } }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isWorking ? workingTitle : [title, value].compactMap { $0 }.joined(separator: " "))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { if !isWorking { action() } }
    }

    private func settle() {
        if reduceMotion { drag = 0 } else { withAnimation(.snappy) { drag = 0 } }
    }
}

private extension String {
    var capitalizedFirst: String { prefix(1).uppercased() + dropFirst() }
}
#endif
