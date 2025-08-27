import SwiftUI

struct LikedPostsView: View {
    @StateObject private var viewModel = LikedPostsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading liked posts...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.likedPosts.isEmpty {
                emptyStateView
            } else {
                postsList
            }
        }
        .onAppear {
            Task {
                await viewModel.loadLikedPosts()
            }
        }
        .refreshable {
            await viewModel.loadLikedPosts()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Liked Posts")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Posts you like will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var postsList: some View {
        List(viewModel.likedPosts) { post in
            LikedPostRow(post: post)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
    }
}

struct LikedPostRow: View {
    let post: LikedPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info header
            HStack {
                AsyncImage(url: URL(string: post.avatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(formatDate(post.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("\(post.likesCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("\(post.commentsCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Caption
            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
            }
            
            // Outfit image if available
            if let outfitImageUrl = post.outfitImageUrl, !outfitImageUrl.isEmpty {
                AsyncImage(url: URL(string: outfitImageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Outfit name if available
            if let outfitName = post.outfitName, !outfitName.isEmpty {
                Text("Outfit: \(outfitName)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    LikedPostsView()
}
