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
    
    func loadPosts(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await postService.getPosts(for: userId)
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
