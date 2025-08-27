import SwiftUI

struct FeedView: View {
    @StateObject private var postViewModel = PostViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if postViewModel.isLoading {
                    ProgressView("Loading posts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if postViewModel.posts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Posts Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Be the first to share your outfit!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Create Post") {
                            // TODO: Navigate to create post
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(postViewModel.posts) { post in
                                PostCardView(post: post)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Navigate to create post
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await postViewModel.loadPosts()
            }
        }
        .task {
            await postViewModel.loadPosts()
        }
        .onAppear {
            // Comment out sample data loading for real backend testing
            // if postViewModel.posts.isEmpty {
            //     postViewModel.loadSamplePosts()
            // }
        }
    }
}

#Preview {
    FeedView()
}
