import SwiftUI

struct LegalView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView {
            Text(document.body)
                .font(.body)
                .lineSpacing(4)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(AppStyle.groupedBackground)
        .navigationTitle(document.title)
        .compactNavigationTitle()
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LegalView(document: .privacy)
        }
    }
}
