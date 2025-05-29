//
//  ProfileMenuView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct ProfileMenuView: View {
    @Binding var selectedTab: Tab
    @StateObject private var authManager = AuthManager()
    @State private var showLoginView: Bool = false
    @State private var showRegistrationView: Bool = false
    let onRegistrationComplete: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if authManager.isLoggedIn {
                    LoggedInView(selectedTab: $selectedTab, isLoggedIn: $authManager.isLoggedIn)
                        .environmentObject(authManager.apiClient)
                } else {
                    VStack {
                        Button("Login") {
                            showLoginView = true
                        }
                        .padding()
                        
                        Button("Register") {
                            showRegistrationView = true
                        }
                        .padding()
                    }
                    .sheet(isPresented: $showLoginView) {
                        LoginView(
                            isPresented: $showLoginView,
                            selectedTab: $selectedTab,
                            isLoggedIn: $authManager.isLoggedIn
                        )
                        .environmentObject(authManager.apiClient)
                    }
                    .sheet(isPresented: $showRegistrationView) {
                        RegistrationView(
                            isPresented: $showRegistrationView,
                            selectedTab: $selectedTab,
                            onRegistrationComplete: onRegistrationComplete
                        )
                        .environmentObject(authManager.apiClient)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await authManager.checkAuthStatus()
            }
        }
    }
}

struct ProfileMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileMenuView(selectedTab: .constant(.profile), onRegistrationComplete: {})
    }
}
