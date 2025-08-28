import Foundation

class OutfitService {
    static let shared = OutfitService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func getOutfits() async throws -> [Outfit] {
        return try await apiService.request(endpoint: Constants.API.outfits)
    }
    
    func getOutfit(id: UUID) async throws -> Outfit {
        return try await apiService.request(endpoint: Constants.API.outfits + "/\(id)")
    }
    
    func createOutfit(_ outfit: CreateOutfitRequest) async throws -> Outfit {
        let body = try JSONEncoder().encode(outfit)
        
        let result: Outfit = try await apiService.request(
            endpoint: Constants.API.outfits,
            method: .POST,
            body: body
        )
        
        return result
    }
    
    func updateOutfit(id: UUID, _ outfit: UpdateOutfitRequest) async throws -> Outfit {
        let body = try JSONEncoder().encode(outfit)
        return try await apiService.request(
            endpoint: Constants.API.outfits + "/\(id)",
            method: .PUT,
            body: body
        )
    }
    
    func deleteOutfit(id: UUID) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.outfits + "/\(id)",
            method: .DELETE
        )
    }

    // ✅ Bulk delete multiple outfits
    func bulkDeleteOutfits(outfitIds: [String]) async throws -> BulkDeleteResponse {
        let request = BulkDeleteOutfitRequest(outfitIds: outfitIds)
        let body = try JSONEncoder().encode(request)
        
        return try await apiService.request(
            endpoint: Constants.API.outfits + "/bulk/delete",
            method: .DELETE,
            body: body
        )
    }
    
    // ✅ Get liked outfits
    func getLikedOutfits() async throws -> [LikedOutfit] {
        return try await apiService.request(endpoint: Constants.API.likes + "/outfits")
    }
    
    // ✅ Get saved outfits
    func getSavedOutfits() async throws -> [LikedOutfit] {
        return try await apiService.request(endpoint: Constants.API.savedOutfits)
    }
    
    // ✅ Like an outfit
    func likeOutfit(outfitId: String) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.likes + "/outfits/\(outfitId)",
            method: .POST
        )
    }
    
    // ✅ Unlike an outfit
    func unlikeOutfit(outfitId: String) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.likes + "/outfits/\(outfitId)",
            method: .DELETE
        )
    }
    
    // ✅ Save an outfit
    func saveOutfit(outfitId: String) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.savedOutfits + "/\(outfitId)",
            method: .POST
        )
    }
    
    // ✅ Unsave an outfit
    func unsaveOutfit(outfitId: String) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.savedOutfits + "/\(outfitId)",
            method: .DELETE
        )
    }
    
    // ✅ Check if an outfit is saved
    func checkSavedStatus(outfitId: String) async throws -> Bool {
        let response: SavedStatusResponse = try await apiService.request(
            endpoint: Constants.API.savedOutfits + "/\(outfitId)/status"
        )
        return response.isSaved
    }
    
    // ✅ Bulk unsave outfits
    func bulkUnsaveOutfits(outfitIds: [String]) async throws {
        let request = BulkDeleteOutfitRequest(outfitIds: outfitIds)
        let body = try JSONEncoder().encode(request)
        
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.savedOutfits + "/bulk/unsave",
            method: .DELETE,
            body: body
        )
    }
}

struct CreateOutfitRequest: Codable {
    let name: String?
    let description: String?
    let totalPrice: Double?
    let imageURL: String?
    let style: [String]?
    let color: [String]?
    let brand: [String]?
    let season: [String]?
    let occasion: [String]?
    let clothingItemIds: [String]?
}

struct UpdateOutfitRequest: Codable {
    let name: String?
    let description: String?
    let totalPrice: Double?
    let imageURL: String?
    let style: [String]?
    let color: [String]?
    let brand: [String]?
    let season: [String]?
    let occasion: [String]?
    let clothingItemIds: [String]?
}

// ✅ Bulk delete outfit request
struct BulkDeleteOutfitRequest: Codable {
    let outfitIds: [String]
}

struct SavedStatusResponse: Codable {
    let isSaved: Bool
}

struct LikedOutfit: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String?
    let description: String?
    let totalPrice: Double?
    let style: [String]?
    let color: [String]?
    let brand: [String]?
    let season: [String]?
    let occasion: [String]?
    let imageURL: String?
    let createdAt: String
    let username: String
    let avatarUrl: String?
    let likesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case totalPrice = "total_price"
        case style
        case color
        case brand
        case season
        case occasion
        case imageURL = "image_url"
        case createdAt = "created_at"
        case username
        case avatarUrl = "avatar_url"
        case likesCount = "likes_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        style = try container.decodeIfPresent([String].self, forKey: .style)
        color = try container.decodeIfPresent([String].self, forKey: .color)
        brand = try container.decodeIfPresent([String].self, forKey: .brand)
        season = try container.decodeIfPresent([String].self, forKey: .season)
        occasion = try container.decodeIfPresent([String].self, forKey: .occasion)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        username = try container.decode(String.self, forKey: .username)
        avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        
        // Handle totalPrice as either String or Double
        if let totalPriceString = try container.decodeIfPresent(String.self, forKey: .totalPrice) {
            totalPrice = Double(totalPriceString)
        } else if let totalPriceDouble = try container.decodeIfPresent(Double.self, forKey: .totalPrice) {
            totalPrice = totalPriceDouble
        } else {
            totalPrice = nil
        }
    }
}
