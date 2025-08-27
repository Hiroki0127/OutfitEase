import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
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
}
