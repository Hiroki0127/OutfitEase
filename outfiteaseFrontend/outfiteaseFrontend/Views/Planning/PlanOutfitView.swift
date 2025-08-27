import SwiftUI

struct PlanOutfitView: View {
    let outfit: Outfit
    @Environment(\.dismiss) private var dismiss
    @StateObject private var planningViewModel = PlanningViewModel()
    @State private var selectedDate = Date()
    @State private var eventTitle = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Outfit Image
                    if let imageURL = outfit.imageURL, !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                                .overlay(
                                    ProgressView()
                                        .foregroundColor(.gray)
                                )
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                VStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No Outfit Photo")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                    
                    // Outfit Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text(outfit.name ?? "Untitled Outfit")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let description = outfit.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Outfit Tags
                        VStack(alignment: .leading, spacing: 8) {
                            if let style = outfit.style, !style.isEmpty {
                                TagSection(title: "Style", tags: style)
                            }
                            
                            if let color = outfit.color, !color.isEmpty {
                                TagSection(title: "Colors", tags: color)
                            }
                            
                            if let brand = outfit.brand, !brand.isEmpty {
                                TagSection(title: "Brands", tags: brand)
                            }
                            
                            if let season = outfit.season, !season.isEmpty {
                                TagSection(title: "Season", tags: season)
                            }
                            
                            if let occasion = outfit.occasion, !occasion.isEmpty {
                                TagSection(title: "Occasion", tags: occasion)
                            }
                            
                            if let totalPrice = outfit.totalPrice {
                                HStack {
                                    Text("Price:")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("$\(totalPrice, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Event Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Title")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("e.g., Brunch with Ella, Work Meeting, Date Night", text: $eventTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Date")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    // Success Message
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    // Plan Outfit Button
                    Button(action: planOutfit) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                            }
                            Text(isLoading ? "Planning..." : "Plan This Outfit")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                }
                .padding()
            }
            .navigationTitle("Plan Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func planOutfit() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Format date for backend
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: selectedDate)
        
        let planRequest = CreateOutfitPlanRequest(
            outfitId: outfit.id.uuidString,
            plannedDate: formattedDate,
            title: eventTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : eventTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        print("📅 Creating plan request:")
        print("  - outfitId: \(outfit.id.uuidString)")
        print("  - plannedDate: \(formattedDate)")
        print("  - eventTitle: '\(eventTitle)'")
        print("  - title: \(eventTitle.isEmpty ? "nil" : "'\(eventTitle)'")")
        
        Task {
            await planningViewModel.addOutfitPlan(planRequest)
            
            await MainActor.run {
                isLoading = false
                
                if planningViewModel.errorMessage != nil {
                    errorMessage = planningViewModel.errorMessage
                } else {
                    successMessage = "Outfit planned for \(formattedDate)!"
                    // Dismiss after a short delay to show success message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PlanOutfitView(outfit: Outfit(
        id: UUID(),
        userId: UUID(),
        name: "Casual Weekend Look",
        description: "Perfect for hanging out with friends",
        totalPrice: 89.99,
        style: ["Casual", "Streetwear"],
        color: ["Blue", "White"],
        brand: ["Nike", "Levi's"],
        season: ["Spring", "Summer"],
        occasion: ["Casual", "Weekend"],
        imageURL: nil,
        createdAt: "2024-01-01T10:30:00Z"
    ))
} 