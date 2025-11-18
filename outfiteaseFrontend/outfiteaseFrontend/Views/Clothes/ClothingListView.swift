import SwiftUI

struct ClothingListView: View {
    @ObservedObject var clothingViewModel: ClothingViewModel
    @ObservedObject var outfitViewModel: OutfitViewModel
    @State private var showAddClothing = false
    @State private var showBulkSelection = false
    @State private var searchText = ""
    
    var filteredItems: [ClothingItem] {
        if searchText.isEmpty {
            return clothingViewModel.clothingItems
        } else {
            return clothingViewModel.clothingItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.brand?.localizedCaseInsensitiveContains(searchText) == true ||
                item.type?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if clothingViewModel.isLoading {
                    ProgressView("Loading clothes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tshirt")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Clothes Yet")
                            .font(.appHeadline2)
                        
                        Text("Add your first clothing item to get started!")
                            .font(.appBody)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Add Clothing") {
                            showAddClothing = true
                        }
                        .font(.appButton)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: ClothingDetailView(clothingItem: item, clothingViewModel: clothingViewModel, outfitViewModel: outfitViewModel)) {
                                    ClothingGridItem(clothingItem: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("My Clothes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search clothes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !filteredItems.isEmpty {
                            Button(action: {
                                showBulkSelection = true
                            }) {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                        
                        Button(action: {
                            showAddClothing = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .refreshable {
                await clothingViewModel.loadClothingItems()
            }
            .sheet(isPresented: $showAddClothing) {
                AddClothingView(clothingViewModel: clothingViewModel)
            }
            .sheet(isPresented: $showBulkSelection) {
                BulkSelectionView(clothingViewModel: clothingViewModel)
            }
        }
        .task {
            await clothingViewModel.loadClothingItems()
        }


    }
    

}

struct ClothingGridItem: View {
    let clothingItem: ClothingItem
    
    var body: some View {
        VStack(spacing: 8) {
            // Clothing Image
            if let imageURL = clothingItem.imageUrl, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 150)
                        .clipped()
                        .cornerRadius(12)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 150)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
            } else {
                // Placeholder image when no image URL is available
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 150)
                    .overlay(
                        Image(systemName: "tshirt")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    )
            }
            
            // Item Name
            Text(clothingItem.name)
                .font(.appCaption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            // Brand (if available)
            if let brand = clothingItem.brand {
                Text(brand)
                    .font(.appCaption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 120)
        .padding(.vertical, 4)
    }
}

// Keep the old row view for other uses if needed
struct ClothingItemRow: View {
    let clothingItem: ClothingItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder for clothing image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "tshirt")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(clothingItem.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    if let brand = clothingItem.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let type = clothingItem.type {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(type)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let price = clothingItem.price {
                    Text("$\(price, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ClothingListView(clothingViewModel: ClothingViewModel(), outfitViewModel: OutfitViewModel())
}





