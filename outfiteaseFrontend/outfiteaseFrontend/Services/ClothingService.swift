import Foundation

class ClothingService {
    static let shared = ClothingService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func getClothingItems() async throws -> [ClothingItem] {
        return try await apiService.request(endpoint: Constants.API.clothes)
    }
    
    func getClothingItem(id: String) async throws -> ClothingItem {
        return try await apiService.request(endpoint: Constants.API.clothes + "/\(id)")
    }
    
    func createClothingItem(_ item: CreateClothingItemRequest) async throws -> ClothingItem {
        let body = try JSONEncoder().encode(item)
        return try await apiService.request(
            endpoint: Constants.API.clothes,
            method: .POST,
            body: body
        )
    }
    
    func updateClothingItem(id: String, _ item: UpdateClothingItemRequest) async throws -> ClothingItem {
        let body = try JSONEncoder().encode(item)
        return try await apiService.request(
            endpoint: Constants.API.clothes + "/\(id)",
            method: .PUT,
            body: body
        )
    }
    
    func deleteClothingItem(id: String) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.clothes + "/\(id)",
            method: .DELETE
        )
    }

    // ✅ Bulk delete multiple clothing items
    func bulkDeleteClothingItems(itemIds: [String]) async throws -> BulkDeleteResponse {
        let request = BulkDeleteRequest(itemIds: itemIds)
        let body = try JSONEncoder().encode(request)
        
        return try await apiService.request(
            endpoint: Constants.API.clothes + "/bulk/delete",
            method: .DELETE,
            body: body
        )
    }
}

struct CreateClothingItemRequest: Codable {
    let name: String
    let type: String?
    let color: String?
    let style: String?
    let brand: String?
    let price: Double?
    let season: [String]?
    let occasion: [String]?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name, type, color, style, brand, price, season, occasion
        case imageUrl = "image_url"
    }
}

struct UpdateClothingItemRequest: Codable {
    let name: String?
    let type: String?
    let color: String?
    let style: String?
    let brand: String?
    let price: Double?
    let season: [String]?
    let occasion: [String]?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name, type, color, style, brand, price, season, occasion
        case imageUrl = "image_url"
    }
}

struct EmptyResponse: Codable {}

// ✅ Bulk delete request and response models
struct BulkDeleteRequest: Codable {
    let itemIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case itemIds
    }
}

struct BulkDeleteResponse: Codable {
    let message: String
    let deletedCount: Int
}
