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
        
        // Wake up server first (Render free tier spins down after inactivity)
        print("⏰ Waking up server...")
        let isConnected = await APIService.shared.testConnectivity()
        print("🌐 Server connectivity: \(isConnected)")
        
        // Small delay to ensure server is fully awake
        if isConnected {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
        
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
        // Check if Google Sign In is configured
        guard GIDSignIn.sharedInstance.configuration != nil else {
            errorMessage = "Google Sign In not configured. Please enable Google Sign In in Firebase Console → Authentication → Sign-in method → Google"
            print("❌ Google Sign In configuration is nil")
            print("   Firebase client ID: \(FirebaseApp.app()?.options.clientID ?? "nil")")
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to present Google Sign In"
            return
        }

        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Google sign-in error: \(error.localizedDescription)"
                    print("❌ Google sign-in error:", error.localizedDescription)
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self.isLoading = false
                    self.errorMessage = "Failed to get Google ID token"
                    print("❌ Failed to get Google ID token")
                    return
                }

                print("✅ Google ID token received, sending to backend...")
                
                do {
                    // Send ID token to backend
                    let response = try await self.authService.googleSignIn(idToken: idToken)
                    
                    // Save auth data
                    self.authService.saveAuthData(response)
                    self.currentUser = response.user
                    self.isLoggedIn = true
                    self.isLoading = false
                    
                    print("✅ Google Sign In successful:", response.user.email)
                } catch {
                    self.isLoading = false
                    self.errorMessage = "Failed to sign in with Google: \(error.localizedDescription)"
                    print("❌ Backend Google Sign In error:", error.localizedDescription)
                }
            }
        }
    }
    

}




