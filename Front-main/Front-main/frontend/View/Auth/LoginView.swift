//
//  LoginView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var apiClient: ApiClient
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    @Binding var selectedTab: Tab
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Вход")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    TextField("Почта", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(.horizontal)
                    
                    SecureField("Пароль", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        Task {
                            await login()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Авторизоваться")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isLoading || !isFormValid)
                    .opacity((isLoading || !isFormValid) ? 0.6 : 1)
                    .padding(.horizontal)
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Нету аккаунта? Зарегестрируйтесь!")
                            .foregroundColor(.blue)
                    }
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Вход успешен!", isPresented: $showSuccessAlert) {
                Button("OK") {
                    isPresented = false
                    selectedTab = .profile
                }
            } message: {
                Text("Вы успешно авторизовались")
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func login() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.login(email: email, password: password)
            print("Login response: \(response)")
            isLoading = false
            isLoggedIn = true
            showSuccessAlert = true
        } catch {
            isLoading = false
            errorMessage = handleError(error)
        }
    }
    
    private func handleError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .serverError(let code):
                if code == 400 {
                    return "Invalid email or password"
                }
                return "Server error: \(code)"
            case .invalidURL:
                return "Invalid server URL"
            case .invalidResponse:
                return "Invalid server response"
            case .decodingError:
                return "Failed to process server response"
            case .invalidQuery(let message):
                return message
            case .unknownError:
                return "unknownError"
            case .saveErrorWithMessage(_):
                return "saveErrorWithMessage"
            case .networkError(_):
                return "Ошибка сети"
            case .invalidRequest:
                return "Ошибка запроса"
            case .invalidCredentials:
                return "Ошибка запроса"
            case .unauthorized:
                return "Вы не авторизованы"
            case .userAlreadyExists:
                return "аккаунт уже существует"
            case .serverErrorWithMessage(_, _):
                return "asasd"
            }
        }
        return "An unexpected error occurred"
    }
}

#Preview {
    LoginView(
        isPresented: .constant(true),
        selectedTab: .constant(.profile),
        isLoggedIn: .constant(false)
    )
    .environmentObject(ApiClient())
}
