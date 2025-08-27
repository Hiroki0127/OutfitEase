import Foundation

struct Comment: Codable, Identifiable, Equatable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let comment: String
    let createdAt: String
    let parentCommentId: UUID? // For replies
    let replies: [Comment]? // Nested replies
    let username: String? // Username for display
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case comment
        case createdAt = "created_at"
        case parentCommentId = "parent_comment_id"
        case replies
        case username
    }
    
    // Regular initializer for creating instances
    init(id: UUID, postId: UUID, userId: UUID, comment: String, createdAt: String, parentCommentId: UUID?, replies: [Comment]?, username: String?) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.comment = comment
        self.createdAt = createdAt
        self.parentCommentId = parentCommentId
        self.replies = replies
        self.username = username
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        postId = try container.decode(UUID.self, forKey: .postId)
        userId = try container.decode(UUID.self, forKey: .userId)
        comment = try container.decode(String.self, forKey: .comment)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        parentCommentId = try container.decodeIfPresent(UUID.self, forKey: .parentCommentId)
        replies = try container.decodeIfPresent([Comment].self, forKey: .replies)
        username = try container.decodeIfPresent(String.self, forKey: .username)
    }
}
