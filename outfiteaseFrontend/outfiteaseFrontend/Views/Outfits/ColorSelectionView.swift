import SwiftUI

struct ColorSelectionView: View {
    @Binding var selectedColors: Set<String>
    @State private var showColorPalette = false
    @State private var newColor: Color = .blue
    @State private var customColors: [(name: String, color: Color)] = []
    
    private let defaultColors = ["Black", "White", "Blue", "Red", "Green", "Yellow", "Purple", "Pink", "Brown", "Gray"]
    
    private var allColors: [String] {
        defaultColors + customColors.map { $0.name }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Colors")
                    .font(.headline)
                Spacer()
                Button("Add Custom Color") {
                    showColorPalette = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(allColors, id: \.self) { color in
                    ColorOptionView(
                        color: color,
                        customColors: customColors,
                        isSelected: selectedColors.contains(color),
                        onTap: {
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
        .sheet(isPresented: $showColorPalette) {
            ColorPickerSheet(
                newColor: $newColor, 
                showColorPalette: $showColorPalette,
                onAddColor: { colorName in
                    if !customColors.contains(where: { $0.name == colorName }) {
                        customColors.append((name: colorName, color: newColor))
                    }
                }
            )
        }
    }
}

struct ColorOptionView: View {
    let color: String
    let customColors: [(name: String, color: Color)]
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(colorFromString(color, customColors: customColors))
                    .frame(width: 20, height: 20)
                Text(color)
                    .font(.body)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func colorFromString(_ colorName: String, customColors: [(name: String, color: Color)]) -> Color {
        // First check if it's a custom color
        if let customColor = customColors.first(where: { $0.name == colorName }) {
            return customColor.color
        }
        
        // Then check default colors
        switch colorName.lowercased() {
        case "black": return .black
        case "white": return .white
        case "blue": return .blue
        case "red": return .red
        case "green": return Color(red: 0.0, green: 0.6, blue: 0.2) // Deep green
        case "yellow": return .yellow
        case "purple": return .purple
        case "pink": return Color(red: 1.0, green: 0.75, blue: 0.8) // Light pink
        case "brown": return .brown
        case "gray": return .gray
        default: return .blue
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var newColor: Color
    @Binding var showColorPalette: Bool
    let onAddColor: (String) -> Void
    
    @State private var colorName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Custom Color")
                .font(.headline)
            
            ColorPicker("Choose Color", selection: $newColor, supportsOpacity: false)
                .labelsHidden()
            
            TextField("Color Name", text: $colorName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    showColorPalette = false
                }
                .foregroundColor(.secondary)
                
                Button("Add") {
                    if !colorName.isEmpty {
                        onAddColor(colorName)
                        showColorPalette = false
                    }
                }
                .foregroundColor(.blue)
                .disabled(colorName.isEmpty)
            }
        }
        .padding()
        .presentationDetents([.height(300)])
    }
}

#Preview {
    ColorSelectionView(selectedColors: .constant(["Blue", "Red"]))
        .padding()
} 