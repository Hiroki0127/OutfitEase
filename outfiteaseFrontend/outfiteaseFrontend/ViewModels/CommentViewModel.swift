import Foundation
import SwiftUI

@MainActor
class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var replyingTo: Comment?
    @Published var replyText = ""
    
    private let commentService = CommentService.shared
    
    func loadComments(postId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            comments = try await commentService.getComments(postId: postId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addComment(postId: UUID, comment: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newComment = try await commentService.createComment(CreateCommentRequest(postId: postId, comment: comment))
            comments.append(newComment)
            // Clear any error message on success
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteComment(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await commentService.deleteComment(id: id)
            comments.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Reply functionality
    func addReply(parentCommentId: UUID, comment: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newReply = try await commentService.addReply(CreateReplyRequest(parentCommentId: parentCommentId, comment: comment))
            
            // Recursively find and update the parent comment (could be a top-level comment or a reply)
            updateCommentWithReply(parentCommentId: parentCommentId, newReply: newReply, in: &comments)
            
            // Clear reply state
            replyingTo = nil
            replyText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Recursive function to find and update comments with replies
    private func updateCommentWithReply(parentCommentId: UUID, newReply: Comment, in comments: inout [Comment]) {
        for i in 0..<comments.count {
            if comments[i].id == parentCommentId {
                // Found the parent comment, add the reply
                var updatedComment = comments[i]
                var replies = updatedComment.replies ?? []
                replies.append(newReply)
                comments[i] = Comment(
                    id: updatedComment.id,
                    postId: updatedComment.postId,
                    userId: updatedComment.userId,
                    comment: updatedComment.comment,
                    createdAt: updatedComment.createdAt,
                    parentCommentId: updatedComment.parentCommentId,
                    replies: replies,
                    username: updatedComment.username
                )
                return
            } else if let replies = comments[i].replies {
                // Check in replies recursively
                var updatedReplies = replies
                updateCommentWithReply(parentCommentId: parentCommentId, newReply: newReply, in: &updatedReplies)
                if updatedReplies != replies {
                    // Update the comment with the new replies
                    var updatedComment = comments[i]
                    comments[i] = Comment(
                        id: updatedComment.id,
                        postId: updatedComment.postId,
                        userId: updatedComment.userId,
                        comment: updatedComment.comment,
                        createdAt: updatedComment.createdAt,
                        parentCommentId: updatedComment.parentCommentId,
                        replies: updatedReplies,
                        username: updatedComment.username
                    )
                    return
                }
            }
        }
    }
    
    func loadReplies(commentId: UUID) async {
        do {
            let replies = try await commentService.getReplies(commentId: commentId)
            
            // Update the comment with replies
            if let index = comments.firstIndex(where: { $0.id == commentId }) {
                var updatedComment = comments[index]
                comments[index] = Comment(
                    id: updatedComment.id,
                    postId: updatedComment.postId,
                    userId: updatedComment.userId,
                    comment: updatedComment.comment,
                    createdAt: updatedComment.createdAt,
                    parentCommentId: updatedComment.parentCommentId,
                    replies: replies,
                    username: updatedComment.username
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
