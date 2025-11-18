import SwiftUI

struct PostCardView: View {
    let post: Post
    let canDelete: Bool
    let onDelete: (() async -> Void)?
    let onUserTapped: (() -> Void)?
    @StateObject private var commentViewModel = CommentViewModel()
    @State private var showComments = false
    @State private var showPostDetail = false
    @State private var newComment = ""
    @State private var isLiked: Bool
    @State private var likeCount: Int
    @State private var isLiking = false
    @State private var showShareSheet = false
    @State private var isSavingOutfit = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var isOutfitSaved = false
    @State private var hasCheckedSavedStatus = false
    
    init(
        post: Post,
        canDelete: Bool = false,
        onDelete: (() async -> Void)? = nil,
        onUserTapped: (() -> Void)? = nil
    ) {
        self.post = post
        self.canDelete = canDelete
        self.onDelete = onDelete
        self.onUserTapped = onUserTapped
        self._isLiked = State(initialValue: post.isLiked)
        self._likeCount = State(initialValue: post.likeCount)
    }
    
    @ViewBuilder
    private var userHeaderContent: some View {
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
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    @unknown default:
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(post.username)
                    .font(.appLabel)
                
                Text(post.createdAt)
                    .font(.appCaption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info Header
            HStack {
                if let onUserTapped = onUserTapped {
                    Button(action: onUserTapped) {
                        userHeaderContent
                    }
                    .buttonStyle(.plain)
                } else {
                    userHeaderContent
                }
                
                Spacer()
                
                if canDelete {
                    Menu {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Post", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Post Content
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.appBody)
                    .multilineTextAlignment(.leading)
            }
            
            // Outfit Image
            if let imageURL = post.imageURL, !imageURL.isEmpty {
                // Show actual image from URL
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
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
            } else {
                // Show placeholder when no image
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Outfit Image")
                                .font(.appCaption)
                                .foregroundColor(.gray)
                        }
                    )
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
                            .font(.appCaption)
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
                            .font(.appCaption)
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
                            .font(.title3)
                    }
                    .disabled(isSavingOutfit)
                }
                
                Spacer()
            }
            .font(.appBodySmall)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .sheet(isPresented: $showComments) {
            CommentsView(post: post)
        }
        .sheet(isPresented: $showPostDetail) {
            PostDetailView(post: post)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: createShareItems())
        }

        .onTapGesture {
            showPostDetail = true
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
        .confirmationDialog("Delete this post?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    guard !isDeleting, let onDelete else { return }
                    isDeleting = true
                    await onDelete()
                    isDeleting = false
                }
            }
            Button("Cancel", role: .cancel) { }
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
    
    private func createShareItems() -> [Any] {
        var items: [Any] = []
        
        // Add share text
        var shareText = "Check out this outfit from \(post.username) on OutfitEase!\n\n"
        
        if !post.caption.isEmpty {
            shareText += "\(post.caption)\n\n"
        }
        
        if let outfit = post.outfit, let outfitName = outfit.name {
            shareText += "Outfit: \(outfitName)\n"
        }
        
        shareText += "\nDownload OutfitEase to discover more amazing outfits! 👗✨"
        
        items.append(shareText)
        
        // Add image URL if available
        if let imageURL = post.imageURL, !imageURL.isEmpty {
            items.append(URL(string: imageURL)!)
        }
        
        return items
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
}

#Preview {
    PostCardView(post: Post(
        id: UUID(),
        userId: UUID(),
        username: "sample_user",
        avatarURL: nil,
        caption: "Sample post caption",
        imageURL: nil,
        createdAt: "2024-01-01T10:30:00Z",
        likeCount: 0,
        commentCount: 0,
        isLiked: false,
        outfitId: nil,
        outfit: nil
    ))
}
