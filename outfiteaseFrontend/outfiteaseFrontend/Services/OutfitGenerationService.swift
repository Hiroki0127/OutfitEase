import Foundation

class OutfitGenerationService {
    static let shared = OutfitGenerationService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func generateOutfits(filters: OutfitGenerationFilters) async throws -> [GeneratedOutfit] {
        let body = try JSONEncoder().encode(filters)
        return try await apiService.request(
            endpoint: "/outfit-generation/generate",
            method: .POST,
            body: body
        )
    }
    
    func generateWeatherBasedOutfits(weather: WeatherInfo) async throws -> [GeneratedOutfit] {
        let body = try JSONEncoder().encode(weather)
        return try await apiService.request(
            endpoint: "/outfit-generation/weather-based",
            method: .POST,
            body: body
        )
    }
    
    func getEventSuggestions(eventType: String) async throws -> [GeneratedOutfit] {
        return try await apiService.request(
            endpoint: "/outfit-generation/event/\(eventType)"
        )
    }
}

struct OutfitGenerationFilters: Codable {
    let eventType: String?
    let colors: [String]?
    let style: String?
    let useOwnedOnly: Bool
    let budget: Double?
    let weather: WeatherInfo?
}



struct GeneratedOutfit: Codable, Identifiable {
    let id: String
    let name: String
    let items: [ClothingItem]
    let totalPrice: Double
    let style: [String]
    let colors: [String]
    let estimatedCost: Double
} 