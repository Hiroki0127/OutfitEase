import SwiftUI

struct MyOutfitsListView: View {
    @ObservedObject var outfitViewModel: OutfitViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showBulkSelection = false
    @State private var selectedOutfit: Outfit?
    @State private var showOutfitDetail = false
    @State private var showCreateOutfit = false
    
    var filteredOutfits: [Outfit] {
        if searchText.isEmpty {
            return outfitViewModel.outfits
        } else {
            return outfitViewModel.outfits.filter { outfit in
                outfit.name?.localizedCaseInsensitiveContains(searchText) == true ||
                outfit.description?.localizedCaseInsensitiveContains(searchText) == true ||
                outfit.style?.contains { $0.localizedCaseInsensitiveContains(searchText) } == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Header indicator
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.blue)
                    Text("Your Created Outfits")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    Text("\(outfitViewModel.outfits.count) total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if outfitViewModel.isLoading {
                    ProgressView("Loading outfits...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredOutfits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Outfits Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Tap the + button to create your first outfit!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredOutfits) { outfit in
                                OutfitCardView(outfit: outfit)
                                    .onTapGesture {
                                        selectedOutfit = outfit
                                        showOutfitDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("My Outfits")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(false)
            .searchable(text: $searchText, prompt: "Search outfits...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Create new outfit button
                        Button(action: {
                            showCreateOutfit = true
                        }) {
                            Image(systemName: "plus")
                        }
                        
                        if !filteredOutfits.isEmpty {
                            Button(action: {
                                showBulkSelection = true
                            }) {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                    }
                }
            }
            .refreshable {
                await outfitViewModel.loadOutfits()
            }
            .onAppear {
                // Debug info
                print("🔍 MyOutfitsListView appeared")
                print("📊 Current outfits count: \(outfitViewModel.outfits.count)")
                print("📋 Outfit IDs: \(outfitViewModel.outfits.map { $0.id.uuidString })")
            }
            .sheet(isPresented: $showBulkSelection) {
                BulkSelectionOutfitView(outfitViewModel: outfitViewModel)
            }
            .sheet(isPresented: $showOutfitDetail) {
                if let outfit = selectedOutfit {
                    OutfitDetailView(outfit: outfit, outfitViewModel: outfitViewModel)
                }
            }
            .sheet(isPresented: $showCreateOutfit) {
                CreateOutfitView(
                    outfitViewModel: outfitViewModel,
                    selectedClothingItemId: nil,
                    onOutfitCreated: {
                        // Refresh the outfits list after creating a new outfit
                        Task {
                            await outfitViewModel.loadOutfits()
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    MyOutfitsListView(outfitViewModel: OutfitViewModel())
}

