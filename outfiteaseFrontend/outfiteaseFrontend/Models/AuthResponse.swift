import Foundation

struct AuthResponse: Codable {
    let token: String
    let user: User
    let message: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}
