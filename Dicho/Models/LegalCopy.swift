import Foundation

enum LegalDocument: String, CaseIterable, Identifiable {
    case privacy
    case terms

    static let currentVersion = "2026-05-03"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacy: "Privacy Policy"
        case .terms: "Terms of Use"
        }
    }

    var summary: String {
        switch self {
        case .privacy: "How message text, usage, and subscriptions are handled."
        case .terms: "Subscription, acceptable use, and AI output terms."
        }
    }

    var systemImage: String {
        switch self {
        case .privacy: "hand.raised"
        case .terms: "doc.text"
        }
    }

    var body: String {
        switch self {
        case .privacy:
            """
            Effective date: May 3, 2026

            dicho helps translate English and Spanish messages and produce more natural phrasing for selected Spanish-speaking countries.

            Information we process
            - Message text you enter is sent to dicho's translation server and OpenAI only when you submit it for translation.
            - Your selected country is sent with the message so the translation can reflect local phrasing.
            - A random installation ID may be sent to manage free monthly usage, rate limits, abuse prevention, and service reliability.
            - Usage counts are stored locally on your device and may be checked by dicho's server to manage the free monthly translation limit.
            - Purchases and subscription status are handled by Apple through StoreKit.

            How information is used
            - Message text is used to generate a translation or suggested phrasing.
            - Usage counts are used to decide whether the free monthly limit has been reached.
            - The installation ID is used for usage limits, rate limiting, fraud prevention, and service reliability.
            - Subscription status is used to unlock dicho pro.

            Third-party services
            - OpenAI processes message text to provide AI translation.
            - Apple processes in-app purchases, subscriptions, and related payment information.

            Data retention
            - dicho does not create an account or store message history in the app.
            - dicho's backend does not intentionally log raw message text.
            - Message text may be processed by OpenAI under OpenAI's API data handling terms.
            - Local settings can be removed by deleting the app.

            Your choices
            - Do not enter messages that contain sensitive personal information unless you are comfortable sending them for AI processing.
            - You can manage or cancel subscriptions in your Apple Account subscription settings.
            - Because dicho does not currently create user accounts, deleting the app removes local app settings from your device.

            Contact
            For privacy questions, contact the developer at support@dicho.app.
            """
        case .terms:
            """
            Effective date: May 3, 2026

            These Terms of Use govern your use of dicho.

            Service
            dicho provides AI-assisted English and Spanish translation for private messages. Translations are generated automatically and may be imperfect. You are responsible for reviewing any output before sending it.

            Subscriptions
            dicho includes a free monthly translation allowance. After the free allowance is used, continued translation access requires an active dicho pro subscription.

            dicho pro is an auto-renewable monthly subscription purchased through Apple. The subscription renews automatically unless canceled at least 24 hours before the end of the current period. Your Apple Account is charged at confirmation of purchase and at renewal. You can manage or cancel the subscription in your Apple Account subscription settings.

            Acceptable use
            You agree not to use dicho to create unlawful, harmful, harassing, deceptive, or abusive content. You also agree not to reverse engineer the app or interfere with its operation.

            AI output
            AI-generated translations can contain errors, omissions, or wording that is not appropriate for every context. dicho is not a substitute for professional translation, legal advice, medical advice, financial advice, or emergency communication.

            Availability
            The service may be interrupted by network issues, Apple services, OpenAI services, or maintenance. Features, limits, pricing, and availability may change over time.

            Apple terms
            Your app download and in-app purchases are also subject to Apple's applicable App Store terms and purchase rules.

            Privacy
            Please review the Privacy Policy to understand how information is processed.

            Contact
            For support questions, contact support@dicho.app.
            """
        }
    }
}
