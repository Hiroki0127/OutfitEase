import SwiftUI

struct PostDetailView: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss
    @StateObject private var commentViewModel = CommentViewModel()
    @State private var showComments = false
    @State private var isLiked: Bool
    @State private var likeCount: Int
    @State private var isLiking = false
    @State private var showShareSheet = false
    @State private var isSavingOutfit = false
    @State private var isOutfitSaved = false
    @State private var hasCheckedSavedStatus = false
    @State private var showUserProfile = false
    
    init(post: Post) {
        self.post = post
        self._isLiked = State(initialValue: post.isLiked)
        self._likeCount = State(initialValue: post.likeCount)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // User Info Header
                    HStack {
                        Button {
                            showUserProfile = true
                        } label: {
                            HStack(spacing: 12) {
                                if let urlString = post.avatarURL, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        case .failure:
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.blue)
                                        @unknown default:
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.blue)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.username)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Text(post.createdAt)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Post Caption
                    if !post.caption.isEmpty {
                        Text(post.caption)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                    }
                    
                    // Outfit Image
                    if let imageURL = post.imageURL, !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .overlay(
                                    ProgressView()
                                        .foregroundColor(.gray)
                                )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Outfit Details (if available)
                    if let outfit = post.outfit {
                        VStack(alignment: .leading, spacing: 16) {
                            // Outfit Name
                            if let name = outfit.name, !name.isEmpty {
                                Text(name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                            }
                            
                            // Outfit Description
                            if let description = outfit.description, !description.isEmpty {
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                            
                            // Outfit Tags
                            VStack(alignment: .leading, spacing: 12) {
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
                                    TagSection(title: "Price", tags: ["$\(String(format: "%.2f", totalPrice))"])
                                }
                                
                                // Clothing Pieces Section
                                if let items = outfit.items, !items.isEmpty {
                                    ClothingPiecesSection(clothingItems: items)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            Task {
                                await toggleLike()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                Text("\(likeCount)")
                                    .font(.subheadline)
                            }
                        }
                        .disabled(isLiking)
                        
                        Button(action: {
                            showComments = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.right")
                                    .foregroundColor(.blue)
                                Text("\(post.commentCount)")
                                    .font(.subheadline)
                            }
                        }
                        
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                        }
                        
                        // Save/Unsave Outfit Button (only show if post has an outfit)
                        if post.outfit != nil {
                            Button(action: {
                                Task {
                                    if isOutfitSaved {
                                        await unsaveOutfit()
                                    } else {
                                        await saveOutfit()
                                    }
                                }
                            }) {
                                Image(systemName: isOutfitSaved ? "bookmark.fill" : (isSavingOutfit ? "bookmark" : "bookmark"))
                                    .foregroundColor(isOutfitSaved ? .blue : (isSavingOutfit ? .gray : .gray))
                                    .font(.title2)
                            }
                            .disabled(isSavingOutfit)
                        }
                        
                        Spacer()
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Post Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showComments) {
                CommentsView(post: post)
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: createShareItems())
            }
            .sheet(isPresented: $showUserProfile) {
                NavigationView {
                    PublicProfileView(userId: post.userId.uuidString)
                }
            }
            
            .task {
                await commentViewModel.loadComments(postId: post.id)
                await checkIfOutfitIsSaved()
            }
            .onAppear {
                Task {
                    await checkIfOutfitIsSaved()
                }
            }
        }
    }
    
    private func toggleLike() async {
        guard !isLiking else { return }
        
        isLiking = true
        
        do {
            if isLiked {
                try await PostService.shared.unlikePost(postId: post.id.uuidString)
                likeCount -= 1
            } else {
                try await PostService.shared.likePost(postId: post.id.uuidString)
                likeCount += 1
            }
            isLiked.toggle()
        } catch {
            print("Error toggling like: \(error)")
        }
        
        isLiking = false
    }
    
    private func saveOutfit() async {
        guard let outfit = post.outfit else { return }
        guard !isSavingOutfit else { return }
        
        isSavingOutfit = true
        
        do {
            // Save the outfit using the saved outfits functionality
            try await OutfitService.shared.saveOutfit(outfitId: outfit.id.uuidString)
            print("✅ Outfit saved successfully: \(outfit.name ?? "Unknown")")
            
            // Update UI state
            isOutfitSaved = true
            
        } catch {
            print("❌ Error saving outfit: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            // You could show an error alert here if needed
        }
        
        isSavingOutfit = false
    }
    
    private func unsaveOutfit() async {
        guard let outfit = post.outfit else { return }
        guard !isSavingOutfit else { return }
        
        isSavingOutfit = true
        
        do {
            // Unsave the outfit using the saved outfits functionality
            try await OutfitService.shared.unsaveOutfit(outfitId: outfit.id.uuidString)
            print("✅ Outfit unsaved successfully: \(outfit.name ?? "Unknown")")
            
            // Update UI state
            isOutfitSaved = false
            
        } catch {
            print("❌ Error unsaving outfit: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            // You could show an error alert here if needed
        }
        
        isSavingOutfit = false
    }
    
    private func checkIfOutfitIsSaved() async {
        guard let outfit = post.outfit else { return }
        print("🔍 Starting outfit saved status check for post: \(post.id)")
        
        do {
            // Check if the outfit is saved using the saved outfits functionality
            let isSaved = try await OutfitService.shared.checkSavedStatus(outfitId: outfit.id.uuidString)
            
            await MainActor.run {
                isOutfitSaved = isSaved
            }
            
            print("🔍 Outfit saved status checked: \(isSaved)")
        } catch {
            print("❌ Error checking saved status: \(error)")
        }
    }
    
    private func createShareItems() -> [Any] {
        var items: [Any] = []
        
        // Add share text
        var shareText = "Check out this outfit from \(post.username) on OutfitEase!\n\n"
        
        if !post.caption.isEmpty {
            shareText += "\(post.caption)\n\n"
        }
        
        if let outfit = post.outfit, let outfitName = outfit.name {
            shareText += "Outfit: \(outfitName)\n"
            
            if let description = outfit.description, !description.isEmpty {
                shareText += "Description: \(description)\n"
            }
            
            if let totalPrice = outfit.totalPrice {
                shareText += "Price: $\(String(format: "%.2f", totalPrice))\n"
            }
        }
        
        shareText += "\nDownload OutfitEase to discover more amazing outfits! 👗✨"
        
        items.append(shareText)
        
        // Add image URL if available
        if let imageURL = post.imageURL, !imageURL.isEmpty {
            items.append(URL(string: imageURL)!)
        }
        
        return items
    }
}



#Preview {
    PostDetailView(post: Post(
        id: UUID(),
        userId: UUID(),
        username: "sample_user",
        avatarURL: nil,
        caption: "Sample post caption with detailed outfit information",
        imageURL: nil,
        createdAt: "2024-01-01T10:30:00Z",
        likeCount: 5,
        commentCount: 3,
        isLiked: false,
        outfitId: UUID(),
        outfit: Outfit(
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
        )
    ))
} 