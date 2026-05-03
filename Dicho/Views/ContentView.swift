import StoreKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranslationViewModel()
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var usageMeter: UsageMeter
    @AppStorage("openAIModel") private var model = "gpt-5.4-mini"
    @FocusState private var inputIsFocused: Bool
    @State private var showsSettings = false
    @State private var showsPaywall = false
    @State private var didApplyScreenshotScenario = false
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if !usesCompactScreenshotResult {
                        header
                        usageBanner
                    }

                    translatorCard
                    statusSection

                    if let result = viewModel.result {
                        ResultView(
                            result: result,
                            copyAction: viewModel.copyOutput,
                            clipboardMessage: viewModel.clipboardMessage
                        )
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppStyle.groupedBackground)
            .navigationTitle("")
            .compactNavigationTitle()
            .tint(AppStyle.primaryAccent)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("dicho")
                        .dichoWordmark(size: 25)
                        .foregroundStyle(AppStyle.primaryAccent)
                }

                ToolbarItem(placement: settingsToolbarPlacement) {
                    Button {
                        showsSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showsSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showsPaywall) {
                PaywallView()
                    .environmentObject(subscriptionManager)
                    .environmentObject(usageMeter)
            }
            .task {
                await subscriptionManager.refreshEntitlements()
                usageMeter.resetIfNeeded()
            }
            .onAppear {
                applyScreenshotScenarioIfNeeded()
            }
            .onChange(of: viewModel.requiresUpgrade) { _, requiresUpgrade in
                if requiresUpgrade {
                    showsPaywall = true
                }
            }
        }
    }

    private var settingsToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }

    private var usesCompactScreenshotResult: Bool {
        AppConfiguration.screenshotScenario == .result
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppStyle.primaryAccent)
                Image(systemName: "sparkles")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text("dicho")
                    .dichoWordmark(size: 35)
                    .foregroundStyle(AppStyle.ink)

                Text("Natural Spanish-English")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    StatusPill(text: "Auto detect", systemImage: "wand.and.stars")
                    StatusPill(text: "Auto copy", systemImage: "doc.on.clipboard")
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .cardSurface()
    }

    private var usageBanner: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: subscriptionManager.hasActiveSubscription ? "checkmark.seal.fill" : "timer")
                .foregroundStyle(subscriptionManager.hasActiveSubscription ? AppStyle.primaryAccent : AppStyle.warmAccent)

            VStack(alignment: .leading, spacing: 3) {
                Text(subscriptionManager.hasActiveSubscription ? "dicho pro active" : "\(usageMeter.remainingFreeUses) free translations left")
                    .font(.subheadline.weight(.semibold))

                Text(subscriptionManager.hasActiveSubscription ? "Unlimited country-aware translations are unlocked." : "Free limit resets monthly. Upgrade when you need more.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if !subscriptionManager.hasActiveSubscription {
                Button("Upgrade") {
                    AppHaptics.lightImpact()
                    showsPaywall = true
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppStyle.primaryAccent)
            }
        }
        .padding(14)
        .cardSurface()
    }

    private var translatorCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Message", systemImage: "text.cursor")

            HStack(spacing: 10) {
                Menu {
                    Picker("Country", selection: $viewModel.selectedCountry) {
                        ForEach(SpanishCountry.allCases) { country in
                            Text(country.displayName).tag(country)
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "globe.americas")
                        Text(viewModel.selectedCountry.displayName)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                    }
                    .font(.headline)
                    .foregroundStyle(AppStyle.primaryAccent)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(AppStyle.primaryAccent.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                IconControl(systemImage: "doc.on.clipboard", label: "Paste") {
                    viewModel.paste()
                    inputIsFocused = true
                }

                IconControl(systemImage: "xmark", label: "Clear", isDestructive: true) {
                    viewModel.clear()
                }
            }

            TextField("Enter English or Spanish", text: $viewModel.inputText)
                .font(.title3)
                .lineLimit(1)
                .frame(height: 56)
                .padding(16)
                .background(AppStyle.secondaryGroupedBackground)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(inputIsFocused ? AppStyle.primaryAccent : Color.clear)
                        .frame(width: 3)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .sentenceAutocapitalization()
                .focused($inputIsFocused)
                .submitLabel(.go)
                .onSubmit {
                    submit()
                }

            HStack {
                if viewModel.isInputTooLong {
                    Label("Too long", systemImage: "exclamationmark.circle")
                        .foregroundStyle(AppStyle.warmAccent)
                } else {
                    Text("Auto-detects English or Spanish")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(viewModel.inputCharacterCount)/\(TranslationViewModel.maxInputCharacters)")
                    .foregroundStyle(viewModel.isInputTooLong ? AppStyle.warmAccent : .secondary)
            }
            .font(.caption.weight(.medium))

            Button {
                submit()
            } label: {
                Label(viewModel.isLoading ? "Translating" : "Translate", systemImage: "arrow.left.arrow.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .buttonStyle(TranslateButtonStyle())
            .disabled(!viewModel.canSubmit)
        }
        .padding(18)
        .cardSurface()
    }

    @ViewBuilder
    private var statusSection: some View {
        if viewModel.isLoading {
            HStack(spacing: 10) {
                ProgressView()
                Text("Translating and copying output")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .cardSurface()
        }

        if let errorMessage = viewModel.errorMessage {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.primary)
            }
            .padding()
            .background(Color.orange.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else if let clipboardMessage = viewModel.clipboardMessage, viewModel.result == nil {
            Label(clipboardMessage, systemImage: "doc.on.clipboard")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private func submit() {
        guard viewModel.canSubmit else {
            return
        }

        guard usageMeter.canTranslate(hasActiveSubscription: subscriptionManager.hasActiveSubscription) else {
            AppHaptics.warning()
            showsPaywall = true
            return
        }

        inputIsFocused = false
        Task {
            let succeeded = await viewModel.submit(model: model)
            if succeeded {
                usageMeter.recordSuccessfulTranslation(hasActiveSubscription: subscriptionManager.hasActiveSubscription)
                requestReviewIfEligible()
            }
        }
    }

    private static let reviewPromptThreshold = 5
    private static let reviewPromptedKey = "hasPromptedForReview"

    private func requestReviewIfEligible() {
        let defaults = UserDefaults.standard
        let lifetimeKey = "lifetimeSuccessfulTranslations"
        let count = defaults.integer(forKey: lifetimeKey) + 1
        defaults.set(count, forKey: lifetimeKey)

        guard count == Self.reviewPromptThreshold,
              !defaults.bool(forKey: Self.reviewPromptedKey) else {
            return
        }

        defaults.set(true, forKey: Self.reviewPromptedKey)
        requestReview()
    }

    private func applyScreenshotScenarioIfNeeded() {
        guard !didApplyScreenshotScenario, let scenario = AppConfiguration.screenshotScenario else {
            return
        }

        didApplyScreenshotScenario = true
        viewModel.applyScreenshotScenario(scenario)
        inputIsFocused = false

        switch scenario {
        case .home, .result:
            break
        case .paywall:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                showsPaywall = true
            }
        case .settings:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                showsSettings = true
            }
        }
    }
}

private struct IconControl: View {
    var systemImage: String
    var label: String
    var isDestructive: Bool
    var action: () -> Void

    init(systemImage: String, label: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.label = label
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(isDestructive ? AppStyle.warmAccent : AppStyle.primaryAccent)
                .frame(width: 44, height: 44)
                .background(AppStyle.secondaryGroupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct SectionHeader: View {
    var title: String
    var systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

private struct StatusPill: View {
    var text: String
    var systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(AppStyle.secondaryGroupedBackground)
            .foregroundStyle(.secondary)
            .clipShape(Capsule())
    }
}

struct TranslateButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? .white : .secondary)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [
                AppStyle.primaryAccent,
                AppStyle.primaryAccent.opacity(0.86)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEnabled ? Color.clear : Color.secondary.opacity(0.25), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.78 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SubscriptionManager())
            .environmentObject(UsageMeter())
    }
}
