import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    let avatarUrl: String?
    let createdAt: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case role
    }
}