import Foundation

/// HiveMind's dashboard colour tokens (integrations/ui/app.css `:root`, the one source); the raw value is the CSS name without `--`.
public enum ThemeToken: String, CaseIterable, Sendable {
    case bg, side, panel, raise, ink, muted, faint, line, edge, accent
    case accentInk = "accent-ink", accentSoft = "accent-soft", accent2 = "accent-2"
    case good, bad, warn, bar
    /// The main-action gradient's two ends and the label on it: bright in both modes (design review 2026-11-07).
    case gradA = "grad-a", gradB = "grad-b", onGrad = "on-grad"
}

/// 0xRRGGBB per token, light and dark, copied from app.css (HiveMind's ThemeTokensTests and this package's keep them equal).
public enum ThemeTokens {
    public static let light: [ThemeToken: UInt32] = [
        .bg: 0xFBFBFD, .side: 0xF3F2F8, .panel: 0xFFFFFF, .raise: 0xF0EFF6, .ink: 0x1C1C22, .muted: 0x555569,
        .faint: 0x66667A, .line: 0xDDDDE8, .edge: 0x7B7B90, .accent: 0x6D28D9, .accentInk: 0xFFFFFF, .accentSoft: 0xEFE8FD,
        .accent2: 0x0E7490, .good: 0x166E3B, .bad: 0xAD3624, .warn: 0x865709, .bar: 0xE8E6F0,
        .gradA: 0x22D3EE, .gradB: 0xA78BFA, .onGrad: 0x10101A,
    ]
    public static let dark: [ThemeToken: UInt32] = [
        .bg: 0x0F0F17, .side: 0x14141E, .panel: 0x1A1A26, .raise: 0x232332, .ink: 0xECECF3, .muted: 0xB8B8CB,
        .faint: 0xA3A3B8, .line: 0x343447, .edge: 0x77778F, .accent: 0xA78BFA, .accentInk: 0x120D24, .accentSoft: 0x2A2347,
        .accent2: 0x22D3EE, .good: 0x4CC584, .bad: 0xFF7A66, .warn: 0xF2B84B, .bar: 0x262636,
        .gradA: 0x22D3EE, .gradB: 0xA78BFA, .onGrad: 0x10101A,
    ]
}
