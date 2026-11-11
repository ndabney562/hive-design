#if canImport(UIKit)
import HiveKit
import SwiftUI

/// The "How to use" guide (spec docs/superpowers/specs/2026-11-11-hive-guide-design.md): a searchable list of
/// "How do I…?" cards, each opening its numbered steps. Shown in a sheet from the ☰ menu's top row.
public struct HiveGuideView: View {
    let guide: Guide
    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    public init(guide: Guide) { self.guide = guide }

    public var body: some View {
        NavigationStack {
            let found = guide.search(query)
            List {
                ForEach(found) { card in
                    NavigationLink {
                        HiveGuideCardView(card: card)
                    } label: {
                        Text(card.title).hmText(.body).padding(.vertical, 6)
                    }
                    .accessibilityIdentifier("guideCard-\(card.id)")
                    .listRowBackground(Color.hm(.panel))
                }
            }
            .overlay {
                if found.isEmpty {
                    Text("No how-to matches \"\(query.trimmingCharacters(in: .whitespaces))\"")
                        .hmText(.support).multilineTextAlignment(.center).padding(24)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.hm(.bg).ignoresSafeArea())
            .navigationTitle("How to use")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search how-tos")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.accessibilityIdentifier("guideDone")
                }
            }
        }
    }
}

/// One card: its question as the heading and its steps numbered 1…n.
public struct HiveGuideCardView: View {
    let card: GuideCard

    public init(card: GuideCard) { self.card = card }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(card.title).hmText(.page).accessibilityAddTraits(.isHeader)
                HMCard { GuideSteps(steps: card.steps) }
            }
            .padding(16)
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.hm(.bg).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GuideSteps: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(steps.enumerated()), id: \.offset) { n, step in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("\(n + 1)").hmText(.emphasis).foregroundStyle(Color.hm(.accent))
                        .frame(minWidth: 22, alignment: .trailing)
                    Text(step).hmText(.body).fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

/// Whether an app shows the 3-card welcome on its first launch (apps meant for other people: HiveRounds, HiveBeat).
public struct HiveGuideOptions: Sendable {
    public var welcome: Bool
    public init(welcome: Bool = false) { self.welcome = welcome }
}

/// The sheet "What's new" (after an update) or "Welcome" (first launch, opt-in) shows its cards in.
struct HiveWhatsNewView: View {
    let title: String
    let cards: [GuideCard]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(cards) { card in
                        HMCard {
                            Text(card.title).hmText(.heading).accessibilityAddTraits(.isHeader)
                            GuideSteps(steps: card.steps)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .background(Color.hm(.bg).ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.accessibilityIdentifier("whatsNewDone")
                }
            }
        }
    }
}

/// The cards one launch shows. The sheet is presented with `item:` so its cards come with it: with
/// `isPresented:` plus separate state, the sheet sometimes drew before the cards were set and opened empty.
struct GuideLaunchSheet: Identifiable {
    let id = UUID()
    let cards: [GuideCard]
    let isWelcome: Bool
}

struct HiveGuideLaunch: ViewModifier {
    let guide: Guide?
    let options: HiveGuideOptions
    let defaults: UserDefaults
    @State private var ran = false
    @State private var sheet: GuideLaunchSheet?

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !ran else { return }
                ran = true
                let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
                let shown = GuideLaunch.take(guide: guide, build: build, defaults: defaults, welcome: options.welcome)
                if !shown.cards.isEmpty { sheet = GuideLaunchSheet(cards: shown.cards, isWelcome: shown.isWelcome) }
            }
            .sheet(item: $sheet) { s in
                HiveWhatsNewView(title: s.isWelcome ? "Welcome" : "What's new", cards: s.cards)
            }
    }
}

public extension View {
    /// Shows "What's new" once after an update (cards changed since the last build seen), or, with
    /// `options.welcome`, the welcome cards once on first launch. Put it on the app's root view.
    func hiveGuideOnLaunch(_ guide: Guide? = .main, options: HiveGuideOptions = .init(),
                           defaults: UserDefaults = .standard) -> some View {
        modifier(HiveGuideLaunch(guide: guide, options: options, defaults: defaults))
    }
}

#Preview("Guide") {
    HiveGuideView(guide: Guide(cards: [
        GuideCard(id: "add", title: "How do I add a repo?", steps: ["Open the ☰ menu", "Tap Repos", "Tap Add", "Pick the repo"],
                  screen: "repos", changed: "20261111.0814"),
        GuideCard(id: "why", title: "How do I see why my score dropped?", steps: ["Tap the score", "Read the top fixes", "Tap a fix for its steps"],
                  screen: "score", changed: "20261111.0814"),
        GuideCard(id: "sign", title: "How do I sign in again?", steps: ["Open Settings", "Tap Sign in", "Enter the code GitHub shows"],
                  screen: "settings", changed: "20261111.0814"),
        GuideCard(id: "widget", title: "How do I add the widget?", steps: ["Touch and hold the Home Screen", "Tap Edit, then Add Widget", "Pick the app"],
                  screen: "score", changed: "20261111.0814"),
    ]))
}

#Preview("What's new, 8 cards") {
    HiveWhatsNewView(title: "What's new", cards: (1...8).map {
        GuideCard(id: "c\($0)", title: "How do I use change \($0)?", steps: ["Open the page", "Tap the new button", "Read the result"],
                  screen: "home", changed: "20261111.0814")
    })
}
#endif
