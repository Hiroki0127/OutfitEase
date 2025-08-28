import SwiftUI

struct LikedOutfitsListView: View {
    @ObservedObject var likedOutfitsViewModel: LikedOutfitsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @StateObject private var outfitViewModel =  OutfitViewModel()
    @State private var selectedOutfits: Set<String> = []
    @State private var showBulkSelection = false
    @State private var showUnsaveAlert = false
    
    var filteredOutfits: [LikedOutfit] {
        if searchText.isEmpty {
            return likedOutfitsViewModel.likedOutfits
        } else {
            
            return likedOutfitsViewModel.likedOutfits.filter { outfit in
                outfit.name?.localizedCaseInsensitiveContains(searchText) == true ||
                outfit.description?.localizedCaseInsensitiveContains(searchText) == true ||
                outfit.style?.contains { $0.localizedCaseInsensitiveContains(searchText) } == true ||
                outfit.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Header indicator
                HStack {
                    Spacer()
                    Text("\(likedOutfitsViewModel.likedOutfits.count) saved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if likedOutfitsViewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading saved outfits...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = likedOutfitsViewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Outfits")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            Task {
                                await likedOutfitsViewModel.loadLikedOutfits()
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredOutfits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Saved Outfits Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            Text("You haven't saved any outfits yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("💡 Tip: Go to the Community tab and like outfits to see them here!")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Quick action button
                        Button(action: {
                            // This would ideally navigate to community tab
                            print("🎯 Navigate to community tab to find outfits to save")
                        }) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                Text("Browse Community")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredOutfits) { outfit in
                                if showBulkSelection {
                                    LikedOutfitSelectionRow(
                                        outfit: outfit,
                                        isSelected: selectedOutfits.contains(outfit.id.uuidString),
                                        onToggle: { toggleSelection(for: outfit) }
                                    )
                                } else {
                                    NavigationLink(destination: OutfitDetailView(outfit: convertToOutfit(likedOutfit: outfit), outfitViewModel: outfitViewModel)) {
                                        LikedOutfitCardView(outfit: outfit)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Saved Outfits")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search saved outfits...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if showBulkSelection {
                        Button("Done") {
                            showBulkSelection = false
                            selectedOutfits.removeAll()
                        }
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            Task {
                                await likedOutfitsViewModel.loadLikedOutfits()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        
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
            }
            .refreshable {
                await likedOutfitsViewModel.loadLikedOutfits()
            }
            .onAppear {
                // Debug info
                print("🔍 LikedOutfitsListView appeared")
                print("📊 Current liked outfits count: \(likedOutfitsViewModel.likedOutfits.count)")
                print("📋 Liked outfit IDs: \(likedOutfitsViewModel.likedOutfits.map { $0.id.uuidString })")
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
                    await likedOutfitsViewModel.loadLikedOutfits()
                }
            }
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
        do {
            // Use bulk unsave for better performance
            let outfitIds = Array(selectedOutfits)
            print("🗑️ Attempting to bulk unsave \(outfitIds.count) outfits: \(outfitIds)")
            try await OutfitService.shared.bulkUnsaveOutfits(outfitIds: outfitIds)
            print("✅ Bulk unsaved \(outfitIds.count) outfits successfully")
        } catch {
            print("❌ Error bulk unsaving outfits: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
        
        // Refresh the list
        print("🔄 Refreshing liked outfits list...")
        await likedOutfitsViewModel.loadLikedOutfits()
        print("✅ Refreshed liked outfits list")
        
        // Reset selection
        selectedOutfits.removeAll()
        showBulkSelection = false
        print("🔄 Reset selection state")
    }
}

struct LikedOutfitCardView: View {
    let outfit: LikedOutfit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Outfit image or placeholder
            if let imageURL = outfit.imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
                .cornerRadius(12)
            } else {
                // Placeholder for outfit image
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Outfit Preview")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(outfit.name ?? "Untitled Outfit")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("by \(outfit.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let description = outfit.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    if let totalPrice = outfit.totalPrice {
                        Text("$\(totalPrice, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    if let style = outfit.style, !style.isEmpty {
                        Text(style.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct LikedOutfitSelectionRow: View {
    let outfit: LikedOutfit
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            // Selection checkbox
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Outfit image
            outfitImageView
            
            // Outfit details
            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.name ?? "Unnamed Outfit")
                    .font(.headline)
                    .lineLimit(1)
                
                if let description = outfit.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let totalPrice = outfit.totalPrice {
                    Text("$\(totalPrice, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var outfitImageView: some View {
        if let imageURL = outfit.imageURL, !imageURL.isEmpty {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.crop.rectangle")
                        .foregroundColor(.gray)
                )
        }
    }
}

#Preview {
    LikedOutfitsListView(likedOutfitsViewModel: LikedOutfitsViewModel())
}
