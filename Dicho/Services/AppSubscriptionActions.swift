import StoreKit
#if canImport(UIKit)
import UIKit
#endif

enum AppSubscriptionActions {
    @MainActor
    static func openManageSubscriptions() async {
        #if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        try? await AppStore.showManageSubscriptions(in: scene)
        #endif
    }
}
