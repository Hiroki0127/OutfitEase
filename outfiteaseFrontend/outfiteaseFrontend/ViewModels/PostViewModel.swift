import Foundation
import SwiftUI

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let postService = PostService.shared
    

    
    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await postService.getPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadUserPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await postService.getUserPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createPost(_ post: CreatePostRequest) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPost = try await postService.createPost(post)
            posts.insert(newPost, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createPostFromOutfit(outfit: Outfit, caption: String) async throws {
        let createPostRequest = CreatePostRequest(outfitId: outfit.id, caption: caption)
        let newPost = try await postService.createPost(createPostRequest)
        posts.insert(newPost, at: 0)
        
        // Update nearby posts (before and after this index) with avatar URL from current user
        if let index = posts.firstIndex(where: { $0.id == newPost.id }) {
            let currentId = newPost.userId
            for offset in [-1, 1] {
                let neighborIndex = index + offset
                guard posts.indices.contains(neighborIndex) else { continue }
                if posts[neighborIndex].userId == currentId {
                    posts[neighborIndex].avatarURL = AuthService.shared.getCurrentUser()?.avatarUrl
                }
            }
        }
    }
    
    func deletePost(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await postService.deletePost(id: id)
            posts.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    

}

struct CreatePostRequest: Codable {
    let outfitId: UUID
    let caption: String?
}
