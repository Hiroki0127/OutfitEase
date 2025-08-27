import SwiftUI
import PhotosUI

struct ImageUploadView: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 16) {
            if let image = selectedImage {
                // Display selected image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        Button(action: {
                            selectedImage = nil
                            selectedItem = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(8),
                        alignment: .topTrailing
                    )
            } else {
                // Upload placeholder
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Add Photo")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Tap to select from your photo library")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
                }
            }
            
            if isLoading {
                ProgressView("Uploading...")
                    .font(.caption)
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                isLoading = true
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
                isLoading = false
            }
        }
    }
}

#Preview {
    ImageUploadView(selectedImage: .constant(nil))
        .padding()
} 
