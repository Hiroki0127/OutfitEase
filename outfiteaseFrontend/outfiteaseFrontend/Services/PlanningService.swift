import Foundation

class PlanningService {
    static let shared = PlanningService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func getOutfitPlans() async throws -> [OutfitPlan] {
        let plans: [OutfitPlan] = try await apiService.request(endpoint: Constants.API.planning)
        print("📅 Raw plans data from backend: \(plans)")
        return plans
    }
    
    func createOutfitPlan(_ plan: CreateOutfitPlanRequest) async throws -> OutfitPlan {
        let body = try JSONEncoder().encode(plan)
        print("📅 Sending plan request: \(String(data: body, encoding: .utf8) ?? "Failed to encode")")
        return try await apiService.request(
            endpoint: Constants.API.planning,
            method: .POST,
            body: body
        )
    }
    
    func deleteOutfitPlan(id: String) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: Constants.API.planning + "/\(id)",
            method: .DELETE
        )
    }
}

struct CreateOutfitPlanRequest: Codable {
    let outfitId: String
    let plannedDate: String
    let title: String?
}
