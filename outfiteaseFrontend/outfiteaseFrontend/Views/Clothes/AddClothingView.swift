import SwiftUI

struct AddClothingView: View {
    @ObservedObject var clothingViewModel: ClothingViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var type = ""
    //@State private var color = ""
    @State private var style = ""
    @State private var brand = ""
    @State private var price = ""
    @State private var selectedSeasons: Set<String> = []
    @State private var selectedOccasions: Set<String> = []
    @State private var selectedImage: UIImage?
    @State private var selectedColors: Set<String> = []
    
    private let clothingTypes = ["Shirt", "Pants", "Dress", "Shoes", "Accessory", "Outerwear", "Other"]
    private let seasons = ["Spring", "Summer", "Fall", "Winter", "All Season"]
    private let occasions = ["Casual", "Formal", "Business", "Sport", "Evening", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
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
                
                Section("Photo") {
                    ImageUploadView(selectedImage: $selectedImage)
                }
                Section("Colors") {
                    ColorSelectionView(selectedColors: $selectedColors)
                }
            }
            .navigationTitle("Add Clothing")
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
                        saveClothingItem()
                    }
                    .disabled(!isFormValid || clothingViewModel.isLoading)
                }
            }
            .alert("Error", isPresented: .constant(clothingViewModel.errorMessage != nil)) {
                Button("OK") {
                    clothingViewModel.errorMessage = nil
                }
            } message: {
                Text(clothingViewModel.errorMessage ?? "")
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty
    }
    
    private func saveClothingItem() {
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
            
            let priceValue = Double(price) ?? 0.0
            
            let request = CreateClothingItemRequest(
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
            
            await clothingViewModel.addClothingItem(request)
            if clothingViewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}

#Preview {
    AddClothingView(clothingViewModel: ClothingViewModel())
}
