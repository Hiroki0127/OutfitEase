import SwiftUI

struct PostFeedView: View {
    @StateObject private var postViewModel = PostViewModel()
    @State private var showCreatePost = false

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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
            .task {
                await postViewModel.loadPosts()
            }
        }
    }


}


#Preview {
    PostFeedView()
}


/*
 } else {
     ScrollView {
         LazyVStack(spacing: 16) {
             ForEach(posts) { post in
                 PostCardView(post: post)
                     .padding(.horizontal)
             }
 */
