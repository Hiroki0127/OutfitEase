import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = Constants.baseURL
    
    // Custom URLSession with longer timeout for Render free tier wake-up
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 120 // 120 seconds for Render wake-up (50-60 sec wake + buffer)
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true // Wait for network connectivity
        return URLSession(configuration: configuration)
    }()
    
    private init() {}
    
    // Test connectivity to the server
    func testConnectivity() async -> Bool {
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid base URL: \(baseURL)")
            return false
        }
        
        do {
            let (_, response) = try await urlSession.data(from: url)
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
        requiresAuth: Bool = true,
        retryCount: Int = 2
    ) async throws -> T {
        print("🌐 API Request: \(method.rawValue) \(endpoint)")
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Set timeout directly on request as well
        request.timeoutInterval = 120
        
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
        print("⏱️ Request timeout: \(request.timeoutInterval) seconds")
        
        // Retry logic for Render wake-up delays
        var data: Data?
        var response: URLResponse?
        var lastError: Error?
        
        for attempt in 0...retryCount {
            if attempt > 0 {
                print("🔄 Retry attempt \(attempt)/\(retryCount)")
                try? await Task.sleep(nanoseconds: UInt64(attempt * 2_000_000_000)) // 2s, 4s delays
            }
            
            do {
                let result = try await urlSession.data(for: request)
                data = result.0
                response = result.1
                lastError = nil
                print("✅ Request succeeded on attempt \(attempt + 1)")
                break
            } catch {
                lastError = error
                print("⚠️ Attempt \(attempt + 1) failed: \(error.localizedDescription)")
                if attempt < retryCount {
                    continue
                }
            }
        }
        
        guard let finalData = data, let finalResponse = response else {
            throw lastError ?? APIError.invalidResponse
        }
        
        guard let httpResponse = finalResponse as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            print("❌ HTTP Error: \(httpResponse.statusCode)")
            print("📄 Response headers: \(httpResponse.allHeaderFields)")
            
            // Try to parse error message from response body
            var errorMessage: String?
            if let responseText = String(data: finalData, encoding: .utf8) {
                print("📄 Response body: \(responseText)")
                
                // Try to decode error response
                do {
                    let errorData = try JSONDecoder().decode(ErrorResponse.self, from: finalData)
                    errorMessage = errorData.message ?? errorData.error
                    print("✅ Parsed error message: \(errorMessage ?? "nil")")
                } catch {
                    print("⚠️ Failed to parse error response: \(error)")
                    // Fallback: parse as dictionary
                    if let json = try? JSONSerialization.jsonObject(with: finalData) as? [String: Any] {
                        errorMessage = json["message"] as? String ?? json["error"] as? String
                        print("✅ Extracted error message from dictionary: \(errorMessage ?? "nil")")
                    }
                }
            }
            
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: finalData)
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
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode, let message):
            // Return backend message if available, otherwise generic error
            if let msg = message {
                return msg
            }
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

struct ErrorResponse: Codable {
    let message: String?
    let error: String?
}
