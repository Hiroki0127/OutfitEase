
import SwiftUI

struct OutfitListView: View {
    @ObservedObject var outfitViewModel: OutfitViewModel
    @StateObject private var likedOutfitsViewModel = LikedOutfitsViewModel()
    @State private var showCreateOutfit = false
    @State private var showBulkSelection = false
    @State private var searchText = ""
    @State private var showMyOutfitsList = false
    @State private var showLikedOutfitsList = false
    
    var filteredOutfits: [Outfit] {
        if searchText.isEmpty {
            return outfitViewModel.outfits
        } else {
            return outfitViewModel.outfits.filter { outfit in
                outfit.name?.localizedCaseInsensitiveContains(searchText) == true ||
                outfit.description?.localizedCaseInsensitiveContains(searchText) == true ||
                outfit.style?.contains { $0.localizedCaseInsensitiveContains(searchText) } == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if outfitViewModel.isLoading {
                    ProgressView("Loading outfits...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Split view with My Outfits and Liked Outfits
                    GeometryReader { geometry in
                        VStack(spacing: 0) {
                            // My Outfits Section (50% of screen)
                            Button(action: {
                                showMyOutfitsList = true
                            }) {
                                ZStack {
                                    // Background image (blurred) - completely constrained to frame
                                    if let firstOutfit = filteredOutfits.first,
                                       let imageURL = firstOutfit.imageURL,
                                       !imageURL.isEmpty {
                                        AsyncImage(url: URL(string: imageURL)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .blur(radius: 15)
                                                .clipped()
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.blue.opacity(0.1))
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.1))
                                    }
                                    
                                    // Overlay for better text readability
                                    Rectangle()
                                        .fill(Color.black.opacity(0.4))
                                        .cornerRadius(12)
                                    
                                    // Content
                                    VStack(spacing: 16) {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        
                                        Text("My Outfits")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Text("\(filteredOutfits.count) outfit\(filteredOutfits.count == 1 ? "" : "s")")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        if filteredOutfits.isEmpty {
                                            Text("Create your first outfit!")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                                .multilineTextAlignment(.center)
                                        } else {
                                            Text("Your created outfits")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(height: geometry.size.height * 0.5)
                            .clipped()
                            
                            // Liked Outfits Section (50% of screen)
                            Button(action: {
                                showLikedOutfitsList = true
                            }) {
                                ZStack {
                                    // Background image (blurred) - completely constrained to frame
                                    if let firstLikedOutfit = likedOutfitsViewModel.likedOutfits.first,
                                       let imageURL = firstLikedOutfit.imageURL,
                                       !imageURL.isEmpty {
                                        AsyncImage(url: URL(string: imageURL)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .blur(radius: 15)
                                                .clipped()
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.red.opacity(0.1))
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red.opacity(0.1))
                                    }
                                    
                                    // Overlay for better text readability
                                    Rectangle()
                                        .fill(Color.black.opacity(0.4))
                                        .cornerRadius(12)
                                    
                                    // Content
                                    VStack(spacing: 16) {
                                        Image(systemName: "bookmark.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        
                                        Text("Saved Outfits")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Text("\(likedOutfitsViewModel.likedOutfits.count) outfit\(likedOutfitsViewModel.likedOutfits.count == 1 ? "" : "s")")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        if likedOutfitsViewModel.likedOutfits.isEmpty {
                                            Text("Liked outfits")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                                .multilineTextAlignment(.center)
                                        } else {
                                            Text("Saved outfits")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(height: geometry.size.height * 0.5)
                            .clipped()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Outfits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateOutfit = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateOutfit) {
                CreateOutfitView(
                    outfitViewModel: outfitViewModel,
                    selectedClothingItemId: nil,
                    onOutfitCreated: {
                        Task {
                            await outfitViewModel.loadOutfits()
                        }
                    }
                )
            }
            .sheet(isPresented: $showBulkSelection) {
                BulkSelectionOutfitView(outfitViewModel: outfitViewModel)
            }
            .sheet(isPresented: $showMyOutfitsList) {
                MyOutfitsListView(outfitViewModel: outfitViewModel)
            }
            .sheet(isPresented: $showLikedOutfitsList) {
                LikedOutfitsListView(likedOutfitsViewModel: likedOutfitsViewModel)
            }
            .onAppear {
                // Debug info
                print("🔍 OutfitListView appeared")
                print("📊 My outfits count: \(outfitViewModel.outfits.count)")
                print("📊 Liked outfits count: \(likedOutfitsViewModel.likedOutfits.count)")
            }
        }
        .task {
            print("🔄 Loading data in OutfitListView...")
            await outfitViewModel.loadOutfits()
            await likedOutfitsViewModel.loadLikedOutfits()
            print("✅ Data loading completed")
        }
        .onAppear {
            Task {
                await likedOutfitsViewModel.loadLikedOutfits()
            }
        }

    }
}

struct OutfitCardView: View {
    let outfit: Outfit
    
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
                Text(outfit.name ?? "Untitled Outfit")
                    .font(.headline)
                    .lineLimit(1)
                
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

#Preview {
    OutfitListView(outfitViewModel: OutfitViewModel())
}
