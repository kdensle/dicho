import SwiftUI

struct ResultView: View {
    let result: TranslationResult
    var copyAction: () -> Void
    var clipboardMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppStyle.warmAccent)
                    .frame(width: 5, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(result.directionLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppStyle.warmAccent)
                        .textCase(.uppercase)

                    Text("Translation")
                        .font(.title2.weight(.semibold))
                }

                Spacer()

                Button(action: copyAction) {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                }
                .buttonStyle(.plain)
                .background(AppStyle.primaryAccent.opacity(0.10))
                .foregroundStyle(AppStyle.primaryAccent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Copy translation")
            }

            Text(result.translation)
                .font(.title3.weight(.medium))
                .lineSpacing(4)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(
                    LinearGradient(
                        colors: [
                            AppStyle.primaryAccent.opacity(0.11),
                            AppStyle.warmAccent.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 8) {
                Tag(text: result.sourceLanguage, systemImage: "text.bubble")
                Tag(text: result.confidence, systemImage: "checkmark.seal")

                if let clipboardMessage {
                    Tag(text: clipboardMessage, systemImage: "doc.on.clipboard")
                }
            }

            if !result.nuance.isEmpty {
                Text(result.nuance)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            if !result.countryNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Notes", systemImage: "map")
                        .font(.subheadline.weight(.semibold))

                    ForEach(result.countryNotes, id: \.self) { note in
                        Bullet(text: note)
                    }
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .cardSurface()
    }
}

private struct Tag: View {
    var text: String
    var systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppStyle.primaryAccent.opacity(0.10))
            .foregroundStyle(AppStyle.primaryAccent)
            .clipShape(Capsule())
    }
}

private struct Bullet: View {
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "smallcircle.filled.circle")
                .font(.caption2)
                .foregroundStyle(AppStyle.warmAccent)
                .padding(.top, 5)

            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ResultView(result: .sample, copyAction: {}, clipboardMessage: "Copied automatically")
                .padding()
        }
        .background(AppStyle.groupedBackground)
    }
}
