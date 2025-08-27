import Foundation
import SwiftUI

@MainActor
class ClothingViewModel: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let clothingService = ClothingService.shared
    
    // Preview initializer for sample data
    init(previewItems: [ClothingItem]) {
        self.clothingItems = previewItems
        self.isLoading = false
        self.errorMessage = nil
    }
    
    // Default initializer
    init() {
        self.clothingItems = []
        self.isLoading = false
        self.errorMessage = nil
    }
    
    func loadClothingItems() async {
        print("🔄 Loading clothing items...")
        isLoading = true
        errorMessage = nil
        
        do {
            let items = try await clothingService.getClothingItems()
            print("📦 Loaded \(items.count) items from server")
            print("📋 Items: \(items.map { $0.name })")
            clothingItems = items
        } catch {
            print("❌ Error loading items: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        print("✅ Loading completed")
    }
    
    func addClothingItem(_ item: CreateClothingItemRequest) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newItem = try await clothingService.createClothingItem(item)
            clothingItems.append(newItem)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateClothingItem(id: String, _ item: UpdateClothingItemRequest) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedItem = try await clothingService.updateClothingItem(id: id, item)
            if let index = clothingItems.firstIndex(where: { $0.id == id }) {
                clothingItems[index] = updatedItem
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteClothingItem(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Delete from backend
            try await clothingService.deleteClothingItem(id: id)
            
            // Remove the item from the local array
            clothingItems.removeAll { $0.id == id }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    // ✅ Bulk delete multiple clothing items
    func bulkDeleteClothingItems(itemIds: [String]) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Delete from backend
            let response = try await clothingService.bulkDeleteClothingItems(itemIds: itemIds)
            
            // Remove the items from the local array
            clothingItems.removeAll { itemIds.contains($0.id) }
            
            print("✅ Bulk deleted \(response.deletedCount) items: \(response.message)")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Bulk delete error: \(error)")
        }
        
        isLoading = false
    }
}
