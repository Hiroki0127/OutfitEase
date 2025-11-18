import SwiftUI
import UIKit

struct ClothingDetailView: View {
    let clothingItem: ClothingItem
    @ObservedObject var clothingViewModel: ClothingViewModel
    @ObservedObject var outfitViewModel: OutfitViewModel
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image Section
                if let imageURL = clothingItem.imageUrl, !imageURL.isEmpty {
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
                    // Fallback to placeholder when no image URL is available
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 300)
                        .padding()
                        .overlay(
                            VStack {
                                Image(systemName: "tshirt")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 150)
                                    .foregroundColor(.gray)
                                Text("No Photo Available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }
                
                // Details Section
                VStack(alignment: .leading, spacing: 16) {
                    Text(clothingItem.name)
                        .font(.appHeadline2)
                    
                    // Tags
                    if let type = clothingItem.type, !type.isEmpty {
                        TagSection(title: "Type", tags: [type])
                    }
                    
                    if let color = clothingItem.color, !color.isEmpty {
                        // Split color string into array if it contains multiple colors
                        let colors = color.components(separatedBy: ", ").filter { !$0.isEmpty }
                        TagSection(title: "Colors", tags: colors)
                    }
                    
                    if let style = clothingItem.style, !style.isEmpty {
                        TagSection(title: "Style", tags: [style])
                    }
                    
                    if let brand = clothingItem.brand, !brand.isEmpty {
                        TagSection(title: "Brand", tags: [brand])
                    }
                    
                    if let season = clothingItem.season, !season.isEmpty {
                        TagSection(title: "Seasons", tags: season)
                    }
                    
                    if let occasion = clothingItem.occasion, !occasion.isEmpty {
                        TagSection(title: "Occasions", tags: occasion)
                    }
                    
                    if let price = clothingItem.price {
                        HStack {
                            Text("Price:")
                                .font(.appLabel)
                            Text("$\(price, specifier: "%.2f")")
                                .font(.appLabel)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Actions
                    HStack(spacing: 12) {
                        NavigationLink(destination: CreateOutfitView(outfitViewModel: outfitViewModel, selectedClothingItemId: clothingItem.id, onOutfitCreated: nil)) {
                            Text("Add to Outfit")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .font(.subheadline)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button("Share") {
                            shareClothingItem()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.subheadline)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Clothing Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button("Edit") {
                        showEditSheet = true
                    }
                    .foregroundColor(.blue)
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditClothingView(clothingItem: clothingItem, clothingViewModel: clothingViewModel)
        }
        .alert("Delete Clothing Item", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await deleteClothingItem()
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(clothingItem.name)'? This action cannot be undone.")
        }
    }
    
    private func deleteClothingItem() async {
        await clothingViewModel.deleteClothingItem(id: clothingItem.id)
        if clothingViewModel.errorMessage == nil {
            dismiss()
        }
    }
    
    private func shareClothingItem() {
        let itemName = clothingItem.name
        let itemType = clothingItem.type ?? "Unknown type"
        let itemBrand = clothingItem.brand ?? "Unknown brand"
        let itemColor = clothingItem.color ?? "Unknown color"
        
        let shareText = """
        Check out this clothing item from OutfitEase!
        
        Name: \(itemName)
        Type: \(itemType)
        Brand: \(itemBrand)
        Color: \(itemColor)
        
        Shared from OutfitEase app
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}



struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct EditClothingView: View {
    let clothingItem: ClothingItem
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var clothingViewModel: ClothingViewModel
    
    @State private var name: String
    @State private var type: String
    @State private var selectedColors: Set<String> = []
    @State private var style: String
    @State private var brand: String
    @State private var price: String
    @State private var selectedSeasons: Set<String> = []
    @State private var selectedOccasions: Set<String> = []
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isUploadingImage = false
    
    private let clothingTypes = ["Shirt", "Pants", "Dress", "Shoes", "Accessory", "Outerwear", "Other"]
    private let seasons = ["Spring", "Summer", "Fall", "Winter", "All Season"]
    private let occasions = ["Casual", "Formal", "Business", "Sport", "Evening", "Other"]
    
    init(clothingItem: ClothingItem, clothingViewModel: ClothingViewModel) {
        self.clothingItem = clothingItem
        self.clothingViewModel = clothingViewModel
        _name = State(initialValue: clothingItem.name)
        _type = State(initialValue: clothingItem.type ?? "")
        _selectedColors = State(initialValue: Set(clothingItem.color?.components(separatedBy: ", ") ?? []))
        _style = State(initialValue: clothingItem.style ?? "")
        _brand = State(initialValue: clothingItem.brand ?? "")
        _price = State(initialValue: clothingItem.price?.description ?? "")
        _selectedSeasons = State(initialValue: Set(clothingItem.season ?? []))
        _selectedOccasions = State(initialValue: Set(clothingItem.occasion ?? []))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Clothing Image") {
                    VStack(alignment: .center, spacing: 12) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(12)
                        } else if let imageURL = clothingItem.imageUrl, !imageURL.isEmpty {
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
                                        Image(systemName: "tshirt")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("No Photo")
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
                    TextField("Item Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        Text("Select Type").tag("")
                        ForEach(clothingTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    
                    TextField("Style", text: $style)
                    TextField("Brand", text: $brand)
                }
                
                Section("Colors") {
                    ColorSelectionView(selectedColors: $selectedColors)
                }
                
                Section("Details") {
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
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
            .navigationTitle("Edit Clothing")
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
                    .disabled(!isFormValid || clothingViewModel.isLoading || isUploadingImage)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty
    }
    
    private func saveChanges() {
        Task {
            var imageURL: String? = clothingItem.imageUrl
            
            // Upload new image if selected
            if let selectedImage = selectedImage {
                isUploadingImage = true
                do {
                    let uploadService = UploadService.shared
                    imageURL = try await uploadService.uploadImage(selectedImage)
                } catch {
                    print("Failed to upload image: \(error)")
                    // Continue without image upload
                }
                isUploadingImage = false
            }
            
            let priceValue = Double(price) ?? 0.0
            
            let request = UpdateClothingItemRequest(
                name: name,
                type: type.isEmpty ? nil : type,
                color: selectedColors.isEmpty ? nil : selectedColors.joined(separator: ", "),
                style: style.isEmpty ? nil : style,
                brand: brand.isEmpty ? nil : brand,
                price: priceValue > 0 ? priceValue : nil,
                season: selectedSeasons.isEmpty ? nil : Array(selectedSeasons),
                occasion: selectedOccasions.isEmpty ? nil : Array(selectedOccasions),
                imageUrl: imageURL
            )
            
            await clothingViewModel.updateClothingItem(id: clothingItem.id, request)
            if clothingViewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationView {
        ClothingDetailView(
            clothingItem: ClothingItem(
                id: "preview",
                userId: "preview",
                name: "Sample Item",
                type: "Shirt",
                color: "Blue",
                style: "Casual",
                brand: "Nike",
                price: 25.99,
                season: ["Summer"],
                occasion: ["Casual"],
                imageUrl: nil,
                createdAt: "2024-01-01"
            ),
            clothingViewModel: ClothingViewModel(),
            outfitViewModel: OutfitViewModel()
        )
    }
}
