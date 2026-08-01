import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [Profile]

    @State private var isPresentingRename = false
    @State private var isPresentingImport = false
    @State private var editedName = ""

    private var profile: Profile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.atlasAccent600)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile?.name ?? "Traveler")
                                .font(.title3.weight(.semibold))
                            Text("Tap to edit your name")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editedName = profile?.name ?? ""
                        isPresentingRename = true
                    }
                }

                Section {
                    Button {
                        isPresentingImport = true
                    } label: {
                        Label("Import Trip Data", systemImage: "square.and.arrow.down")
                    }
                } footer: {
                    Text("Bulk-add places, trips, and recommendations from a CSV file.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.atlasGround)
            .navigationTitle("Profile")
            .sheet(isPresented: $isPresentingRename) {
                RenameProfileSheet(name: $editedName) {
                    profile?.name = editedName.trimmingCharacters(in: .whitespaces)
                }
            }
            .sheet(isPresented: $isPresentingImport) {
                ImportTripDataView()
            }
        }
    }
}

private struct RenameProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    var onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Your name", text: $name)
            }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [Profile.self, Place.self, Recommendation.self, Trip.self, TripItem.self], inMemory: true)
}
