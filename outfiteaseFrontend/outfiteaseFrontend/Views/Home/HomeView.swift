import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var clothingViewModel = ClothingViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ClothingListView(clothingViewModel: clothingViewModel, outfitViewModel: outfitViewModel)
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text("Clothes")
                }
            
            OutfitListView(outfitViewModel: outfitViewModel)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Outfits")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Planning")
                }
            
            ProfileView(clothingViewModel: clothingViewModel, outfitViewModel: outfitViewModel, authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text("More")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    HomeView(authViewModel: AuthViewModel())
        .preferredColorScheme(.light) // Show in light mode
}

#Preview {
    HomeView(authViewModel: AuthViewModel())
        .preferredColorScheme(.dark) // Show in dark mode
}
