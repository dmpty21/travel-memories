import Foundation

extension Place {
    @MainActor
    func loadPhotoIfNeeded() async {
        guard photoURL == nil else { return }
        do {
            let photo = try await PexelsService.searchPhoto(query: "\(city) \(country) skyline")
            photoURL = photo.src.large2x
            photoPhotographer = photo.photographer
            photoPageURL = photo.url
        } catch {
            // Photo is a nice-to-have; fail silently if the lookup doesn't succeed.
        }
    }
}
