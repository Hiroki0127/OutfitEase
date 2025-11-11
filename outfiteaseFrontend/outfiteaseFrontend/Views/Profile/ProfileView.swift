import SwiftUI

struct ProfileView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
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
                                StatCard(title: "Posts", value: "\(profileViewModel.postCount)", icon: "photo.stack.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(0.98)
                        }
                        
                        HStack(spacing: 20) {
                            StatCard(title: "Followers", value: "\(profileViewModel.followerCount)", icon: "person.2.fill")
                            
                            StatCard(title: "Following", value: "\(profileViewModel.followingCount)", icon: "person.2.wave.2.fill")
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
                async let clothingTask = clothingViewModel.loadClothingItems()
                async let outfitTask = outfitViewModel.loadOutfits()
                async let profileTask = profileViewModel.loadProfileDetails()
                _ = await (clothingTask, outfitTask, profileTask)
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

struct PublicProfileView: View {
    let userId: String
    @StateObject private var viewModel = PublicProfileViewModel()
    @State private var hasLoaded = false
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.profile == nil {
                ProgressView("Loading profile...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let profile = viewModel.profile {
                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader(profile)
                        statsSection(profile)
                        postsSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .refreshable {
                    await viewModel.loadProfile(userId: userId)
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Profile unavailable")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
            }
        }
        .navigationTitle(viewModel.profile?.user.username ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await viewModel.loadProfile(userId: userId)
        }
    }
    
    @ViewBuilder
    private func profileHeader(_ profile: PublicProfileResponse) -> some View {
        VStack(spacing: 16) {
            if let avatarUrl = profile.user.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        defaultAvatar
                    @unknown default:
                        defaultAvatar
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                defaultAvatar
                    .frame(width: 100, height: 100)
            }
            
            VStack(spacing: 6) {
                Text(profile.user.username)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if !profile.isSelf {
                    Text("Member since \(formattedDate(profile.user.createdAt))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !profile.isSelf {
                Button {
                    Task {
                        await viewModel.toggleFollow()
                    }
                } label: {
                    Text(profile.isFollowing ? "Following" : "Follow")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(profile.isFollowing ? .bordered : .borderedProminent)
                .tint(profile.isFollowing ? .gray : .blue)
                .disabled(viewModel.isFollowActionInProgress)
            }
        }
    }
    
    @ViewBuilder
    private func statsSection(_ profile: PublicProfileResponse) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(title: "Posts", value: "\(profile.stats.postCount)", icon: "photo.stack.fill")
                StatCard(title: "Outfits", value: "\(profile.stats.outfitCount)", icon: "person.2.fill")
            }
            
            HStack(spacing: 20) {
                StatCard(title: "Followers", value: "\(profile.stats.followerCount)", icon: "person.2.fill")
                StatCard(title: "Following", value: "\(profile.stats.followingCount)", icon: "person.2.wave.2.fill")
            }
        }
    }
    
    @ViewBuilder
    private var postsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Posts")
                .font(.headline)
            
            if viewModel.posts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.6))
                    Text("No posts yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.posts) { post in
                        PostCardView(post: post)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var defaultAvatar: some View {
        Circle()
            .fill(Color.blue.opacity(0.2))
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            )
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString.prefix(10).description
    }
}

#Preview {
    ProfileView(clothingViewModel: ClothingViewModel(), outfitViewModel: OutfitViewModel(), authViewModel: AuthViewModel())
}
