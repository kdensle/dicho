import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var usageMeter: UsageMeter
    @AppStorage("openAIModel") private var model = "gpt-5.4-mini"
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @AppStorage("acceptedLegalVersion") private var acceptedLegalVersion = ""
    @AppStorage("acceptedLegalDate") private var acceptedLegalDate = ""
    @State private var apiKey = ""
    @State private var statusMessage: String?
    @State private var selectedLegalDocument: LegalDocument?

    private let keychain = KeychainStore()

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Mode", selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                #if DEBUG
                Section("Developer") {
                    SecureField("API key", text: $apiKey)
                        .neverAutocapitalized()
                        .autocorrectionDisabled()

                    TextField("Model", text: $model)
                        .neverAutocapitalized()
                        .autocorrectionDisabled()

                    if let backendBaseURL = AppConfiguration.backendBaseURL {
                        LabeledContent("Fallback server", value: backendBaseURL.absoluteString)
                    }
                }
                #else
                Section("Server") {
                    LabeledContent("Environment", value: "Production")

                    if let backendBaseURL = AppConfiguration.backendBaseURL {
                        LabeledContent("Endpoint", value: backendBaseURL.host ?? backendBaseURL.absoluteString)
                    }
                }
                #endif

                Section("dicho pro") {
                    LabeledContent("Status", value: subscriptionManager.hasActiveSubscription ? "Active" : "Free")
                    LabeledContent("Free uses left", value: "\(usageMeter.remainingFreeUses)")

                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                            statusMessage = subscriptionManager.message
                        }
                    }

                    #if os(iOS)
                    Button("Manage Subscription") {
                        Task {
                            await AppSubscriptionActions.openManageSubscriptions()
                        }
                    }
                    #endif
                }

                Section("Legal") {
                    LabeledContent("Accepted", value: acceptedLegalVersion.isEmpty ? "Not yet" : acceptedLegalVersion)

                    if !acceptedLegalDate.isEmpty {
                        LabeledContent("Accepted on", value: acceptedLegalDate)
                    }

                    ForEach(LegalDocument.allCases) { document in
                        Button(document.title) {
                            selectedLegalDocument = document
                        }
                    }
                }

                if let statusMessage {
                    Section {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                #if DEBUG
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
                #else
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                #endif
            }
            .onAppear {
                #if DEBUG
                apiKey = keychain.readAPIKey() ?? ""
                #endif
            }
            .sheet(item: $selectedLegalDocument) { document in
                NavigationStack {
                    LegalView(document: document)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    selectedLegalDocument = nil
                                }
                            }
                        }
                }
            }
        }
    }

    private func save() {
        #if DEBUG
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            if trimmedKey.isEmpty {
                try keychain.deleteAPIKey(allowMissing: true)
            } else {
                try keychain.saveAPIKey(trimmedKey)
            }

            statusMessage = "Saved"
            dismiss()
        } catch {
            statusMessage = error.localizedDescription
        }
        #else
        dismiss()
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SubscriptionManager())
            .environmentObject(UsageMeter())
    }
}
