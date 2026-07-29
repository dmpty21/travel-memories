import Foundation

enum PexelsService {
    struct SearchResponse: Decodable {
        let photos: [Photo]
    }

    struct Photo: Decodable {
        let src: Source
        let photographer: String
        let url: String
    }

    struct Source: Decodable {
        let large: String
        let large2x: String
    }

    enum PexelsError: Error {
        case invalidURL
        case noResults
    }

    static func searchPhoto(query: String) async throws -> Photo {
        var components = URLComponents(string: "https://api.pexels.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: "1"),
            URLQueryItem(name: "orientation", value: "landscape")
        ]
        guard let url = components?.url else { throw PexelsError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue(Secrets.pexelsAPIKey, forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        guard let photo = response.photos.first else { throw PexelsError.noResults }
        return photo
    }
}
