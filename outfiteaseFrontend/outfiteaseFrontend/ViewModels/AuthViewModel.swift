import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift


@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: Constants.UserDefaults.isLoggedIn)
        let hasToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.authToken) != nil
        
        print("🔍 Debug - Auth Status Check:")
        print("   isLoggedIn: \(isLoggedIn)")
        print("   hasToken: \(hasToken)")
        print("   UserDefaults keys: \(UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.contains("auth") || $0.contains("login") })")
        
        self.isLoggedIn = isLoggedIn
        currentUser = authService.getCurrentUser()
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        print("🔐 Starting login process...")
        
        // Test connectivity first
        let isConnected = await APIService.shared.testConnectivity()
        print("🌐 Server connectivity: \(isConnected)")
        
        do {
            let response = try await authService.login(email: email, password: password)
            authService.saveAuthData(response)
            currentUser = response.user
            isLoggedIn = true
            print("✅ Login successful")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Login failed: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func register(email: String, username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await authService.register(email: email, username: username, password: password)
            authService.saveAuthData(response)
            currentUser = response.user
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        authService.logout()
        isLoggedIn = false
        currentUser = nil
    }
    
    // MARK: - Testing Helper
    func resetForTesting() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.authToken)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.currentUser)
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.isLoggedIn)
        isLoggedIn = false
        currentUser = nil
        errorMessage = nil
    }
    
    // MARK: - Mock Login for Testing
    func mockLogin(email: String, password: String) async {
        print("🔐 Mock login started")
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        if email == "test@example.com" && password == "password" {
            print("✅ Valid credentials detected")
            
            let mockUser = User(
                id: "mock-user-id",
                email: email,
                username: "testuser",
                avatarUrl: nil,
                createdAt: "2024-01-01",
                role: "user"
            )
            
            let mockResponse = AuthResponse(
                token: "mock-jwt-token",
                user: mockUser,
                message: "Login successful"
            )
            
            print("💾 Saving auth data...")
            authService.saveAuthData(mockResponse)
            
            print("👤 Setting current user...")
            currentUser = mockUser
            
            print("🔓 Setting isLoggedIn to true...")
            isLoggedIn = true
            
            print("✅ Mock login completed successfully")
        } else {
            print("❌ Invalid credentials")
            errorMessage = "Invalid credentials. Use test@example.com / password"
        }
        
        isLoading = false
        print("🏁 Mock login function finished")
    }
    func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google sign-in error:", error.localizedDescription)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Firebase sign-in error:", error.localizedDescription)
                    return
                }

                print("✅ User signed in successfully:", result?.user.uid ?? "")
            }
        }
    }
    

}




