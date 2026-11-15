import HiveKit
#if canImport(UIKit)
import SwiftUI
import UIKit

/// Shared GitHub device-flow sign-in screen for HiveScore, HiveTempo, and HiveWorld.
public struct HiveGitHubSignInView: View {
    public let mark: Image
    public let title: String
    public let subtitle: String
    public let footnote: String
    public let code: DeviceCode?
    public let problem: String?
    public let onSignIn: () -> Void
    public let onCancel: () -> Void
    public let onDismiss: (() -> Void)?

    @Environment(\.openURL) private var openURL

    public init(
        mark: Image,
        title: String,
        subtitle: String,
        footnote: String,
        code: DeviceCode?,
        problem: String?,
        onSignIn: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.mark = mark
        self.title = title
        self.subtitle = subtitle
        self.footnote = footnote
        self.code = code
        self.problem = problem
        self.onSignIn = onSignIn
        self.onCancel = onCancel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HiveAppMark(mark, size: 64)
                Text(title).hmText(.page)
                Text(subtitle).hmText(.support)

                if let code {
                    HMCard {
                        Text("On GitHub, type this code:").hmText(.support)
                        Text(code.userCode)
                            .font(HMType.font(.metric, size: 34))
                            .foregroundStyle(Color.hm(.ink))
                            .textSelection(.enabled)
                            .accessibilityIdentifier("device-code")
                        Button {
                            copyToClipboard(code.userCode)
                            openURL(code.verificationURI)
                        } label: {
                            Label("Copy code and open GitHub", systemImage: "arrow.up.right.square")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Waiting for GitHub. The code works for 15 minutes.")
                                .hmText(.support)
                        }
                        Button("Cancel", action: onCancel).buttonStyle(SecondaryButtonStyle())
                    }
                } else {
                    Button(action: onSignIn) {
                        Label("Sign in with GitHub", systemImage: "person.badge.key")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("sign-in")
                    Text(footnote).hmText(.support)
                    if let onDismiss {
                        Button("Not now", action: onDismiss).buttonStyle(SecondaryButtonStyle())
                    }
                }

                if let problem {
                    Text(problem).hmText(.body, color: .bad)
                }
            }
            .padding(20)
        }
        .background(Color.hm(.bg))
        .tint(Color.hm(.accent))
    }

    private func copyToClipboard(_ value: String) {
        UIPasteboard.general.string = value
    }
}
#endif
