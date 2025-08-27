import Foundation
import SwiftUI
import CoreLocation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var currentWeather: WeatherInfo?
    @Published var weatherForecast: [WeatherForecast] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var locationPermissionGranted = false
    
    private let weatherService = WeatherService.shared
    
    func requestLocationAndWeather() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Request location permission
            locationPermissionGranted = await weatherService.requestLocationPermission()
            
            if locationPermissionGranted {
                // Get current location
                let location = try await weatherService.getCurrentLocation()
                
                // Get weather data
                currentWeather = try await weatherService.getCurrentWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                // Get weather forecast
                weatherForecast = try await weatherService.getWeatherForecast(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            } else {
                errorMessage = "Location permission denied. Please enable location access in Settings."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getWeatherForCity(_ city: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentWeather = try await weatherService.getCurrentWeather(city: city)
            weatherForecast = try await weatherService.getWeatherForecast(city: city)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getWeatherRecommendations() async -> WeatherRecommendations? {
        guard let weather = currentWeather else { return nil }
        
        do {
            return try await weatherService.getWeatherRecommendations(
                temperature: weather.temperature,
                conditions: weather.conditions,
                humidity: weather.humidity
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
} 


