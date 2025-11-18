import Foundation
import CoreLocation

class WeatherService: NSObject, CLLocationManagerDelegate {
    static let shared = WeatherService()
    private let apiService = APIService.shared
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func getCurrentWeather(latitude: Double? = nil, longitude: Double? = nil, city: String? = nil) async throws -> WeatherInfo {
        var queryItems: [String] = []
        
        if let latitude = latitude, let longitude = longitude {
            queryItems.append("latitude=\(latitude)")
            queryItems.append("longitude=\(longitude)")
        } else if let city = city {
            queryItems.append("city=\(city)")
        }
        
        let queryString = queryItems.isEmpty ? "" : "?" + queryItems.joined(separator: "&")
        let response: WeatherResponse = try await apiService.request(endpoint: "/weather/current\(queryString)")
        return response.weather
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
        let response: WeatherForecastResponse = try await apiService.request(endpoint: "/weather/forecast\(queryString)")
        return response.forecast
    }
    
    func getWeatherRecommendations(temperature: Double, conditions: String, humidity: Int) async throws -> WeatherRecommendations {
        let weatherData = WeatherRecommendationRequest(
            temperature: temperature,
            conditions: conditions,
            humidity: humidity
        )
        
        let body = try JSONEncoder().encode(weatherData)
        let response: WeatherRecommendationResponse = try await apiService.request(
            endpoint: "/weather/recommendations",
            method: .POST,
            body: body
        )
        return response.recommendations
    }
    
    func requestLocationPermission() async -> Bool {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let newStatus = self.locationManager.authorizationStatus
                    continuation.resume(returning: newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways)
                }
            }
        default:
            return false
        }
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        let status = locationManager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            throw WeatherError.locationDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
            
            // Timeout after 15 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if let cont = self.locationContinuation {
                    self.locationContinuation = nil
                    cont.resume(throwing: WeatherError.locationTimeout)
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first, let continuation = locationContinuation else { return }
        locationContinuation = nil
        continuation.resume(returning: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil
        continuation.resume(throwing: error)
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

struct WeatherResponse: Codable {
    let success: Bool
    let weather: WeatherInfo
}

struct WeatherForecastResponse: Codable {
    let success: Bool
    let forecast: [WeatherForecast]
}

struct WeatherRecommendationResponse: Codable {
    let success: Bool
    let recommendations: WeatherRecommendations
}

enum WeatherError: Error {
    case locationTimeout
    case locationDenied
    case networkError
} 