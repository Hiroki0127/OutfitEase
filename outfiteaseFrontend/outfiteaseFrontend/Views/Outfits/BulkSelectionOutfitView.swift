import SwiftUI

struct BulkSelectionOutfitView: View {
    @ObservedObject var outfitViewModel: OutfitViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOutfits: Set<String> = []
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Select Outfits")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        trailingToolbarContent
                    }
                }
                .alert("Delete Selected Outfits", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        Task {
                            await deleteSelectedOutfits()
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete \(selectedOutfits.count) selected outfit\(selectedOutfits.count == 1 ? "" : "s")? This action cannot be undone.")
                }
         ht 
        t
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if outfitViewModel.outfits.isEmpty {
            emptyStateView
        } else {
            outfitListView
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No outfits to select")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var outfitListView: some View {
        List {
            ForEach(outfitViewModel.outfits) { outfit in
                OutfitSelectionRow(
                    outfit: outfit,
                    isSelected: selectedOutfits.contains(outfit.id.uuidString),
                    onToggle: { toggleSelection(for: outfit) }
                )
            }
        }
    }
    
    @ViewBuilder
    private var trailingToolbarContent: some View {
        if !selectedOutfits.isEmpty {
            HStack {
                Text("\(selectedOutfits.count) selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Delete") {
                    showDeleteAlert = true
                }
                .foregroundColor(.red)
                .disabled(selectedOutfits.isEmpty)
            }
        }
    }
    
    private func toggleSelection(for outfit: Outfit) {
        let outfitId = outfit.id.uuidString
        if selectedOutfits.contains(outfitId) {
            selectedOutfits.remove(outfitId)
        } else {
            selectedOutfits.insert(outfitId)
        }
    }
    
    private func deleteSelectedOutfits() async {
        await outfitViewModel.bulkDeleteOutfits(outfitIds: Array(selectedOutfits))
        dismiss()
    }
}

struct OutfitSelectionRow: View {
    let outfit: Outfit
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            // Selection checkbox
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Outfit image
            outfitImageView
            
            // Outfit details
            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.name ?? "Unnamed Outfit")
                    .font(.headline)
                    .lineLimit(1)
                
                if let description = outfit.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let totalPrice = outfit.totalPrice {
                    Text("$\(totalPrice, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var outfitImageView: some View {
        if let imageURL = outfit.imageURL, !imageURL.isEmpty {
            AsyncImage(url: URL(string: imageURL)) { image in
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
                    Image(systemName: "person.crop.rectangle")
                        .foregroundColor(.gray)
                )
        }
    }
}

#Preview {
    BulkSelectionOutfitView(outfitViewModel: OutfitViewModel())
}
