import SwiftUI

struct CreatePostView: View {
    @StateObject private var postViewModel = PostViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var caption = ""
    @State private var selectedOutfit: Outfit?
    @State private var showOutfitPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Outfit Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Outfit")
                        .font(.headline)
                    
                    if let selectedOutfit = selectedOutfit {
                        OutfitSelectionCard(outfit: selectedOutfit) {
                            showOutfitPicker = true
                        }
                    } else {
                        Button(action: {
                            showOutfitPicker = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Choose an outfit to share")
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                
                // Caption
                VStack(alignment: .leading, spacing: 8) {
                    Text("Caption")
                        .font(.headline)
                    
                    TextField("Write a caption...", text: $caption, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                // Preview
                if let selectedOutfit = selectedOutfit {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview")
                            .font(.headline)
                        
                        PostPreviewCard(outfit: selectedOutfit, caption: caption)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        createPost()
                    }
                    .disabled(selectedOutfit == nil || postViewModel.isLoading)
                }
            }
            .sheet(isPresented: $showOutfitPicker) {
                OutfitPickerView(selectedOutfit: $selectedOutfit)
            }
        }
    }
    
    private func createPost() {
        guard let selectedOutfit = selectedOutfit else { return }
        
        let request = CreatePostRequest(
            outfitId: selectedOutfit.id,
            caption: caption.isEmpty ? nil : caption
        )
        
        Task {
            await postViewModel.createPost(request)
            if postViewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}

struct OutfitSelectionCard: View {
    let outfit: Outfit
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Outfit Image
                if let imageURL = outfit.imageURL, !imageURL.isEmpty {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.gray)
                            )
                    }
                    .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(outfit.name ?? "Untitled Outfit")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let description = outfit.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PostPreviewCard: View {
    let outfit: Outfit
    let caption: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    )
                
                Text("You")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Caption
            if !caption.isEmpty {
                Text(caption)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            
            // Outfit Image
            if let imageURL = outfit.imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                                Text("Outfit Preview")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            Text("Outfit Preview")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct OutfitPickerView: View {
    @Binding var selectedOutfit: Outfit?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var outfitViewModel = OutfitViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if outfitViewModel.isLoading {
                    ProgressView("Loading outfits...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if outfitViewModel.outfits.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No Outfits Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Create an outfit first to share it")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(outfitViewModel.outfits) { outfit in
                        Button(action: {
                            selectedOutfit = outfit
                            dismiss()
                        }) {
                            OutfitSelectionCard(outfit: outfit) {
                                selectedOutfit = outfit
                                dismiss()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Choose Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await outfitViewModel.loadOutfits()
        }
    }
}

#Preview {
    CreatePostView()
}
