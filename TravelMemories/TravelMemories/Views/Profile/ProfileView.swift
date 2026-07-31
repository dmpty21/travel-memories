import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Your Profile",
                systemImage: "person.crop.circle",
                description: Text("Profile settings are coming soon.")
            )
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
