import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = Constants.baseURL
    
    private init() {}
    
    // Test connectivity to the server
    func testConnectivity() async -> Bool {
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid base URL: \(baseURL)")
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Server connectivity test: \(httpResponse.statusCode)")
                return httpResponse.statusCode == 200
            }
        } catch {
            print("❌ Server connectivity test failed: \(error)")
        }
        return false
    }
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        print("🌐 API Request: \(method.rawValue) \(endpoint)")
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = UserDefaults.standard.string(forKey: Constants.UserDefaults.authToken) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                print("🔐 Adding auth token: \(token.prefix(20))...")
            } else {
                print("❌ No auth token found in UserDefaults")
            }
        } else {
            print("🔓 No auth required for this request")
        }
        
        if let body = body {
            request.httpBody = body
            print("📦 Request body size: \(body.count) bytes")
        }
        
        print("📤 Sending request to: \(url)")
        print("📋 Request method: \(request.httpMethod ?? "Unknown")")
        print("📦 Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "None")")
        print("📧 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            print("❌ HTTP Error: \(httpResponse.statusCode)")
            print("📄 Response headers: \(httpResponse.allHeaderFields)")
            if let responseText = String(data: data, encoding: .utf8) {
                print("📄 Response body: \(responseText)")
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            print("✅ Request successful")
            return decodedData
        } catch {
            print("❌ Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
