import Foundation
import UIKit

class UploadService {
    static let shared = UploadService()
    private let apiService = APIService.shared
    
    private init() {}
    
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw UploadError.invalidImageData
        }
        
        let base64String = imageData.base64EncodedString()
        
        let uploadRequest = ImageUploadRequest(image: base64String)
        let body = try JSONEncoder().encode(uploadRequest)
        
        let response: ImageUploadResponse = try await apiService.request(
            endpoint: Constants.API.upload,
            method: .POST,
            body: body
        )
        
        return response.imageURL
    }
}

struct ImageUploadRequest: Codable {
    let image: String
}

struct ImageUploadResponse: Codable {
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
    }
}

enum UploadError: Error, LocalizedError {
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Invalid image data"
        }
    }
} 