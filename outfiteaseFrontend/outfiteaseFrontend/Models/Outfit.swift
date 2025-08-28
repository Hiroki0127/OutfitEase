import Foundation

struct Outfit: Codable, Identifiable {
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
    let items: [ClothingItem]?
    
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
        case items
    }
    
    // Regular initializer for creating instances
    init(id: UUID, userId: UUID, name: String?, description: String?, totalPrice: Double?, style: [String]?, color: [String]?, brand: [String]?, season: [String]?, occasion: [String]?, imageURL: String?, createdAt: String, items: [ClothingItem]? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.totalPrice = totalPrice
        self.style = style
        self.color = color
        self.brand = brand
        self.season = season
        self.occasion = occasion
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.items = items
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
        
        // Handle totalPrice that might come as string or double
        if let totalPriceString = try container.decodeIfPresent(String.self, forKey: .totalPrice) {
            totalPrice = Double(totalPriceString)
        } else if let totalPriceDouble = try container.decodeIfPresent(Double.self, forKey: .totalPrice) {
            totalPrice = totalPriceDouble
        } else {
            totalPrice = nil
        }
        
        // Decode clothing items
        items = try container.decodeIfPresent([ClothingItem].self, forKey: .items)
    }
}
