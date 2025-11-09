import SwiftUI

struct MyPostsView: View {
    @StateObject private var postViewModel = PostViewModel()
    @State private var showCreatePost = false
    
    var body: some View {
        VStack {
            if postViewModel.isLoading {
                ProgressView("Loading your posts...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if postViewModel.posts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Posts Yet")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Share an outfit to see it here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(postViewModel.posts) { post in
                            PostCardView(post: post, canDelete: true) {
                                await deletePost(post)
                            }
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("My Posts")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCreatePost = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
        .task {
            await postViewModel.loadUserPosts()
        }
        .refreshable {
            await postViewModel.loadUserPosts()
        }
    }
    
    private func deletePost(_ post: Post) async {
        await postViewModel.deletePost(id: post.id)
        await postViewModel.loadUserPosts()
    }
}

#Preview {
    NavigationView {
        MyPostsView()
    }
}

