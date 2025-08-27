import SwiftUI

struct CreateOutfitView: View {
    @ObservedObject var outfitViewModel: OutfitViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Optional parameter for when coming from clothing detail view
    let selectedClothingItemId: String?
    
    // Callback to notify parent when outfit is created
    var onOutfitCreated: (() -> Void)?
    
    @State private var name = ""
    @State private var description = ""
    @State private var brand = ""
    @State private var totalPrice = ""
    @State private var selectedStyles: Set<String> = []
    @State private var selectedColors: Set<String> = []
    @State private var selectedBrands: Set<String> = []
    @State private var selectedSeasons: Set<String> = []
    @State private var selectedOccasions: Set<String> = []
    @State private var brands: [String] = []
    @State private var selectedImage: UIImage?
    
    private let styles = ["Casual", "Formal", "Business", "Sport", "Streetwear", "Vintage", "Minimalist"]
    private let seasons = ["Spring", "Summer", "Fall", "Winter", "All Season"]
    private let occasions = ["Casual", "Formal", "Business", "Sport", "Evening", "Weekend", "Travel"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Outfit Photo") {
                    ImageUploadView(selectedImage: $selectedImage)
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



                
                Section(header: Text("Brands")) {
                    if !brands.isEmpty {
                        Text(brands.joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(.primary)
                    } else {
                        Text("No brands added yet")
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Enter brand name", text: $brand)
                        //.textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    
                    
                    Button(action: {
                        let trimmed = brand.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            brands.append(trimmed)
                            brand = "" // Clear input
                        }
                        //brands.append("") // add empty string for new brand
                    }) {
                        Label("Add Brand", systemImage: "plus.circle")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.bordered)
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
            .navigationTitle("Create Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Create") {
                    createOutfit()
                }
                .disabled(!isFormValid)
                .opacity(!isFormValid ? 0.5 : 1.0)
            )
            .alert("Error", isPresented: .constant(outfitViewModel.errorMessage != nil)) {
                Button("OK") {
                    outfitViewModel.errorMessage = nil
                }
            } message: {
                Text(outfitViewModel.errorMessage ?? "")
            }
        }
    }
    
    private var isFormValid: Bool {
        return !name.isEmpty
    }
    
    private func createOutfit() {
        Task {
            var imageURL: String? = nil
            
            // Upload image if selected
            if let selectedImage = selectedImage {
                do {
                    let uploadService = UploadService.shared
                    imageURL = try await uploadService.uploadImage(selectedImage)
                } catch {
                    print("Failed to upload image: \(error)")
                    // Continue without image upload
                }
            }
            
            let request = CreateOutfitRequest(
                name: name.isEmpty ? nil : name,
                description: description.isEmpty ? nil : description,
                totalPrice: Double(totalPrice),
                imageURL: imageURL,
                style: selectedStyles.isEmpty ? nil : Array(selectedStyles),
                color: selectedColors.isEmpty ? nil : Array(selectedColors),
                brand: brands.isEmpty ? nil : brands,
                season: selectedSeasons.isEmpty ? nil : Array(selectedSeasons),
                occasion: selectedOccasions.isEmpty ? nil : Array(selectedOccasions),
                clothingItemIds: selectedClothingItemId != nil ? [selectedClothingItemId!] : nil
            )
            
            await outfitViewModel.addOutfit(request)
            
            if outfitViewModel.errorMessage == nil {
                // Notify parent that outfit was created
                onOutfitCreated?()
                dismiss()
            }
        }
    }
    

}

#Preview {
    CreateOutfitView(outfitViewModel: OutfitViewModel(), selectedClothingItemId: nil, onOutfitCreated: nil)
}
