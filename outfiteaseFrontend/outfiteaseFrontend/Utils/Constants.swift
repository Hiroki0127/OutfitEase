import Foundation

struct Constants {
    static let baseURL = "http://127.0.0.1:3000"
    
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
    
    struct UserDefaults {
        static let authToken = "authToken"
        static let isLoggedIn = "isLoggedIn"
        static let currentUser = "currentUser"
    }
    
    struct Weather {
        static let defaultCity = "New York"
        static let temperatureUnit = "°C"
        static let windSpeedUnit = "m/s"
    }
    
    struct OutfitGeneration {
        static let maxGeneratedOutfits = 10
        static let defaultBudget = 100.0
        static let minBudget = 20.0
        static let maxBudget = 500.0
    }
}
