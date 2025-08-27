import SwiftUI

struct OutfitGenerationView: View {
    @StateObject private var generationViewModel = OutfitGenerationViewModel()
    @StateObject private var weatherViewModel = WeatherViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedEventType = ""
    @State private var selectedColors: Set<String> = []
    @State private var selectedStyle = ""
    @State private var useOwnedOnly = true
    @State private var budget: Double = 100.0
    @State private var showWeatherOptions = false
    
    private let eventTypes = ["Casual", "Formal", "Business", "Sport", "Evening", "Weekend"]
    private let colors = ["Black", "White", "Blue", "Red", "Green", "Yellow", "Purple", "Pink", "Brown", "Gray"]
    private let styles = ["Casual", "Formal", "Business", "Sport", "Streetwear", "Vintage", "Minimalist", "Elegant"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("AI Outfit Generator")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Get personalized outfit suggestions based on your preferences")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Filters Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Generation Filters")
                            .font(.headline)
                        
                        // Event Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Type")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Picker("Event Type", selection: $selectedEventType) {
                                Text("Select Event").tag("")
                                ForEach(eventTypes, id: \.self) { event in
                                    Text(event).tag(event)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // Colors
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preferred Colors")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(colors, id: \.self) { color in
                                    ColorSelectionButton(
                                        color: color,
                                        isSelected: selectedColors.contains(color),
                                        action: {
                                            if selectedColors.contains(color) {
                                                selectedColors.remove(color)
                                            } else {
                                                selectedColors.insert(color)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Style
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Style Preference")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Picker("Style", selection: $selectedStyle) {
                                Text("Any Style").tag("")
                                ForEach(styles, id: \.self) { style in
                                    Text(style).tag(style)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // Options
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Use Only Owned Clothing", isOn: $useOwnedOnly)
                            
                            if !useOwnedOnly {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Budget Limit: $\(Int(budget))")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Slider(value: $budget, in: 20...500, step: 10)
                                        .accentColor(.blue)
                                }
                            }
                            
                            Button("Include Weather Data") {
                                showWeatherOptions = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Generate Button
                    Button(action: {
                        generateOutfits()
                    }) {
                        HStack {
                            if generationViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "wand.and.stars")
                                Text("Generate Outfits")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(generationViewModel.isLoading)
                    .padding(.horizontal)
                    
                    // Results
                    if !generationViewModel.generatedOutfits.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Generated Outfits")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(generationViewModel.generatedOutfits) { outfit in
                                    GeneratedOutfitCard(outfit: outfit)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Outfit Generator")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showWeatherOptions) {
                WeatherOptionsView(weatherViewModel: weatherViewModel)
            }
            .alert("Error", isPresented: .constant(generationViewModel.errorMessage != nil)) {
                Button("OK") {
                    generationViewModel.errorMessage = nil
                }
            } message: {
                Text(generationViewModel.errorMessage ?? "")
            }
        }
    }
    
    private func generateOutfits() {
        let filters = OutfitGenerationFilters(
            eventType: selectedEventType.isEmpty ? nil : selectedEventType,
            colors: selectedColors.isEmpty ? nil : Array(selectedColors),
            style: selectedStyle.isEmpty ? nil : selectedStyle,
            useOwnedOnly: useOwnedOnly,
            budget: useOwnedOnly ? nil : budget,
            weather: weatherViewModel.currentWeather
        )
        
        Task {
            await generationViewModel.generateOutfits(filters: filters)
        }
    }
}

struct ColorSelectionButton: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(colorFromString(color))
                    .frame(width: 20, height: 20)
                
                Text(color)
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "black": return .black
        case "white": return .white
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "gray": return .gray
        default: return .gray
        }
    }
}

struct GeneratedOutfitCard: View {
    let outfit: GeneratedOutfit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(outfit.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("$\(outfit.totalPrice, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            }
            
            // Clothing items
            VStack(alignment: .leading, spacing: 8) {
                ForEach(outfit.items) { item in
                    HStack {
                        Text("• \(item.name)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        if let price = item.price {
                            Text("$\(price, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Tags
            if !outfit.style.isEmpty {
                HStack {
                    ForEach(outfit.style, id: \.self) { style in
                        Text(style)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
            
            // Actions
            HStack {
                Button("View Details") {
                    // TODO: Navigate to outfit details
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Save Outfit") {
                    // TODO: Save outfit
                }
                .font(.caption)
                .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct WeatherOptionsView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if weatherViewModel.isLoading {
                    ProgressView("Loading weather data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let weather = weatherViewModel.currentWeather {
                    VStack(spacing: 16) {
                        Image(systemName: weatherIcon(for: weather.conditions))
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("\(Int(weather.temperature))°C")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(weather.description.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Humidity: \(weather.humidity)%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Use Weather Data") {
                            weatherViewModel.currentWeather = weather
                            dismiss()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "location.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Location Access Required")
                            .font(.headline)
                        
                        Text("Allow location access to get weather-based recommendations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Enable Location") {
                            Task {
                                await weatherViewModel.requestLocationAndWeather()
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle("Weather Options")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func weatherIcon(for conditions: String) -> String {
        switch conditions.lowercased() {
        case let c where c.contains("rain"): return "cloud.rain"
        case let c where c.contains("snow"): return "cloud.snow"
        case let c where c.contains("cloud"): return "cloud"
        case let c where c.contains("sun"): return "sun.max"
        default: return "cloud"
        }
    }
}

#Preview {
    OutfitGenerationView()
} 