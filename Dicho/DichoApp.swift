import SwiftUI

@main
struct DichoApp: App {
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var usageMeter = UsageMeter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(subscriptionManager)
                .environmentObject(usageMeter)
                .preferredColorScheme(AppTheme(rawValue: appTheme)?.colorScheme)
        }
    }
}
