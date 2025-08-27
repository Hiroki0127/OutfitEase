import SwiftUI

struct LikedOutfitsView: View {
    @StateObject private var viewModel = LikedOutfitsViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()
    @State private var selectedOutfits: Set<String> = []
    @State private var showBulkSelection = false
    @State private var showUnsaveAlert = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading liked outfits...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.likedOutfits.isEmpty {
                emptyStateView
            } else {
                outfitsGrid
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !showBulkSelection {
                    Button(action: {
                        showBulkSelection = true
                    }) {
                        Image(systemName: "checkmark.circle")
                    }
                } else if !selectedOutfits.isEmpty {
                    Button("Unsave (\(selectedOutfits.count))") {
                        showUnsaveAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("Unsave Selected Outfits", isPresented: $showUnsaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Unsave", role: .destructive) {
                Task {
                    await unsaveSelectedOutfits()
                }
            }
        } message: {
            Text("Are you sure you want to unsave \(selectedOutfits.count) selected outfit\(selectedOutfits.count == 1 ? "" : "s")?")
        }
        .onAppear {
            Task {
                await viewModel.loadLikedOutfits()
            }
        }
        .refreshable {
            await viewModel.loadLikedOutfits()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Saved Outfits")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Outfits you save will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var outfitsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.likedOutfits) { outfit in
                    if showBulkSelection {
                        LikedOutfitSelectionCard(
                            outfit: outfit,
                            isSelected: selectedOutfits.contains(outfit.id.uuidString),
                            onToggle: { toggleSelection(for: outfit) }
                        )
                    } else {
                        NavigationLink(destination: OutfitDetailView(outfit: convertToOutfit(likedOutfit: outfit), outfitViewModel: outfitViewModel)) {
                            LikedOutfitCard(outfit: outfit)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
    }
    
    private func convertToOutfit(likedOutfit: LikedOutfit) -> Outfit {
        return Outfit(
            id: likedOutfit.id,
            userId: likedOutfit.userId,
            name: likedOutfit.name,
            description: likedOutfit.description,
            totalPrice: likedOutfit.totalPrice,
            style: likedOutfit.style,
            color: likedOutfit.color,
            brand: likedOutfit.brand,
            season: likedOutfit.season,
            occasion: likedOutfit.occasion,
            imageURL: likedOutfit.imageURL,
            createdAt: likedOutfit.createdAt
        )
    }
    
    private func toggleSelection(for outfit: LikedOutfit) {
        let outfitId = outfit.id.uuidString
        if selectedOutfits.contains(outfitId) {
            selectedOutfits.remove(outfitId)
        } else {
            selectedOutfits.insert(outfitId)
        }
    }
    
    private func unsaveSelectedOutfits() async {
        for outfitId in selectedOutfits {
            do {
                try await OutfitService.shared.unlikeOutfit(outfitId: outfitId)
                print("✅ Unliked outfit: \(outfitId)")
            } catch {
                print("❌ Error unliking outfit \(outfitId): \(error)")
            }
        }
        
        // Refresh the list
        await viewModel.loadLikedOutfits()
        
        // Reset selection
        selectedOutfits.removeAll()
        showBulkSelection = false
    }
}

struct LikedOutfitCard: View {
    let outfit: LikedOutfit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Outfit image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: outfit.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.crop.rectangle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                

            }
            
            // Outfit details
            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.name ?? "Unnamed Outfit")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text("by \(outfit.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let description = outfit.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let totalPrice = outfit.totalPrice {
                    Text("$\(totalPrice, specifier: "%.2f")")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                // Tags
                if let style = outfit.style, !style.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(style.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct LikedOutfitSelectionCard: View {
    let outfit: LikedOutfit
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Outfit image with selection overlay
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: outfit.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.crop.rectangle")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Selection checkbox
                Button(action: onToggle) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .white)
                        .font(.title2)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            // Outfit details
            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.name ?? "Unnamed Outfit")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text("by \(outfit.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let description = outfit.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let totalPrice = outfit.totalPrice {
                    Text("$\(totalPrice, specifier: "%.2f")")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    LikedOutfitsView()
}
