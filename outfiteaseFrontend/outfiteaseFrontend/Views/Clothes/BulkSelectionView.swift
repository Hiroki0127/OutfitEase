import SwiftUI

struct BulkSelectionView: View {
    @ObservedObject var clothingViewModel: ClothingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: Set<String> = []
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if clothingViewModel.clothingItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tshirt")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No clothing items to select")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(clothingViewModel.clothingItems) { item in
                            HStack {
                                // Selection checkbox
                                Button(action: {
                                    if selectedItems.contains(item.id) {
                                        selectedItems.remove(item.id)
                                    } else {
                                        selectedItems.insert(item.id)
                                    }
                                }) {
                                    Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedItems.contains(item.id) ? .blue : .gray)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Item image
                                if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.3))
                                    }
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "tshirt")
                                                .foregroundColor(.gray)
                                        )
                                }
                                
                                // Item details
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    if let type = item.type {
                                        Text(type)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let brand = item.brand {
                                        Text(brand)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Select Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !selectedItems.isEmpty {
                            Text("\(selectedItems.count) selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("Delete") {
                                showDeleteAlert = true
                            }
                            .foregroundColor(.red)
                            .disabled(selectedItems.isEmpty)
                        }
                    }
                }
            }
            .alert("Delete Selected Items", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteSelectedItems()
                    }
                }
            } message: {
                Text("Are you sure you want to delete \(selectedItems.count) selected item\(selectedItems.count == 1 ? "" : "s")? This action cannot be undone.")
            }
        }
    }
    
    private func deleteSelectedItems() async {
        await clothingViewModel.bulkDeleteClothingItems(itemIds: Array(selectedItems))
        dismiss()
    }
}

#Preview {
    BulkSelectionView(clothingViewModel: ClothingViewModel())
}
