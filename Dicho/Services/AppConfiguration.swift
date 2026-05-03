import Foundation

enum AppConfiguration {
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

    static var isReleaseBuild: Bool {
        #if DEBUG
        false
        #else
        true
        #endif
    }
}
