import Foundation

@MainActor
class LikedPostsViewModel: ObservableObject {
    @Published var likedPosts: [LikedPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let postService = PostService.shared
    
    func loadLikedPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            likedPosts = try await postService.getLikedPosts()
        } catch {
            errorMessage = "Failed to load liked posts: \(error.localizedDescription)"
            print("Error loading liked posts: \(error)")
        }
        
        isLoading = false
    }
}
