import Foundation
import SwiftUI

@MainActor
class PlanningViewModel: ObservableObject {
    @Published var outfitPlans: [OutfitPlan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let planningService = PlanningService.shared
    
    // Preview initializer
    init(previewMode: Bool = false) {
        // No sample data in production
    }
    
    func loadOutfitPlans() async {
        isLoading = true
        errorMessage = nil
        
        do {
            outfitPlans = try await planningService.getOutfitPlans()
            print("📅 Loaded \(outfitPlans.count) outfit plans")
            for plan in outfitPlans {
                print("  - \(plan.outfitName ?? "Unknown") for \(plan.plannedDate)")
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading outfit plans: \(error)")
        }
        
        isLoading = false
    }
    
    func addOutfitPlan(_ plan: CreateOutfitPlanRequest) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newPlan = try await planningService.createOutfitPlan(plan)
            print("✅ Added new plan: \(newPlan.outfitName ?? "Unknown") for \(newPlan.plannedDate)")
            // Reload all plans to get the full outfit details
            await loadOutfitPlans()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error adding outfit plan: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteOutfitPlan(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await planningService.deleteOutfitPlan(id: id)
            outfitPlans.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
