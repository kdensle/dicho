import Combine
import Foundation

@MainActor
final class TranslationViewModel: ObservableObject {
    static let maxInputCharacters = 4000

    @Published var inputText = ""
    @Published var selectedCountry: SpanishCountry = .mexico
    @Published private(set) var result: TranslationResult?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var clipboardMessage: String?
    @Published var requiresUpgrade = false

    private let keychain = KeychainStore()

    var canSubmit: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && !isInputTooLong
    }

    var inputCharacterCount: Int {
        inputText.count
    }

    var charactersRemaining: Int {
        Self.maxInputCharacters - inputCharacterCount
    }

    var isInputTooLong: Bool {
        inputCharacterCount > Self.maxInputCharacters
    }

    @discardableResult
    func submit(model: String) async -> Bool {
        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else {
            return false
        }

        guard !isInputTooLong else {
            errorMessage = "Messages can be up to \(Self.maxInputCharacters) characters."
            AppHaptics.warning()
            return false
        }

        isLoading = true
        errorMessage = nil
        clipboardMessage = nil
        requiresUpgrade = false

        let context = MessageContext(country: selectedCountry)

        do {
            let client = try makeClient(model: model)
            let translation = try await client.translate(message: message, context: context)
            result = translation
            AppClipboard.copy(translation.translation)
            clipboardMessage = "Copied automatically"
            isLoading = false
            AppHaptics.success()
            return true
        } catch {
            if let clientError = error as? TranslationClientError,
               case TranslationClientError.usageLimitReached(let message) = clientError {
                requiresUpgrade = true
                errorMessage = message
                AppHaptics.warning()
            } else if let clientError = error as? TranslationClientError,
                      case TranslationClientError.rateLimited(let message) = clientError {
                errorMessage = message
                AppHaptics.warning()
            } else if let urlError = error as? URLError {
                errorMessage = Self.message(for: urlError)
                AppHaptics.error()
            } else {
                errorMessage = error.localizedDescription
                AppHaptics.error()
            }
        }

        isLoading = false
        return false
    }

    private func makeClient(model: String) throws -> any TranslationClient {
        #if DEBUG
        if let apiKey = keychain.readAPIKey(), !apiKey.isEmpty {
            return OpenAITranslationClient(apiKey: apiKey, model: model)
        }
        #endif

        guard let backendBaseURL = AppConfiguration.backendBaseURL else {
            #if DEBUG
            throw TranslationClientError.api("Add your API key in Settings or configure DICHO_API_BASE_URL.")
            #else
            throw TranslationClientError.api("dicho server is not configured for this build.")
            #endif
        }

        return BackendTranslationClient(baseURL: backendBaseURL)
    }

    func paste() {
        guard let pastedText = AppClipboard.readText(), !pastedText.isEmpty else {
            clipboardMessage = "Clipboard is empty"
            return
        }

        inputText = pastedText
        result = nil
        errorMessage = nil
        clipboardMessage = "Pasted"
        AppHaptics.lightImpact()
    }

    func copyOutput() {
        guard let output = result?.translation, !output.isEmpty else {
            clipboardMessage = "Nothing to copy yet"
            return
        }

        AppClipboard.copy(output)
        clipboardMessage = "Copied"
        AppHaptics.success()
    }

    func clear() {
        inputText = ""
        result = nil
        errorMessage = nil
        clipboardMessage = nil
        requiresUpgrade = false
        AppHaptics.lightImpact()
    }

    private static func message(for urlError: URLError) -> String {
        switch urlError.code {
        case .notConnectedToInternet:
            "You appear to be offline. Check your connection and try again."
        case .timedOut:
            "The request timed out. Try again in a moment."
        case .cannotFindHost, .cannotConnectToHost, .networkConnectionLost:
            "dicho could not reach the translation server. Try again in a moment."
        default:
            urlError.localizedDescription
        }
    }
}
