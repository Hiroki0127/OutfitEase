import SwiftUI

struct OutfitDetailView: View {
    let outfit: Outfit
    @ObservedObject var outfitViewModel: OutfitViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showCreatePostSheet = false
    @State private var showPlanningSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Outfit Image
                if let imageURL = outfit.imageURL, !imageURL.isEmpty {
                    // Display actual image from URL
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(12)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                } else {
                    // Placeholder when no image
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("No Outfit Photo")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }
                
                // Details Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(outfit.name ?? "Untitled Outfit")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button("Edit") {
                            showEditSheet = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    if let description = outfit.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Tags
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
                        TagSection(title: "Seasons", tags: season)
                    }
                    
                    if let occasion = outfit.occasion, !occasion.isEmpty {
                        TagSection(title: "Occasions", tags: occasion)
                    }
                    
                    if let totalPrice = outfit.totalPrice {
                        HStack {
                            Text("Total Price:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("$\(totalPrice, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Clothing Pieces Section
                    if let items = outfit.items, !items.isEmpty {
                        ClothingPiecesSection(clothingItems: items)
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button("Plan This Outfit") {
                            showPlanningSheet = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Share to Community") {
                            showCreatePostSheet = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Outfit Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                EditOutfitView(outfit: outfit, outfitViewModel: outfitViewModel)
            }
        }
        .sheet(isPresented: $showCreatePostSheet) {
            CreatePostFromOutfitView(outfit: outfit)
        }
        .sheet(isPresented: $showPlanningSheet) {
            PlanOutfitView(outfit: outfit)
        }
        .alert("Delete Outfit", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteOutfit()
            }
        } message: {
            Text("Are you sure you want to delete this outfit? This action cannot be undone.")
        }
    }
    
    private func deleteOutfit() {
        Task {
            print("🗑️ Deleting outfit: \(outfit.id)")
            await outfitViewModel.deleteOutfit(id: outfit.id)
            if outfitViewModel.errorMessage == nil {
                print("✅ Outfit deleted successfully")
                dismiss()
            } else {
                print("❌ Failed to delete outfit: \(outfitViewModel.errorMessage ?? "Unknown error")")
            }
        }
    }
}

struct TagSection: View {
    let title: String
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct ClothingPiecesSection: View {
    let clothingItems: [ClothingItem]
    @StateObject private var clothingViewModel = ClothingViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clothing Pieces Used")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach(clothingItems, id: \.id) { item in
                    NavigationLink(destination: ClothingDetailView(
                        clothingItem: item,
                        clothingViewModel: clothingViewModel,
                        outfitViewModel: OutfitViewModel()
                    )) {
                        HStack {
                            // Clothing item image
                            if let imageURL = item.imageUrl, !imageURL.isEmpty {
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                        .cornerRadius(8)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "tshirt")
                                                .foregroundColor(.gray)
                                        )
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "tshirt")
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                if let type = item.type, !type.isEmpty {
                                    Text(type)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let brand = item.brand, !brand.isEmpty {
                                    Text(brand)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct EditOutfitView: View {
    let outfit: Outfit
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var outfitViewModel: OutfitViewModel
    
    @State private var name: String
    @State private var description: String
    @State private var selectedStyles: Set<String>
    @State private var selectedColors: Set<String>
    @State private var selectedBrands: Set<String>
    @State private var selectedSeasons: Set<String>
    @State private var selectedOccasions: Set<String>
    @State private var totalPrice: String
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isUploadingImage = false
    @State private var brand = ""
    @State private var brands: [String] = []
    
    private let styles = ["Casual", "Formal", "Business", "Sport", "Streetwear", "Vintage", "Minimalist"]
    private let defaultBrands = ["Nike", "Adidas", "Zara", "H&M", "Uniqlo", "Gap", "Levi's", "Other"]
    private let seasons = ["Spring", "Summer", "Fall", "Winter", "All Season"]
    private let occasions = ["Casual", "Formal", "Business", "Sport", "Evening", "Weekend", "Travel"]
    
    init(outfit: Outfit, outfitViewModel: OutfitViewModel) {
        self.outfit = outfit
        self.outfitViewModel = outfitViewModel
        _name = State(initialValue: outfit.name ?? "")
        _description = State(initialValue: outfit.description ?? "")
        _selectedStyles = State(initialValue: Set(outfit.style ?? []))
        _selectedColors = State(initialValue: Set(outfit.color ?? []))
        _selectedBrands = State(initialValue: Set(outfit.brand ?? []))
        _selectedSeasons = State(initialValue: Set(outfit.season ?? []))
        _selectedOccasions = State(initialValue: Set(outfit.occasion ?? []))
        _totalPrice = State(initialValue: outfit.totalPrice != nil ? String(format: "%.2f", outfit.totalPrice!) : "")
        _brands = State(initialValue: outfit.brand ?? [])
    }
    
    var body: some View {
        Form {
                Section("Outfit Image") {
                    VStack(alignment: .center, spacing: 12) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)
                        } else if let imageURL = outfit.imageURL, !imageURL.isEmpty {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(12)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 200)
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
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
                        
                        Button(selectedImage != nil ? "Change Photo" : "Add Photo") {
                            showImagePicker = true
                        }
                        .foregroundColor(.blue)
                        
                        if selectedImage != nil {
                            Button("Remove Photo") {
                                selectedImage = nil
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Basic Information") {
                    TextField("Outfit Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Total Price", text: $totalPrice)
                        .keyboardType(.decimalPad)
                }
                
                Section("Style") {
                    ForEach(styles, id: \.self) { style in
                        HStack {
                            Text(style)
                            Spacer()
                            if selectedStyles.contains(style) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedStyles.contains(style) {
                                selectedStyles.remove(style)
                            } else {
                                selectedStyles.insert(style)
                            }
                        }
                    }
                }
                
                Section("Colors") {
                    ColorSelectionView(selectedColors: $selectedColors)
                }
                
                Section("Brands") {
                    // Display existing brands
                    if !brands.isEmpty {
                        ForEach(brands, id: \.self) { brandName in
                            HStack {
                                Text(brandName)
                                Spacer()
                                if selectedBrands.contains(brandName) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedBrands.contains(brandName) {
                                    selectedBrands.remove(brandName)
                                } else {
                                    selectedBrands.insert(brandName)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) {
                                    if let index = brands.firstIndex(of: brandName) {
                                        brands.remove(at: index)
                                        selectedBrands.remove(brandName)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("No brands added yet")
                            .foregroundColor(.secondary)
                    }
                    
                    // Add new brand functionality
                    TextField("Enter brand name", text: $brand)
                        .autocapitalization(.words)
                    
                    Button(action: {
                        let trimmed = brand.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            brands.append(trimmed)
                            selectedBrands.insert(trimmed)
                            brand = "" // Clear input
                        }
                    }) {
                        Label("Add Brand", systemImage: "plus.circle")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.bordered)
                    
                    // Default brands section
                    Section("Quick Add Brands") {
                        ForEach(defaultBrands, id: \.self) { defaultBrand in
                            HStack {
                                Text(defaultBrand)
                                Spacer()
                                if brands.contains(defaultBrand) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if brands.contains(defaultBrand) {
                                    // Remove if already added
                                    if let index = brands.firstIndex(of: defaultBrand) {
                                        brands.remove(at: index)
                                        selectedBrands.remove(defaultBrand)
                                    }
                                } else {
                                    // Add if not already added
                                    brands.append(defaultBrand)
                                    selectedBrands.insert(defaultBrand)
                                }
                            }
                        }
                    }
                }
                
                Section("Seasons") {
                    ForEach(seasons, id: \.self) { season in
                        HStack {
                            Text(season)
                            Spacer()
                            if selectedSeasons.contains(season) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedSeasons.contains(season) {
                                selectedSeasons.remove(season)
                            } else {
                                selectedSeasons.insert(season)
                            }
                        }
                    }
                }
                
                Section("Occasions") {
                    ForEach(occasions, id: \.self) { occasion in
                        HStack {
                            Text(occasion)
                            Spacer()
                            if selectedOccasions.contains(occasion) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedOccasions.contains(occasion) {
                                selectedOccasions.remove(occasion)
                            } else {
                                selectedOccasions.insert(occasion)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isFormValid || outfitViewModel.isLoading || isUploadingImage)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty
    }
    
    private func saveChanges() {
        Task {
            var imageURL: String? = outfit.imageURL
            
            // Upload new image if selected
            if let selectedImage = selectedImage {
                isUploadingImage = true
                do {
                    let uploadService = UploadService.shared
                    imageURL = try await uploadService.uploadImage(selectedImage)
                    print("✅ Image uploaded successfully: \(imageURL ?? "nil")")
                } catch {
                    print("❌ Failed to upload image: \(error)")
                    // Continue without image upload
                }
                isUploadingImage = false
            }
            
            let request = UpdateOutfitRequest(
                name: name.isEmpty ? nil : name,
                description: description.isEmpty ? nil : description,
                totalPrice: Double(totalPrice),
                imageURL: imageURL,
                style: selectedStyles.isEmpty ? nil : Array(selectedStyles),
                color: selectedColors.isEmpty ? nil : Array(selectedColors),
                brand: selectedBrands.isEmpty ? nil : Array(selectedBrands),
                season: selectedSeasons.isEmpty ? nil : Array(selectedSeasons),
                occasion: selectedOccasions.isEmpty ? nil : Array(selectedOccasions)
            )
            
            print("📝 Saving outfit changes...")
            await outfitViewModel.updateOutfit(id: outfit.id, request)
            
            if outfitViewModel.errorMessage == nil {
                print("✅ Outfit updated successfully")
                dismiss()
            } else {
                print("❌ Failed to update outfit: \(outfitViewModel.errorMessage ?? "Unknown error")")
            }
        }
    }
}

#Preview {
    NavigationView {
        OutfitDetailView(outfit: Outfit(
            id: UUID(),
            userId: UUID(),
            name: "Casual Weekend Look",
            description: "A comfortable and stylish outfit for weekend activities",
            totalPrice: 89.99,
            style: ["Casual", "Streetwear"],
            color: ["Blue", "White"],
            brand: ["Nike", "Levi's"],
            season: ["Spring", "Summer"],
            occasion: ["Weekend", "Casual"],
            imageURL: nil,
            createdAt: "2024-01-01"
        ), outfitViewModel: OutfitViewModel())
    }
}


