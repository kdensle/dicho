import SwiftUI

struct LegalAcceptanceView: View {
    var acceptAction: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("dicho")
                                .dichoWordmark(size: 44)
                                .foregroundStyle(AppStyle.primaryAccent)

                            Text("Before you continue")
                                .font(.title2.weight(.semibold))

                            Text("Please review and accept the Terms of Use and acknowledge the Privacy Policy.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }

                        VStack(spacing: 0) {
                            LegalRow(document: .terms)
                            Divider()
                                .padding(.leading, 48)
                            LegalRow(document: .privacy)
                        }
                        .cardSurface()

                        Text("By continuing, you agree to the Terms of Use and acknowledge that your message text is processed to provide translations.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                Button {
                    AppHaptics.success()
                    acceptAction()
                } label: {
                    Text("Agree and Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(TranslateButtonStyle())
                .padding()
                .background(AppStyle.groupedBackground)
            }
            .background(AppStyle.groupedBackground)
        }
    }
}

private struct LegalRow: View {
    var document: LegalDocument

    var body: some View {
        NavigationLink {
            LegalView(document: document)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: document.systemImage)
                    .font(.headline)
                    .foregroundStyle(AppStyle.primaryAccent)
                    .frame(width: 32, height: 32)
                    .background(AppStyle.primaryAccent.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(document.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(document.summary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }
}

struct LegalAcceptanceView_Previews: PreviewProvider {
    static var previews: some View {
        LegalAcceptanceView {}
    }
}
