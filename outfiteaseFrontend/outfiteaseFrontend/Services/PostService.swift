
import Foundation

class PostService {
    static let shared = PostService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func getPosts() async throws -> [Post] {
        return try await apiService.request(endpoint: Constants.API.posts)
    }
    
    func getUserPosts() async throws -> [Post] {
        return try await apiService.request(endpoint: Constants.API.posts + "/user")
    }
    
    func getPosts(for userId: String) async throws -> [Post] {
        return try await apiService.request(endpoint: Constants.API.posts + "/user/\(userId)")
    }
    
    func getPost(id: UUID) async throws -> Post {
        return try await apiService.request(endpoint: Constants.API.posts + "/\(id)")
    }
    
    func createPost(_ post: CreatePostRequest) async throws -> Post {
        let body = try JSONEncoder().encode(post)
        return try await apiService.request(
            endpoint: Constants.API.posts,
            method: .POST,
            body: body
        )
    }
    
    func deletePost(id: UUID) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.posts + "/\(id)",
            method: .DELETE
        )
    }
    
    // ✅ Get liked posts
    func getLikedPosts() async throws -> [LikedPost] {
        return try await apiService.request(endpoint: Constants.API.likes + "/posts")
    }
    
    // ✅ Like a post
    func likePost(postId: String) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.likes + "/posts/\(postId)",
            method: .POST
        )
    }
    
    // ✅ Unlike a post
    func unlikePost(postId: String) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.likes + "/posts/\(postId)",
            method: .DELETE
        )
    }
}

struct LikedPost: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let outfitId: UUID?
    let caption: String?
    let createdAt: String
    let username: String
    let avatarUrl: String?
    let outfitName: String?
    let outfitImageUrl: String?
    let likesCount: Int
    let commentsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case outfitId = "outfit_id"
        case caption
        case createdAt = "created_at"
        case username
        case avatarUrl = "avatar_url"
        case outfitName = "outfit_name"
        case outfitImageUrl = "outfit_image_url"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
    }
}
