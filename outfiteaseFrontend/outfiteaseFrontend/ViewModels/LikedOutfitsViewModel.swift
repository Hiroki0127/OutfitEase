import Foundation

@MainActor
class LikedOutfitsViewModel: ObservableObject {
    @Published var likedOutfits: [LikedOutfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let outfitService = OutfitService.shared
    
    func loadLikedOutfits() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔄 Loading saved outfits...")
            likedOutfits = try await outfitService.getSavedOutfits()
            print("✅ Loaded \(likedOutfits.count) saved outfits")
            
            // Debug: Print outfit details
            for (index, outfit) in likedOutfits.enumerated() {
                print("📋 Saved outfit \(index + 1): \(outfit.name ?? "Unknown") by \(outfit.username)")
            }
        } catch {
            errorMessage = "Failed to load saved outfits: \(error.localizedDescription)"
            print("❌ Error loading saved outfits: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
