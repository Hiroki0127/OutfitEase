import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var postCount: Int = 0
    @Published var outfitCount: Int = 0
    
    private let authService = AuthService.shared
    private let userService = UserService.shared
    
    init() {
        currentUser = authService.getCurrentUser()
    }
    
    func logout() {
        authService.logout()
        currentUser = nil
    }
    
    func refreshUserData() {
        currentUser = authService.getCurrentUser()
    }
    
    func updateProfile(username: String? = nil, avatarUrl: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedUser = try await authService.updateProfile(username: username, avatarUrl: avatarUrl)
            currentUser = updatedUser
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadProfileDetails() async {
        guard let userId = currentUser?.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await userService.getPublicProfile(userId: userId)
            
            followerCount = response.stats.followerCount
            followingCount = response.stats.followingCount
            postCount = response.stats.postCount
            outfitCount = response.stats.outfitCount
            
            let updatedUser = User(
                id: response.user.id,
                email: response.user.email,
                username: response.user.username,
                avatarUrl: response.user.avatarUrl,
                createdAt: response.user.createdAt,
                role: response.user.role
            )
            
            currentUser = updatedUser
            
            if let userData = try? JSONEncoder().encode(updatedUser) {
                UserDefaults.standard.set(userData, forKey: Constants.UserDefaults.currentUser)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

@MainActor
class PublicProfileViewModel: ObservableObject {
    @Published var profile: PublicProfileResponse?
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var isFollowActionInProgress = false
    @Published var errorMessage: String?
    
    private let userService = UserService.shared
    private let postService = PostService.shared
    private let authService = AuthService.shared
    private var userId: String?
    
    var isCurrentUser: Bool {
        profile?.isSelf ?? false
    }
    
    var currentViewerId: String? {
        authService.getCurrentUser()?.id
    }
    
    func loadProfile(userId: String) async {
        self.userId = userId
        isLoading = true
        errorMessage = nil
        
        do {
            async let profileTask = userService.getPublicProfile(userId: userId)
            async let postsTask: [Post] = postService.getPosts(for: userId)
            
            let (profileResponse, userPosts) = try await (profileTask, postsTask)
            
            self.profile = profileResponse
            self.posts = userPosts
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func refreshPosts() async {
        guard let userId = userId else { return }
        
        do {
            posts = try await postService.getPosts(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleFollow() async {
        guard let userId = userId,
              var currentProfile = profile,
              !currentProfile.isSelf else { return }
        
        isFollowActionInProgress = true
        errorMessage = nil
        
        do {
            let response: FollowActionResponse
            
            if currentProfile.isFollowing {
                response = try await userService.unfollow(userId: userId)
            } else {
                response = try await userService.follow(userId: userId)
            }
            
            currentProfile.isFollowing = response.isFollowing ?? !currentProfile.isFollowing
            currentProfile.stats.followerCount = response.stats.followerCount
            currentProfile.stats.followingCount = response.stats.followingCount
            
            profile = currentProfile
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isFollowActionInProgress = false
    }
}

enum FollowListType {
    case followers
    case following
    
    var title: String {
        switch self {
        case .followers: return "Followers"
        case .following: return "Following"
        }
    }
    
    var emptyMessage: String {
        switch self {
        case .followers: return "No followers yet"
        case .following: return "Not following anyone yet"
        }
    }
}

extension FollowListType: Identifiable {
    var id: String { title }
}

@MainActor
class FollowListViewModel: ObservableObject {
    @Published var users: [FollowListUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userService = UserService.shared
    
    func load(type: FollowListType, userId: String) async {
        guard !userId.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            switch type {
            case .followers:
                users = try await userService.getFollowers(userId: userId)
            case .following:
                users = try await userService.getFollowing(userId: userId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
