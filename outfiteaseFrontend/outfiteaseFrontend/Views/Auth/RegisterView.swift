
import SwiftUI

struct RegisterView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        NavigationView {
            ZStack{
                Image("register")
                    .resizable()               // Makes the image scalable
                    .scaledToFill()            // Fill entire area, cropping if needed
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        
                        Text("Create Account")
                            .font(.appDisplaySmall)
                        
                        Text("Join OutfitEase today")
                            .font(.appBody)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 30)
                    
                    // Registration Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                //.font(.headline)
                                .foregroundColor(.primary)
                            
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                //.font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Choose a username", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                //.font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Group {
                                    if isPasswordVisible {
                                        TextField("Enter your password", text: $password)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isPasswordVisible.toggle()
                                    }
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                //.font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Group {
                                    if isConfirmPasswordVisible {
                                        TextField("Confirm your password", text: $confirmPassword)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    } else {
                                        SecureField("Confirm your password", text: $confirmPassword)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isConfirmPasswordVisible.toggle()
                                    }
                                }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    .frame(maxWidth: 400)
                    
                    // Register Button
                    Button(action: {
                        Task {
                            await authViewModel.register(email: email, username: username, password: password)
                        }
                    }) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(authViewModel.isLoading || !isFormValid)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: 400)
                    
                    // Back to Login
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        
                        Button("Sign In") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                    }
                }
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .alert("Error", isPresented: .constant(authViewModel.errorMessage != nil)) {
                    Button("OK") {
                        authViewModel.errorMessage = nil
                    }
                } message: {
                    Text(authViewModel.errorMessage ?? "")
                }
            }
        
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !username.isEmpty && !password.isEmpty && 
        password == confirmPassword && password.count >= 6
    }
}

#Preview {
    RegisterView()
}
