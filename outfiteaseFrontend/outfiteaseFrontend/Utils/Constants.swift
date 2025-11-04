import Foundation

struct Constants {
    // MARK: - API Base URL (Production)
    // Production server: https://outfitease.onrender.com
    // For local testing: http://127.0.0.1:3000
    static let baseURL = "https://outfitease.onrender.com"
    
    // MARK: - API Endpoints
    struct API {
        static let auth = "/auth"
        static let clothes = "/clothes"
        static let outfits = "/outfits"
        static let planning = "/planning"
        static let posts = "/posts"
        static let likes = "/likes"
        static let savedOutfits = "/saved-outfits"
        static let comments = "/comments"
        static let upload = "/upload"
        
        // New feature endpoints
        static let outfitGeneration = "/outfit-generation"
        static let weather = "/weather"
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaults {
        static let authToken = "authToken"
        static let isLoggedIn = "isLoggedIn"
        static let currentUser = "currentUser"
    }
    
    // MARK: - Weather Configuration
    struct Weather {
        static let defaultCity = "New York"
        static let temperatureUnit = "°C"
        static let windSpeedUnit = "m/s"
    }
    
    // MARK: - Outfit Generation Configuration
    struct OutfitGeneration {
        static let maxGeneratedOutfits = 10
        static let defaultBudget = 100.0
        static let minBudget = 20.0
        static let maxBudget = 500.0
    }
}
