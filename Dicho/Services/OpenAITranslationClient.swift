import Foundation

protocol TranslationClient {
    func translate(message: String, context: MessageContext) async throws -> TranslationResult
}

struct OpenAITranslationClient: TranslationClient {
    var apiKey: String
    var model: String
    var session: URLSession = .shared

    func translate(message: String, context: MessageContext) async throws -> TranslationResult {
        guard let url = URL(string: "https://api.openai.com/v1/responses") else {
            throw TranslationClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody(message: message, context: context))

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranslationClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let errorEnvelope = try? JSONDecoder().decode(OpenAIErrorEnvelope.self, from: data) {
                throw TranslationClientError.api(errorEnvelope.error.message)
            }
            throw TranslationClientError.api("OpenAI request failed with status \(httpResponse.statusCode).")
        }

        let apiResponse = try JSONDecoder().decode(ResponsesAPIResponse.self, from: data)
        if let apiError = apiResponse.error {
            throw TranslationClientError.api(apiError.message)
        }

        guard let outputText = apiResponse.outputText else {
            throw TranslationClientError.missingOutput
        }

        guard let resultData = outputText.data(using: .utf8) else {
            throw TranslationClientError.invalidOutput
        }

        do {
            return try JSONDecoder().decode(TranslationResult.self, from: resultData)
        } catch {
            throw TranslationClientError.decoding("Could not read the structured translation result.")
        }
    }

    private func requestBody(message: String, context: MessageContext) -> [String: Any] {
        [
            "model": model,
            "instructions": PromptBuilder.instructions,
            "input": PromptBuilder.userInput(message: message, context: context),
            "max_output_tokens": 700,
            "text": [
                "format": [
                    "type": "json_schema",
                    "name": "dicho_translation",
                    "strict": true,
                    "schema": Self.outputSchema
                ]
            ]
        ]
    }

    private static let outputSchema: [String: Any] = [
        "type": "object",
        "additionalProperties": false,
        "required": [
            "sourceLanguage",
            "targetLanguage",
            "directionLabel",
            "translation",
            "nuance",
            "countryNotes",
            "confidence"
        ],
        "properties": [
            "sourceLanguage": [
                "type": "string",
                "description": "The detected source language, such as English, Spanish, Mixed, or Unknown."
            ],
            "targetLanguage": [
                "type": "string",
                "description": "The language translated into, usually English or Spanish."
            ],
            "directionLabel": [
                "type": "string",
                "description": "A short label like English -> Mexican Spanish or Spanish -> English."
            ],
            "translation": [
                "type": "string",
                "description": "The primary translation to show and copy."
            ],
            "nuance": [
                "type": "string",
                "description": "A concise explanation of tone, idiom, or why the translation is natural."
            ],
            "countryNotes": [
                "type": "array",
                "items": ["type": "string"],
                "description": "Country-specific notes. Return an empty array when none are needed."
            ],
            "confidence": [
                "type": "string",
                "description": "A concise confidence label such as High, Medium, or Low with uncertainty if needed."
            ]
        ]
    ]
}

enum TranslationClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case missingOutput
    case invalidOutput
    case api(String)
    case decoding(String)
    case usageLimitReached(String)
    case rateLimited(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The OpenAI endpoint URL is invalid."
        case .invalidResponse:
            "The server returned an invalid response."
        case .missingOutput:
            "The model did not return any text."
        case .invalidOutput:
            "The model returned text that could not be read."
        case .api(let message):
            message
        case .decoding(let message):
            message
        case .usageLimitReached(let message):
            message
        case .rateLimited(let message):
            message
        }
    }
}

private struct ResponsesAPIResponse: Decodable {
    var output: [OutputItem]?
    var error: OpenAIAPIError?

    var outputText: String? {
        output?
            .flatMap { $0.content ?? [] }
            .compactMap(\.text)
            .joined()
    }
}

private struct OutputItem: Decodable {
    var content: [OutputContent]?
}

private struct OutputContent: Decodable {
    var text: String?
    var refusal: String?
}

private struct OpenAIErrorEnvelope: Decodable {
    var error: OpenAIAPIError
}

private struct OpenAIAPIError: Decodable {
    var message: String
}
