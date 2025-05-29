//
//  ContentView.swift
//  CineTome
//
//  Created by 596 on 22.04.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .movie
    @State private var showProfileMenu = false

    var body: some View {
        VStack(spacing: 0) {
            // Контент вкладок
            Group {
                switch selectedTab {
                case .movie:
                    MovieListView(selectedTab: $selectedTab)
                case .book:
                    BookListView(selectedTab: $selectedTab)
                case .profile:
                    ProfileMenuView(selectedTab: $selectedTab, onRegistrationComplete: {
                        print("ContentView: Registration completed, switching to profile")
                        selectedTab = .profile
                        showProfileMenu = false // Закрываем модальное окно
                    })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Кастомный таб-бар
            CustomBar(selectedTab: $selectedTab)
                .frame(height: 70)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showProfileMenu) {
            ProfileMenuView(selectedTab: $selectedTab, onRegistrationComplete: {
                print("ContentView (sheet): Registration completed, switching to profile")
                selectedTab = .profile
                showProfileMenu = false // Закрываем модальное окно
            })
        }
        
    }
}

#Preview {
    ContentView()
}
