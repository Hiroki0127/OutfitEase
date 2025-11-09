import Foundation

struct Post: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let username: String
    var avatarURL: String?
    let caption: String
    let imageURL: String?
    let createdAt: String
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    let outfitId: UUID?
    let outfit: Outfit?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case username
        case avatarURL = "avatar_url"
        case caption
        case imageURL = "image_url"
        case createdAt = "created_at"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case isLiked = "is_liked"
        case outfitId = "outfit_id"
        case outfit
    }
    
    // Regular initializer for creating instances
    init(id: UUID, userId: UUID, username: String, avatarURL: String?, caption: String, imageURL: String?, createdAt: String, likeCount: Int, commentCount: Int, isLiked: Bool, outfitId: UUID?, outfit: Outfit?) {
        self.id = id
        self.userId = userId
        self.username = username
        self.avatarURL = avatarURL
        self.caption = caption
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
        self.outfitId = outfitId
        self.outfit = outfit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        username = try container.decode(String.self, forKey: .username)
        avatarURL = try container.decodeIfPresent(String.self, forKey: .avatarURL)
        caption = try container.decode(String.self, forKey: .caption)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
        outfitId = try container.decodeIfPresent(UUID.self, forKey: .outfitId)
        outfit = try container.decodeIfPresent(Outfit.self, forKey: .outfit)
    }
}
