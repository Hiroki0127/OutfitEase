import Foundation

struct UpdateProfileRequest: Codable {
    let username: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case avatarUrl = "avatar_url"
    }
}

struct UpdateProfileResponse: Codable {
    let user: User
    let message: String
}

class AuthService {
    static let shared = AuthService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let loginRequest = LoginRequest(email: email, password: password)
        let body = try JSONEncoder().encode(loginRequest)
        
        return try await apiService.request(
            endpoint: Constants.API.auth + "/login",
            method: .POST,
            body: body,
            requiresAuth: false
        )
    }
    
    func register(email: String, username: String, password: String) async throws -> AuthResponse {
        let registerRequest = RegisterRequest(email: email, username: username, password: password)
        let body = try JSONEncoder().encode(registerRequest)
        
        return try await apiService.request(
            endpoint: Constants.API.auth + "/register",
            method: .POST,
            body: body,
            requiresAuth: false
        )
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.authToken)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.currentUser)
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.isLoggedIn)
    }
    
    func saveAuthData(_ authResponse: AuthResponse) {
        print("💾 AuthService.saveAuthData called")
        UserDefaults.standard.set(authResponse.token, forKey: Constants.UserDefaults.authToken)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.isLoggedIn)
        
        if let userData = try? JSONEncoder().encode(authResponse.user) {
            UserDefaults.standard.set(userData, forKey: Constants.UserDefaults.currentUser)
            print("✅ User data saved to UserDefaults")
        } else {
            print("❌ Failed to encode user data")
        }
        
        print("🔐 Token and login state saved to UserDefaults")
    }
    
    func getCurrentUser() -> User? {
        guard let userData = UserDefaults.standard.data(forKey: Constants.UserDefaults.currentUser) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: userData)
    }
    
    func updateProfile(username: String? = nil, avatarUrl: String? = nil) async throws -> User {
        let updateRequest = UpdateProfileRequest(username: username, avatarUrl: avatarUrl)
        let body = try JSONEncoder().encode(updateRequest)
        
        let response: UpdateProfileResponse = try await apiService.request(
            endpoint: Constants.API.auth + "/profile",
            method: .PUT,
            body: body
        )
        
        // Update the stored user data
        if let userData = try? JSONEncoder().encode(response.user) {
            UserDefaults.standard.set(userData, forKey: Constants.UserDefaults.currentUser)
        }
        
        return response.user
    }
}
