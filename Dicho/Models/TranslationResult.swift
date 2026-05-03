import Foundation

struct TranslationResult: Codable, Equatable {
    var sourceLanguage: String
    var targetLanguage: String
    var directionLabel: String
    var translation: String
    var nuance: String
    var countryNotes: [String]
    var confidence: String
}

extension TranslationResult {
    static let sample = TranslationResult(
        sourceLanguage: "Spanish",
        targetLanguage: "English",
        directionLabel: "Spanish -> English",
        translation: "Don't worry, it's fine. We'll talk later.",
        nuance: "The message is reassuring and casual. It softens the situation rather than sounding dismissive.",
        countryNotes: [
            "No pasa nada can mean it is okay, not literally that nothing happened.",
            "Nos vemos al rato feels casual and local; it implies later today or soon."
        ],
        confidence: "High"
    )
}
