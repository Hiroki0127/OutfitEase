import Foundation
import SwiftUI

@MainActor
class OutfitGenerationViewModel: ObservableObject {
    @Published var generatedOutfits: [GeneratedOutfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let generationService = OutfitGenerationService.shared
    
    func generateOutfits(filters: OutfitGenerationFilters) async {
        isLoading = true
        errorMessage = nil
        
        do {
            generatedOutfits = try await generationService.generateOutfits(filters: filters)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func generateWeatherBasedOutfits(weather: WeatherInfo) async {
        isLoading = true
        errorMessage = nil
        
        do {
            generatedOutfits = try await generationService.generateWeatherBasedOutfits(weather: weather)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getEventSuggestions(eventType: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            generatedOutfits = try await generationService.getEventSuggestions(eventType: eventType)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
} 