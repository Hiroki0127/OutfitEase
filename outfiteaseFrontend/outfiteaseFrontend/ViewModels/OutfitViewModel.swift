import Foundation
import SwiftUI

@MainActor
class OutfitViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let outfitService = OutfitService.shared
    

    
    func loadOutfits() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedOutfits = try await outfitService.getOutfits()
            outfits = loadedOutfits
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addOutfit(_ outfit: CreateOutfitRequest) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newOutfit = try await outfitService.createOutfit(outfit)
            outfits.append(newOutfit)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateOutfit(id: UUID, _ outfit: UpdateOutfitRequest) async {
        isLoading = true
        errorMessage = nil
        
        print("📝 Updating outfit with ID: \(id)")
        
        do {
            let updatedOutfit = try await outfitService.updateOutfit(id: id, outfit)
            print("✅ Outfit updated on server successfully")
            
            if let index = outfits.firstIndex(where: { $0.id == id }) {
                outfits[index] = updatedOutfit
                print("✅ Updated outfit in local array")
            } else {
                print("⚠️ Outfit not found in local array, reloading...")
                await loadOutfits()
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error updating outfit: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteOutfit(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        print("🗑️ Deleting outfit with ID: \(id)")
        
        do {
            try await outfitService.deleteOutfit(id: id)
            print("✅ Outfit deleted from server successfully")
            
            // Remove from local array and reload to ensure consistency
            outfits.removeAll { $0.id == id }
            print("🗑️ Removed outfit from local array")
            
            // Reload outfits to ensure UI is in sync with server
            await loadOutfits()
            print("🔄 Reloaded outfits from server")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error deleting outfit: \(error)")
        }
        
        isLoading = false
    }
    
    // ✅ Bulk delete multiple outfits
    func bulkDeleteOutfits(outfitIds: [String]) async {
        isLoading = true
        errorMessage = nil
        
        print("🗑️ Bulk deleting \(outfitIds.count) outfits")
        
        do {
            let response = try await outfitService.bulkDeleteOutfits(outfitIds: outfitIds)
            print("✅ Bulk deleted \(response.deletedCount) outfits: \(response.message)")
            
            // Remove the items from the local array
            outfits.removeAll { outfitIds.contains($0.id.uuidString) }
            
            // Reload outfits to ensure UI is in sync with server
            await loadOutfits()
            print("🔄 Reloaded outfits from server")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Bulk delete error: \(error)")
        }
        
        isLoading = false
    }

}
