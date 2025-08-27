//
//  outfiteaseFrontendApp.swift
//  outfiteaseFrontend
//
//  Created by Hiroki Mukai on 2025-07-30.
//

import SwiftUI
import Firebase

@main
struct outfiteaseFrontendApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
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

