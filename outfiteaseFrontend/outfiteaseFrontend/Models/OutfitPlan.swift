import Foundation

struct OutfitPlan: Codable, Identifiable {
    let id: String
    let userId: String
    let outfitId: String
    let plannedDate: String
    let title: String?
    
    // Outfit details (from JOIN query)
    let outfitName: String?
    let outfitDescription: String?
    let outfitStyle: [String]?
    let outfitColor: [String]?
    let outfitBrand: [String]?
    let outfitSeason: [String]?
    let outfitOccasion: [String]?
    let outfitTotalPrice: Double?
    let outfitImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case outfitId = "outfit_id"
        case plannedDate = "planned_date"
        case title
        // Outfit fields (these come directly from the outfits table)
        case outfitName = "name"
        case outfitDescription = "description"
        case outfitStyle = "style"
        case outfitColor = "color"
        case outfitBrand = "brand"
        case outfitSeason = "season"
        case outfitOccasion = "occasion"
        case outfitTotalPrice = "total_price"
        case outfitImageURL = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Planning fields - use decodeIfPresent for all fields to be more flexible
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
        plannedDate = try container.decodeIfPresent(String.self, forKey: .plannedDate) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title)
        
        // Outfit fields - these might not exist in all responses
        outfitId = try container.decodeIfPresent(String.self, forKey: .outfitId) ?? ""
        outfitName = try container.decodeIfPresent(String.self, forKey: .outfitName)
        outfitDescription = try container.decodeIfPresent(String.self, forKey: .outfitDescription)
        outfitStyle = try container.decodeIfPresent([String].self, forKey: .outfitStyle)
        outfitColor = try container.decodeIfPresent([String].self, forKey: .outfitColor)
        outfitBrand = try container.decodeIfPresent([String].self, forKey: .outfitBrand)
        outfitSeason = try container.decodeIfPresent([String].self, forKey: .outfitSeason)
        outfitOccasion = try container.decodeIfPresent([String].self, forKey: .outfitOccasion)
        outfitImageURL = try container.decodeIfPresent(String.self, forKey: .outfitImageURL)
        // Handle total_price as either String or Double
        if let totalPriceString = try container.decodeIfPresent(String.self, forKey: .outfitTotalPrice) {
            outfitTotalPrice = Double(totalPriceString)
        } else if let totalPriceDouble = try container.decodeIfPresent(Double.self, forKey: .outfitTotalPrice) {
            outfitTotalPrice = totalPriceDouble
        } else {
            outfitTotalPrice = nil
        }
    }
}
