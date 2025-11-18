import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationView {
            ZStack{ // when placing a background, ZStack - Z-axis Stack
                Image("outfitLogin")
                    .resizable()               // Makes the image scalable
                    .scaledToFill()            // Fill entire area, cropping if needed
                    .ignoresSafeArea()
                
                VStack {
                    // Main content
                    VStack(spacing: 30) {
                        
                        // Header
                        VStack(spacing: 10) {
                            
                            
                            Text("OutfitEase")
                                .font(.appDisplayMedium)
                            
                            Text("Your Personal Style Assistant")
                                .font(.appBody)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 50)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    TextField("Email", text: $email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .textFieldStyle(PlainTextFieldStyle())
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5))
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    
                                    Group {
                                        if isPasswordVisible {
                                            TextField("Password", text: $password)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                                .textFieldStyle(PlainTextFieldStyle())
                                        } else {
                                            SecureField("Password", text: $password)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                                .textFieldStyle(PlainTextFieldStyle())
                                        }
                                    }
                                    
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isPasswordVisible.toggle()
                                        }
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .foregroundColor(.gray)
                                            .frame(width: 20)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5))
                                )
                            }
                        }
                        .frame(maxWidth: 320)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        
                        // Login Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)){
                                print("🔘 Login button tapped")
                                print("📧 Email: \(email)")
                                print("🔑 Password: \(password)")
                                Task {
                                    await authViewModel.login(email: email, password: password)
                                }
                            }
                        }) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Sign In")
                                        .font(.appButton)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(authViewModel.isLoading)
                        .frame(maxWidth: 320)
                        .padding(.horizontal, 20)
                        
                        // Divider line
                        HStack(alignment: .center) {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                            
                            Text("or login with")
                                .font(.appCaption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        }
                        .frame(maxWidth: 320)
                        .padding(.horizontal, 20)
                        
                        // Google Sign In
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: {
                                    authViewModel.handleGoogleSignIn()
                                }) {
                                    Image("google_sign_in_logo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 180, maxHeight: 40)
                                }
                                .padding(12)
                            }
                        }
                        .frame(maxWidth: 320)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                    
                    // Push content to top and register link to bottom
                    Spacer()
                    
                    // Register Link at bottom
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        
                        Button("Sign Up") {
                            showRegister = true
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.bottom, 30)
                }
            }
            .alert("Error", isPresented: .constant(authViewModel.errorMessage != nil)) {
                Button("OK") {
                    authViewModel.errorMessage = nil
                }
            } message: {
                Text(authViewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }

}

#Preview {
    LoginView(authViewModel: AuthViewModel())
}
