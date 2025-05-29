//
//  AuthManager.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    let apiClient: ApiClient
    
    init() {
        self.apiClient = ApiClient()
        // Проверяем, есть ли токен, при инициализации
        Task {
            await checkAuthStatus()
        }
    }
    
    func checkAuthStatus() async {
        do {
            // Если токен есть и валиден, пользователь авторизован
            _ = try await apiClient.fetchCurrentUser()
            await MainActor.run {
                self.isLoggedIn = true
            }
        } catch {
            print("Auth check failed: \(error)")
            await MainActor.run {
                self.isLoggedIn = false
            }
        }
    }
    
    func logout() async {
        apiClient.logout()
        await MainActor.run {
            self.isLoggedIn = false
        }
    }
}
