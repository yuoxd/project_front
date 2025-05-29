//
//  LoggedInView.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct LoggedInView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject var apiClient: ApiClient
    @State private var userProfile: User?
    @Binding var isLoggedIn: Bool
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .tint(.blue)
                            .scaleEffect(1.5)
                            .padding(.top, 50)
                    } else if let user = userProfile {
                        profileHeader(user: user)
                        userInfoSection(user: user)
                        preferencesSection(user: user)
                        actionButtons()
                    } else if let error = errorMessage {
                        errorView(error: error)
                    }
                }
                .padding()
            }
            .refreshable {
                await loadUserProfile()
            }
            .onAppear {
                Task {
                    await loadUserProfile()
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.1), .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) {
                    Task {
                        await performLogout()
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
    
    private func profileHeader(user: User) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
            }
            .shadow(radius: 5)
            
            Text(user.username)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 10)
            
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
    
    private func userInfoSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("О себе")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 5)
            
            InfoRow(icon: "person", text: "Имя: \(user.username)")
                .padding(.vertical, 5)
            InfoRow(icon: "envelope", text: "Почта: \(user.email)")
                .padding(.vertical, 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
    
    private func preferencesSection(user: User) -> some View {
        Group {
            if let prefs = user.preferences {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Предпочтения:")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 5)
                    
                    if let genres = prefs.favoriteGenres, !genres.isEmpty {
                        InfoRow(icon: "book.fill", text: "Genres: \(genres.joined(separator: ", "))")
                            .padding(.vertical, 5)
                    }
                    
                    if let authors = prefs.favoriteAuthors, !authors.isEmpty {
                        InfoRow(icon: "pencil.and.outline", text: "Authors: \(authors.joined(separator: ", "))")
                            .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(radius: 3)
                )
                .padding(.horizontal)
            }
        }
    }
    
    private func actionButtons() -> some View {
        VStack(spacing: 15) {
            Button(role: .destructive) {
                showLogoutAlert = true
            } label: {
                Label("Выйти", systemImage: "power")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private func errorView(error: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .padding()
            
            Text(error)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                apiClient.logout()
                isLoggedIn = false
                selectedTab = .profile
            }) {
                Text("Выйти")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .padding()
    }
    
    private func loadUserProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            userProfile = try await apiClient.fetchCurrentUser()
        } catch {
            errorMessage = handleProfileError(error)
        }
        
        isLoading = false
    }
    
    private func performLogout() async {
        do {
            apiClient.logout()
            isLoggedIn = false
            selectedTab = .profile
        } catch {
            errorMessage = "Logout failed. Please try again."
        }
    }
    
    private func handleProfileError(_ error: Error) -> String {
        switch error {
        case APIError.serverError(let code):
            return code == 401 ? "Session expired. Please login again." : "Server error: \(code)"
        case APIError.decodingError:
            return "Failed to parse profile data"
        default:
            return "Failed to load profile: \(error.localizedDescription)"
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(text)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview {
    LoggedInView(selectedTab: .constant(.profile), isLoggedIn: .constant(true))
        .environmentObject(ApiClient())
}
