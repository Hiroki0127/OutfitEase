import Foundation

struct ClothingItem: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let type: String?
    let color: String?
    let style: String?
    let brand: String?
    let price: Double?
    let season: [String]?
    let occasion: [String]?
    let imageUrl: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case type
        case color
        case style
        case brand
        case price
        case season
        case occasion
        case imageUrl = "image_url"
        case createdAt = "created_at"
    }
}
