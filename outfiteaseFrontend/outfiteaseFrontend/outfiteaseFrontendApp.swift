//
//  outfiteaseFrontendApp.swift
//  outfiteaseFrontend
//
//  Created by Hiroki Mukai on 2025-07-30.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct outfiteaseFrontendApp: App {
    // Connect AppDelegate for Google Sign-In URL handling
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
        
        // Configure Google Sign In
        // Try to get CLIENT_ID from GoogleService-Info.plist first
        var clientId: String?
        
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let plistClientId = plist["CLIENT_ID"] as? String {
            clientId = plistClientId
            print("✅ Found CLIENT_ID in GoogleService-Info.plist")
        }
        
        // Fallback to Firebase options
        if clientId == nil, let firebaseClientId = FirebaseApp.app()?.options.clientID {
            clientId = firebaseClientId
            print("✅ Using Firebase client ID")
        }
        
        if let clientId = clientId {
            let configuration = GIDConfiguration(clientID: clientId)
            GIDSignIn.sharedInstance.configuration = configuration
            print("✅ Google Sign In configured with client ID: \(clientId.prefix(30))...")
        } else {
            print("⚠️ Warning: Google Sign In client ID not found")
            print("   Please ensure GoogleService-Info.plist includes CLIENT_ID")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoggedIn {
                    HomeView(authViewModel: authViewModel)
                        .onAppear {
                            print("🏠 HomeView appeared - User is logged in")
                        }
                } else {
                    LoginView(authViewModel: authViewModel)
                        .onAppear {
                            print("🔐 LoginView appeared - User is NOT logged in")
                        }
                }
            }
            .onAppear {
                print("📱 App started")
                // Comment out reset for real backend testing
                // authViewModel.resetForTesting()
            }
        }
    }
}

// AppDelegate to handle URL callback for Google Sign-In
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Optional: configure Google Sign-In if needed
        // GIDSignIn.sharedInstance.restorePreviousSignIn() // if you want auto sign-in
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle the URL callback so Google Sign-In can detect the URL scheme
        return GIDSignIn.sharedInstance.handle(url)
    }
}

