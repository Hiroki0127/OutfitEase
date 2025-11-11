import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var clothingViewModel = ClothingViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()
    
    var body: some View {
        TabView {
            PostFeedView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
            
            ClothingListView(clothingViewModel: clothingViewModel, outfitViewModel: outfitViewModel)
                .tabItem {
                    Image(systemName: "tshirt.fill")
                    Text("Clothes")
                }
            
            OutfitListView(outfitViewModel: outfitViewModel)
                .tabItem {
                    Image(systemName: "hanger")
                    Text("Outfits")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Planning")
                }
            
            ProfileView(clothingViewModel: clothingViewModel, outfitViewModel: outfitViewModel, authViewModel: authViewModel)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
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
