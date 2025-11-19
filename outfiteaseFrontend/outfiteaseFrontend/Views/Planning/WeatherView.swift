import SwiftUI
import CoreLocation

struct WeatherView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @State private var cityInput: String = ""
    @State private var showingCityInput = false
    @State private var showLocationAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Weather Section
                    if let weather = weatherViewModel.currentWeather {
                        CurrentWeatherCard(weather: weather)
                    } else if weatherViewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let error = weatherViewModel.errorMessage {
                        ErrorView(message: error)
                            .onTapGesture {
                                // Clear error and try again
                                weatherViewModel.errorMessage = nil
                            }
                    } else {
                        EmptyWeatherView()
                    }
                    
                    // Forecast Section
                    if !weatherViewModel.weatherForecast.isEmpty {
                        ForecastSection(forecast: weatherViewModel.weatherForecast)
                    }
                    
                    // Weather Recommendations
                    if let weather = weatherViewModel.currentWeather {
                        WeatherRecommendationsView(weather: weather, viewModel: weatherViewModel)
                    }
                }
                .padding()
            }
            .navigationTitleFont("Weather")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showingCityInput = true
                        }) {
                            Image(systemName: "magnifyingglass")
                        }
                        
                        Button(action: {
                            Task {
                                await weatherViewModel.requestLocationAndWeather()
                            }
                        }) {
                            Image(systemName: "location.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCityInput) {
                CityInputView(cityInput: $cityInput, weatherViewModel: weatherViewModel)
            }
            .task {
                if weatherViewModel.currentWeather == nil && !weatherViewModel.isLoading {
                    // Try to get weather, but don't fail if permission is denied
                    await weatherViewModel.requestLocationAndWeather()
                    if weatherViewModel.errorMessage?.contains("Location permission denied") == true {
                        showLocationAlert = true
                    }
                }
            }
            .onChange(of: weatherViewModel.errorMessage) { newValue in
                if newValue?.contains("Location permission denied") == true {
                    showLocationAlert = true
                }
            }
            .alert("Location Permission Required", isPresented: $showLocationAlert) {
                Button("Search by City") {
                    showingCityInput = true
                    showLocationAlert = false
                }
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    showLocationAlert = false
                }
                Button("Cancel", role: .cancel) {
                    showLocationAlert = false
                }
            } message: {
                Text("To get weather for your current location, please enable location access in Settings. You can also search for weather by city name.")
            }
        }
    }
}

struct CurrentWeatherCard: View {
    let weather: WeatherInfo
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(weather.city)
                        .font(.appHeadline2)
                    
                    Text(weather.country)
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(weather.temperature))°")
                        .font(.appDisplayMedium)
                    
                    Text(weather.description.capitalized)
                        .font(.appBody)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 32) {
                WeatherDetail(
                    icon: "thermometer",
                    label: "Feels like",
                    value: "\(Int(weather.feelsLike))°"
                )
                
                WeatherDetail(
                    icon: "humidity",
                    label: "Humidity",
                    value: "\(weather.humidity)%"
                )
                
                WeatherDetail(
                    icon: "wind",
                    label: "Wind",
                    value: "\(Int(weather.windSpeed)) m/s"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct WeatherDetail: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.appBody)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.appLabel)
            
            Text(label)
                .font(.appCaption)
                .foregroundColor(.secondary)
        }
    }
}

struct ForecastSection: View {
    let forecast: [WeatherForecast]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5-Day Forecast")
                .font(.appHeadline3)
            
            ForEach(forecast.prefix(5), id: \.date) { day in
                ForecastRow(forecast: day)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ForecastRow: View {
    let forecast: WeatherForecast
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: forecast.date) {
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
        return forecast.date
    }
    
    var body: some View {
        HStack {
            Text(dateString)
                .font(.appBody)
            
            Spacer()
            
            Text(forecast.conditions.capitalized)
                .font(.appCaption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(forecast.temperature)°")
                .font(.appLabel)
        }
        .padding(.vertical, 8)
    }
}

extension WeatherForecast: Equatable {
    static func == (lhs: WeatherForecast, rhs: WeatherForecast) -> Bool {
        lhs.date == rhs.date
    }
}

struct WeatherRecommendationsView: View {
    let weather: WeatherInfo
    @ObservedObject var viewModel: WeatherViewModel
    @State private var recommendations: WeatherRecommendations?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Outfit Recommendations")
                .font(.appHeadline3)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if let recs = recommendations {
                RecommendationGrid(recommendations: recs)
            } else {
                Button(action: {
                    Task {
                        isLoading = true
                        recommendations = await viewModel.getWeatherRecommendations()
                        isLoading = false
                    }
                }) {
                    Text("Get Recommendations")
                        .font(.appButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct RecommendationGrid: View {
    let recommendations: WeatherRecommendations
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !recommendations.seasons.isEmpty {
                RecommendationSection(title: "Seasons", items: recommendations.seasons)
            }
            
            if !recommendations.styles.isEmpty {
                RecommendationSection(title: "Styles", items: recommendations.styles)
            }
            
            if !recommendations.clothingTypes.isEmpty {
                RecommendationSection(title: "Clothing Types", items: recommendations.clothingTypes)
            }
            
            if !recommendations.colors.isEmpty {
                RecommendationSection(title: "Colors", items: recommendations.colors)
            }
            
            if !recommendations.accessories.isEmpty {
                RecommendationSection(title: "Accessories", items: recommendations.accessories)
            }
        }
    }
}

struct RecommendationSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appLabel)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100), spacing: 8)
            ], spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.appCaption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct CityInputView: View {
    @Binding var cityInput: String
    @ObservedObject var weatherViewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("City Name", text: $cityInput)
                        .font(.appBody)
                } header: {
                    Text("Enter City Name")
                        .font(.appCaption)
                }
            }
            .navigationTitleFont("Search City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Search") {
                        Task {
                            await weatherViewModel.getWeatherForCity(cityInput)
                            dismiss()
                        }
                    }
                    .disabled(cityInput.isEmpty)
                }
            }
        }
    }
}

struct EmptyWeatherView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Weather Data")
                .font(.appHeadline2)
            
            Text("Tap the location button to get weather for your current location")
                .font(.appBody)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.appHeadline2)
            
            Text(message)
                .font(.appBody)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    WeatherView()
}

