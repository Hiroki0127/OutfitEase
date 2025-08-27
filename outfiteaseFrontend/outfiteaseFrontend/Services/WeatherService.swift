import Foundation
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    private let apiService = APIService.shared
    private let locationManager = CLLocationManager()
    
    private init() {}
    
    func getCurrentWeather(latitude: Double? = nil, longitude: Double? = nil, city: String? = nil) async throws -> WeatherInfo {
        var queryItems: [String] = []
        
        if let latitude = latitude, let longitude = longitude {
            queryItems.append("latitude=\(latitude)")
            queryItems.append("longitude=\(longitude)")
        } else if let city = city {
            queryItems.append("city=\(city)")
        }
        
        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        return try await apiService.request(endpoint: "/weather/current\(queryString)")
    }
    
    func getWeatherForecast(latitude: Double? = nil, longitude: Double? = nil, city: String? = nil) async throws -> [WeatherForecast] {
        var queryItems: [String] = []
        
        if let latitude = latitude, let longitude = longitude {
            queryItems.append("latitude=\(latitude)")
            queryItems.append("longitude=\(longitude)")
        } else if let city = city {
            queryItems.append("city=\(city)")
        }
        
        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        return try await apiService.request(endpoint: "/weather/forecast\(queryString)")
    }
    
    func getWeatherRecommendations(temperature: Double, conditions: String, humidity: Int) async throws -> WeatherRecommendations {
        let weatherData = WeatherRecommendationRequest(
            temperature: temperature,
            conditions: conditions,
            humidity: humidity
        )
        
        let body = try JSONEncoder().encode(weatherData)
        return try await apiService.request(
            endpoint: "/weather/recommendations",
            method: .POST,
            body: body
        )
    }
    
    func requestLocationPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            locationManager.requestWhenInUseAuthorization()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let status = CLLocationManager.authorizationStatus()
                continuation.resume(returning: status == .authorizedWhenInUse || status == .authorizedAlways)
            }
        }
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            locationManager.requestLocation()
            
            // Set up a timer to handle timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                continuation.resume(throwing: WeatherError.locationTimeout)
            }
            
            // This would need to be implemented with proper delegate methods
            // For now, we'll return a mock location
            continuation.resume(returning: CLLocation(latitude: 40.7128, longitude: -74.0060)) // NYC
        }
    }
}

struct WeatherInfo: Codable {
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let conditions: String
    let description: String
    let windSpeed: Double
    let city: String
    let country: String
}

struct WeatherForecast: Codable {
    let date: String
    let temperature: Int
    let conditions: String
    let humidity: Int
    let recommendations: WeatherRecommendations
}

struct WeatherRecommendations: Codable {
    let seasons: [String]
    let styles: [String]
    let occasions: [String]
    let clothingTypes: [String]
    let colors: [String]
    let accessories: [String]
}

struct WeatherRecommendationRequest: Codable {
    let temperature: Double
    let conditions: String
    let humidity: Int
}

enum WeatherError: Error {
    case locationTimeout
    case locationDenied
    case networkError
} 