import SwiftUI

@main
struct DichoApp: App {
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var usageMeter = UsageMeter()

    init() {
        guard AppConfiguration.isScreenshotMode else {
            return
        }

        UserDefaults.standard.set(AppTheme.dark.rawValue, forKey: "appTheme")
        UserDefaults.standard.set(LegalDocument.currentVersion, forKey: "acceptedLegalVersion")
        UserDefaults.standard.set("2026-05-03T09:41:00Z", forKey: "acceptedLegalDate")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(subscriptionManager)
                .environmentObject(usageMeter)
                .preferredColorScheme(AppTheme(rawValue: appTheme)?.colorScheme)
        }
    }
}
