import SwiftUI

struct RootView: View {
    @AppStorage("acceptedLegalVersion") private var acceptedLegalVersion = ""
    @AppStorage("acceptedLegalDate") private var acceptedLegalDate = ""

    var body: some View {
        if acceptedLegalVersion == LegalDocument.currentVersion {
            ContentView()
        } else {
            LegalAcceptanceView {
                acceptedLegalVersion = LegalDocument.currentVersion
                acceptedLegalDate = Date().ISO8601Format()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(SubscriptionManager())
            .environmentObject(UsageMeter())
    }
}
