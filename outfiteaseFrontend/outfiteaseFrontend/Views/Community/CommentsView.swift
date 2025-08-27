
import SwiftUI

struct CommentsView: View {
    let post: Post
    @StateObject private var commentViewModel = CommentViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if commentViewModel.isLoading {
                    ProgressView("Loading comments...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        // Comments List
                        if commentViewModel.comments.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "bubble.right")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No Comments Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Be the first to comment!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(commentViewModel.comments) { comment in
                                        CommentRow(comment: comment, commentViewModel: commentViewModel)
                                    }
                                }
                                .padding()
                            }
                        }
                        
                        // Error Message
                        if let errorMessage = commentViewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                        }
                        
                        // Add Comment Section
                        VStack(spacing: 12) {
                            Divider()
                            
                            // Reply to specific comment
                            if let replyingTo = commentViewModel.replyingTo {
                                HStack {
                                    Text("Replying to \(replyingTo.username ?? "User")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Button("Cancel") {
                                        commentViewModel.replyingTo = nil
                                        commentViewModel.replyText = ""
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                                .padding(.horizontal)
                            }
                            
                            HStack {
                                TextField(commentViewModel.replyingTo != nil ? "Add a reply..." : "Add a comment...", 
                                        text: commentViewModel.replyingTo != nil ? $commentViewModel.replyText : $newComment, 
                                        axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(1...3)
                                
                                Button(commentViewModel.replyingTo != nil ? "Reply" : "Post") {
                                    if commentViewModel.replyingTo != nil {
                                        addReply()
                                    } else {
                                        addComment()
                                    }
                                }
                                .disabled((commentViewModel.replyingTo != nil ? commentViewModel.replyText : newComment).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await commentViewModel.loadComments(postId: post.id)
        }
    }
    
    private func addComment() {
        let commentText = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !commentText.isEmpty else { return }
        
        Task {
            await commentViewModel.addComment(postId: post.id, comment: commentText)
            newComment = ""
        }
    }
    
    private func addReply() {
        let replyText = commentViewModel.replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !replyText.isEmpty, let replyingTo = commentViewModel.replyingTo else { return }
        
        Task {
            await commentViewModel.addReply(parentCommentId: replyingTo.id, comment: replyText)
        }
    }
}

struct CommentRow: View {
    let comment: Comment
    @ObservedObject var commentViewModel: CommentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // User Avatar
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Username and Time
                    HStack {
                        Text(comment.username ?? "User")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(comment.createdAt)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Reply") {
                            commentViewModel.replyingTo = comment
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    // Comment Text
                    Text(comment.comment)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
            }
            
            // Show replies if any
            if let replies = comment.replies, !replies.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(replies) { reply in
                        ReplyRow(reply: reply, commentViewModel: commentViewModel, depth: 1)
                    }
                }
                .padding(.leading, 44) // Indent replies
            }
        }
    }
}

struct ReplyRow: View {
    let reply: Comment
    @ObservedObject var commentViewModel: CommentViewModel
    let depth: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // Smaller avatar for replies
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    // Username and Time
                    HStack {
                        Text(reply.username ?? "User")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text(reply.createdAt)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Reply") {
                            commentViewModel.replyingTo = reply
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                    }
                    
                    // Reply Text
                    Text(reply.comment)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
            }
            
            // Show nested replies if any
            if let nestedReplies = reply.replies, !nestedReplies.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(nestedReplies) { nestedReply in
                        ReplyRow(reply: nestedReply, commentViewModel: commentViewModel, depth: depth + 1)
                    }
                }
                .padding(.leading, 32) // Indent nested replies
            }
        }
    }
}

#Preview {
    CommentsView(post: Post(
        id: UUID(),
        userId: UUID(),
        username: "sample_user",
        avatarURL: nil,
        caption: "Sample post",
        imageURL: nil,
        createdAt: "2024-01-01",
        likeCount: 0,
        commentCount: 0,
        isLiked: false,
        outfitId: nil,
        outfit: nil
    ))
}
