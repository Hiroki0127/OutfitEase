import Foundation

class CommentService {
    static let shared = CommentService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func getComments(postId: UUID) async throws -> [Comment] {
        return try await apiService.request(endpoint: Constants.API.comments + "/\(postId)")
    }
    
    func createComment(_ comment: CreateCommentRequest) async throws -> Comment {
        let body = try JSONEncoder().encode(comment)
        return try await apiService.request(
            endpoint: Constants.API.comments,
            method: .POST,
            body: body
        )
    }
    
    func deleteComment(id: UUID) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.comments + "/\(id)",
            method: .DELETE
        )
    }
    
    // Reply functionality
    func getReplies(commentId: UUID) async throws -> [Comment] {
        return try await apiService.request(endpoint: Constants.API.comments + "/\(commentId)/replies")
    }
    
    func addReply(_ reply: CreateReplyRequest) async throws -> Comment {
        let body = try JSONEncoder().encode(reply)
        return try await apiService.request(
            endpoint: Constants.API.comments + "/\(reply.parentCommentId)/replies",
            method: .POST,
            body: body
        )
    }
}

struct CreateCommentRequest: Codable {
    let postId: UUID
    let comment: String
}

struct CreateReplyRequest: Codable {
    let parentCommentId: UUID
    let comment: String
}
