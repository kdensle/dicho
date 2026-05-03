import Foundation

enum AppConfiguration {
    enum ScreenshotScenario: String {
        case home
        case result
        case paywall
        case settings
    }

    static var backendBaseURL: URL? {
        guard
            let rawValue = Bundle.main.object(forInfoDictionaryKey: "DICHO_API_BASE_URL") as? String,
            !rawValue.isEmpty,
            !rawValue.hasPrefix("$(")
        else {
            return nil
        }

        return URL(string: rawValue)
    }

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    static var clientVersionHeader: String {
        "dicho-ios/\(appVersion) (\(buildNumber))"
    }

    static var screenshotScenario: ScreenshotScenario? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let markerIndex = arguments.firstIndex(of: "--dicho-screenshot") else {
            return nil
        }

        let scenarioIndex = arguments.index(after: markerIndex)
        guard arguments.indices.contains(scenarioIndex) else {
            return .home
        }

        return ScreenshotScenario(rawValue: arguments[scenarioIndex]) ?? .home
    }

    static var isScreenshotMode: Bool {
        screenshotScenario != nil
    }

    static var isReleaseBuild: Bool {
        #if DEBUG
        false
        #else
        true
        #endif
    }
}
