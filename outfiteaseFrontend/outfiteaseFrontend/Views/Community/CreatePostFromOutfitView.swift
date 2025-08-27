import SwiftUI

struct CreatePostFromOutfitView: View {
    let outfit: Outfit
    @Environment(\.dismiss) private var dismiss
    @StateObject private var postViewModel = PostViewModel()
    @State private var caption = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
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
                    
                    // Caption Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a caption...")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("Share your thoughts about this outfit...", text: $caption, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    // Create Post Button
                    Button(action: createPost) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }
                            Text(isLoading ? "Creating Post..." : "Share to Community")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canCreatePost ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!canCreatePost || isLoading)
                }
                .padding()
            }
            .navigationTitle("Share Outfit")
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
    
    private var canCreatePost: Bool {
        !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func createPost() {
        let trimmedCaption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCaption.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await postViewModel.createPostFromOutfit(outfit: outfit, caption: trimmedCaption)
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    CreatePostFromOutfitView(outfit: Outfit(
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