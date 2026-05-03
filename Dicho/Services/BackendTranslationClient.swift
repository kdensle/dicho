import Foundation

struct BackendTranslationClient: TranslationClient {
    var baseURL: URL
    var session: URLSession = .shared

    func translate(message: String, context: MessageContext) async throws -> TranslationResult {
        let url = baseURL.appendingPathComponent("v1/translate")
        let payload = BackendTranslationRequest(
            message: message,
            country: context.country.rawValue,
            countryDisplayName: context.country.displayName,
            clientID: InstallationIdentity.current,
            entitlementJWS: await EntitlementToken.currentProJWS()
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfiguration.clientVersionHeader, forHTTPHeaderField: "X-Dicho-Client-Version")
        request.setValue(InstallationIdentity.current, forHTTPHeaderField: "X-Dicho-Install-ID")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let errorEnvelope = try? JSONDecoder().decode(BackendErrorEnvelope.self, from: data) {
                if httpResponse.statusCode == 402 || errorEnvelope.error == "free_limit_reached" {
                    throw TranslationClientError.usageLimitReached(errorEnvelope.displayMessage)
                }

                if httpResponse.statusCode == 429 || errorEnvelope.error == "rate_limited" {
                    throw TranslationClientError.rateLimited(errorEnvelope.displayMessage)
                }

                throw TranslationClientError.api(errorEnvelope.displayMessage)
            }

            throw TranslationClientError.api("dicho server request failed with status \(httpResponse.statusCode).")
        }

        do {
            return try JSONDecoder().decode(TranslationResult.self, from: data)
        } catch {
            throw TranslationClientError.decoding("Could not read the server translation result.")
        }
    }
}

private struct BackendTranslationRequest: Encodable {
    var message: String
    var country: String
    var countryDisplayName: String
    var clientID: String
    var entitlementJWS: String?
}

private struct BackendErrorEnvelope: Decodable {
    var error: String?
    var message: String?
    var freeTranslationsRemaining: Int?

    var displayMessage: String {
        message ?? error ?? "dicho server request failed."
    }
}
