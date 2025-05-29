//
//  RegistrationView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject private var apiClient: ApiClient
    @Binding var isPresented: Bool
    @Binding var selectedTab: Tab
    let onRegistrationComplete: () -> Void
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    @State private var validationMessage: String?
    @State private var isNavigatingToGenreSelection = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Создать аккаунт")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    TextField("Ваше имя", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .padding(.horizontal)
                    
                    TextField("Почта", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .padding(.horizontal)
                    
                    SecureField("Пароль", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    SecureField("Повторите пароль", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    if let validationMessage = validationMessage {
                        Text(validationMessage)
                            .foregroundColor(.orange)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        print("Register button tapped")
                        Task {
                            await register()
                        }
                    }) {
                        Text("Зарегестрироваться!")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isLoading || !isFormValid)
                    .padding(.horizontal)
                    .animation(.easeInOut, value: isFormValid)
                    
                    if isLoading {
                        ProgressView()
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Регистрация прошла успешно!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    isNavigatingToGenreSelection = true
                }
            } message: {
                Text("Вы успешнно зарегестрировались!")
            }
            .navigationDestination(isPresented: $isNavigatingToGenreSelection) {
                GenreSelectionView(selectedTab: $selectedTab, onRegistrationComplete: onRegistrationComplete)
                    .environmentObject(apiClient)
            }
        }
        .onChange(of: username) { _ in updateValidationMessage() }
        .onChange(of: email) { _ in updateValidationMessage() }
        .onChange(of: password) { _ in updateValidationMessage() }
        .onChange(of: confirmPassword) { _ in updateValidationMessage() }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        isValidEmail(email) &&
        password.count >= 6
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isValid = emailPredicate.evaluate(with: email)
        return isValid
    }
    
    private func updateValidationMessage() {
        if username.isEmpty {
            validationMessage = "Username is required"
        } else if email.isEmpty {
            validationMessage = "Email is required"
        } else if !isValidEmail(email) {
            validationMessage = "Invalid email format"
        } else if password.isEmpty {
            validationMessage = "Password is required"
        } else if password.count < 6 {
            validationMessage = "Password must be at least 6 characters"
        } else if password != confirmPassword {
            validationMessage = "Passwords do not match"
        } else {
            validationMessage = nil
        }
    }
    
    private func register() async {
        print("Starting registration")
        isLoading = true
        errorMessage = nil
        
        do {
            print("Sending registration request: username=\(username), email=\(email)")
            let response = try await apiClient.register(
                username: username,
                email: email,
                password: password
            )
            print("Registration successful: \(response)")
            isLoading = false
            showSuccessAlert = true
        } catch {
            print("Registration failed: \(error)")
            isLoading = false
            errorMessage = handleError(error)
        }
    }
    
    private func handleError(_ error: Error) -> String {
        switch error {
        case APIError.invalidURL:
            return "Invalid server URL"
        case APIError.invalidResponse:
            return "Invalid server response"
        case APIError.unauthorized:
            return "Unauthorized"
        case APIError.serverError(let statusCode):
            return "Server error: \(statusCode)"
        case APIError.serverErrorWithMessage(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case APIError.decodingError(let error):
            return "Failed to process server response: \(error.localizedDescription)"
        case APIError.invalidQuery(let message):
            return message
        case APIError.invalidRequest(let message):
            return "Invalid request: \(message)"
        case APIError.userAlreadyExists:
            return "User already exists"
        case APIError.invalidCredentials:
            return "Invalid credentials"
        case APIError.networkError(let message):
            return "Network error: \(message)"
        case APIError.saveErrorWithMessage(let message):
            return message
        case APIError.unknownError:
            return "Unknown error"
        default:
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

