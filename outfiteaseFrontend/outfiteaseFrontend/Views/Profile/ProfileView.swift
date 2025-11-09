import SwiftUI

struct ProfileView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var postViewModel = PostViewModel()
    @ObservedObject var clothingViewModel: ClothingViewModel
    @ObservedObject var outfitViewModel: OutfitViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showSettings = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isUploadingImage = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar
                        Button(action: {
                            showImagePicker = true
                        }) {
                            ZStack {
                                if let avatarUrl = profileViewModel.currentUser?.avatarUrl, !avatarUrl.isEmpty {
                                    AsyncImage(url: URL(string: avatarUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.blue)
                                            )
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.blue)
                                        )
                                }
                                
                                // Edit icon overlay
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 35, y: 35)
                            }
                        }
                        .disabled(isUploadingImage)
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(profileViewModel.currentUser?.username ?? "User")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(profileViewModel.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Stats Section
                    VStack(spacing: 16) {
                        Text("Your Stats")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 20) {
                            NavigationLink(destination: ClothingListView(clothingViewModel: clothingViewModel, outfitViewModel: outfitViewModel)) {
                                StatCard(title: "Clothes", value: "\(clothingViewModel.clothingItems.count)", icon: "tshirt.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(0.98)
                            
                            NavigationLink(destination: OutfitListView(outfitViewModel: outfitViewModel)) {
                                StatCard(title: "Outfits", value: "\(outfitViewModel.outfits.count)", icon: "person.2.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(0.98)
                            
                            NavigationLink(destination: MyPostsView()) {
                                StatCard(title: "Posts", value: "\(postViewModel.posts.count)", icon: "photo.stack.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(0.98)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(spacing: 16) {
                        Text("Quick Actions")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            NavigationLink(destination: AddClothingView(clothingViewModel: clothingViewModel)) {
                                QuickActionRow(title: "Add Clothing", icon: "plus.circle.fill", color: .blue)
                            }
                            
                            NavigationLink(destination: CreateOutfitView(outfitViewModel: outfitViewModel, selectedClothingItemId: nil, onOutfitCreated: nil)) {
                                QuickActionRow(title: "Create Outfit", icon: "person.2.circle.fill", color: .green)
                            }
                            
                            NavigationLink(destination: CreatePostView()) {
                                QuickActionRow(title: "Share Outfit", icon: "square.and.arrow.up.circle.fill", color: .orange)
                            }
                            
                            NavigationLink(destination: LikedContentView()) {
                                QuickActionRow(title: "Liked Content", icon: "heart.circle.fill", color: .red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Settings Section
                    VStack(spacing: 16) {
                        Text("Settings")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                showSettings = true
                            }) {
                                QuickActionRow(title: "App Settings", icon: "gear.circle.fill", color: .gray)
                            }
                            
                            Button(action: {
                                profileViewModel.logout()
                                authViewModel.logout()
                            }) {
                                QuickActionRow(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", color: .red)
                            }
                            
                            // Testing Helper Button
                            Button(action: {
                                authViewModel.resetForTesting()
                            }) {
                                QuickActionRow(title: "Reset for Testing", icon: "arrow.clockwise.circle.fill", color: .purple)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .task {
                await clothingViewModel.loadClothingItems()
                await outfitViewModel.loadOutfits()
                await postViewModel.loadUserPosts()
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage {
                    uploadProfileImage(image)
                }
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        isUploadingImage = true
        
        Task {
            do {
                // Upload image to get URL
                let imageURL = try await UploadService.shared.uploadImage(image)
                
                // Update profile with new avatar URL
                await profileViewModel.updateProfile(avatarUrl: imageURL)
                
                // Clear selected image
                selectedImage = nil
                
            } catch {
                print("Error uploading profile image: \(error)")
            }
            
            isUploadingImage = false
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct QuickActionRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView(clothingViewModel: ClothingViewModel(), outfitViewModel: OutfitViewModel(), authViewModel: AuthViewModel())
}
