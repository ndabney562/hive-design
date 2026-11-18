#if canImport(UIKit)
import HiveKit
import SwiftUI

/// First-launch setup (Hive build order #35, Onboard 60): hive-kit's `HiveSetup` on screen. One step at a time with
/// "Step 2 of 3" and a bar, why the app asks, and what iOS will show before it shows it; "Not now" on optional steps;
/// "Welcome back" after an interrupted setup; every step listed below with its state. The app saves `setup` on every
/// change (`HiveSetup.save`) and closes the screen from `finish`.
public struct HiveSetupView: View {
    @Binding var setup: HiveSetup
    let appName: String
    let mark: Image?
    /// Runs a step (shows the sign-in, asks iOS for the permission). true: the step is done now. false: not yet
    /// (declined, or it finishes elsewhere, like a sign-in sheet; the app then calls `setup.sync`).
    let run: (SetupStep) async -> Bool
    let finish: () -> Void
    @State private var working = false

    public init(setup: Binding<HiveSetup>, appName: String, mark: Image? = nil,
                run: @escaping (SetupStep) async -> Bool, finish: @escaping () -> Void) {
        _setup = setup
        self.appName = appName
        self.mark = mark
        self.run = run
        self.finish = finish
    }

    public var body: some View {
        HMScroll {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    HiveAppMark(mark, size: 36)
                    Text("Set up \(appName)").hmText(.page).accessibilityAddTraits(.isHeader)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(setup.progressText).hmText(.label, color: .muted).accessibilityIdentifier("setup-progress")
                    ProgressView(value: setup.fraction).tint(Color.hm(.accent))
                        .accessibilityLabel("Setup progress")
                        .accessibilityValue("\(Int((setup.fraction * 100).rounded())) percent")
                }
                if let note = setup.resumeNote {
                    Text(note).hmText(.support).accessibilityIdentifier("setup-resume")
                }
                if let step = setup.current { current(step) } else { allSet }
                list
            }
            .padding(16)
        }
        .background(Color.hm(.bg).ignoresSafeArea())
    }

    private func current(_ step: SetupStep) -> some View {
        HMCard {
            HMCardTitle(step.title)
            Text(step.why).hmText(.body).fixedSize(horizontal: false, vertical: true)
            if let ask = step.permission {
                Label(ask, systemImage: "hand.raised").hmText(.support)
                    .accessibilityIdentifier("setup-permission")
            }
            HStack(spacing: 8) {
                Button(working ? "Working…" : step.action) {
                    working = true
                    Task {
                        if await run(step) { setup.markDone(step.id) }
                        working = false
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(working)
                .accessibilityIdentifier("setup-action")
                if !step.required {
                    Button("Not now") { setup.skip(step.id) }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(working)
                        .accessibilityIdentifier("setup-skip")
                }
            }
            .padding(.top, 4)
        }
        .accessibilityIdentifier("setup-step-\(step.id)")
    }

    private var allSet: some View {
        HMCard {
            HMCardTitle("All set")
            Text("Steps you put off are in Settings whenever you want them.").hmText(.body)
            Button("Start using \(appName)", action: finish)
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("setup-finish")
        }
    }

    private var list: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(setup.steps) { step in
                let state = setup.state(step.id)
                HStack(spacing: 10) {
                    Image(systemName: state == .done ? "checkmark.circle.fill" : state == .skipped ? "minus.circle" : "circle")
                        .foregroundStyle(Color.hm(state == .done ? .good : .faint))
                        .accessibilityHidden(true)
                    Text(step.title).hmText(.body, color: step.id == setup.current?.id ? .ink : .muted)
                    Spacer(minLength: 0)
                    Text(state == .done ? "Done" : state == .skipped ? "Not now" : step.required ? "Needed" : "Optional")
                        .hmText(.caption, color: .muted)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview("Setup: step 2 of 3, resumed") {
    @Previewable @State var setup = HiveSetup(steps: [
        SetupStep(id: "github", title: "Sign in to GitHub", why: "HiveTempo reads today's plan from your repo.",
                  required: true, action: "Sign in"),
        SetupStep(id: "alerts", title: "Allow notifications", why: "Briefings and nudges ring with sound.",
                  permission: "iOS asks: \"HiveTempo\" Would Like to Send You Notifications", action: "Allow"),
        SetupStep(id: "icloud", title: "Check iCloud", why: "Ticks sync between this iPhone and the Mac.", action: "Check"),
    ], states: ["github": .done], resumed: true)
    HiveSetupView(setup: $setup, appName: "HiveTempo", run: { _ in true }, finish: {})
}
#endif
