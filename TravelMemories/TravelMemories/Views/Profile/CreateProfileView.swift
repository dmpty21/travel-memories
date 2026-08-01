import SwiftUI
import SwiftData

struct CreateProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var name: String = ""
    @FocusState private var isNameFieldFocused: Bool

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            PeaksMarkIcon(size: 88)

            VStack(spacing: 8) {
                Text("Welcome to Atlas")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.atlasText)
                Text("What should we call you?")
                    .foregroundStyle(Color.atlasNeutral500)
            }

            TextField("Your name", text: $name)
                .textFieldStyle(.plain)
                .font(.title3)
                .multilineTextAlignment(.center)
                .focused($isNameFieldFocused)
                .padding()
                .background(Color.atlasSurface, in: RoundedRectangle(cornerRadius: AtlasRadius.lg, style: .continuous))
                .padding(.horizontal, 32)
                .submitLabel(.done)
                .onSubmit(save)

            Spacer()

            Button(action: save) {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.atlasAccent, in: RoundedRectangle(cornerRadius: AtlasRadius.pill, style: .continuous))
            }
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.5)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.atlasGround)
        .onAppear { isNameFieldFocused = true }
    }

    private func save() {
        guard isValid else { return }
        let profile = Profile(name: name.trimmingCharacters(in: .whitespaces))
        modelContext.insert(profile)
    }
}

#Preview {
    CreateProfileView()
        .modelContainer(for: [Profile.self], inMemory: true)
}
