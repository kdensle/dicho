import Foundation

enum SpanishCountry: String, CaseIterable, Codable, Identifiable {
    case mexico
    case spain
    case colombia
    case argentina
    case chile
    case peru
    case puertoRico
    case unitedStates

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mexico: "Mexico"
        case .spain: "Spain"
        case .colombia: "Colombia"
        case .argentina: "Argentina"
        case .chile: "Chile"
        case .peru: "Peru"
        case .puertoRico: "Puerto Rico"
        case .unitedStates: "U.S. Spanish"
        }
    }

    var promptGuidance: String {
        switch self {
        case .mexico:
            "Mexican Spanish. Prefer warm, clear phrasing. Use slang only when it genuinely fits the message."
        case .spain:
            "European Spanish from Spain. Use vosotros only when a native speaker would naturally use it."
        case .colombia:
            "Colombian Spanish. Keep warmth and politeness in mind; avoid overdoing regional slang."
        case .argentina:
            "Argentine Spanish. Use voseo naturally when appropriate, and avoid mixing it with Mexican or Caribbean wording."
        case .chile:
            "Chilean Spanish. Explain Chile-specific idioms when present; keep replies understandable and natural."
        case .peru:
            "Peruvian Spanish. Favor respectful, conversational phrasing; avoid forced slang."
        case .puertoRico:
            "Puerto Rican Spanish. Recognize Caribbean rhythm and idioms, but keep replies readable and context-sensitive."
        case .unitedStates:
            "Spanish used by bilingual speakers in the United States. Allow natural code-switching only when the user asks for it or the context strongly suggests it."
        }
    }
}
