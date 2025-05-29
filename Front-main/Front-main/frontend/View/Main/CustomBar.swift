//
//  CustomBar.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct CustomBar: View {
    @Binding var selectedTab: Tab
    var body: some View {
        HStack {
            Spacer()
            TabBarButton(image: "movieclapper", tab: .movie, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(image: "book", tab: .book, selectedTab: $selectedTab)
            Spacer()
            TabBarButton(image: "person.crop.circle", tab: .profile, selectedTab: $selectedTab)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
    }
}
struct TabBarButton: View {
    let image: String
    let tab: Tab
    @Binding var selectedTab: Tab
    var body: some View {
        Button(action:{
            selectedTab = tab
        }){
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(selectedTab == tab ? .blue : .gray)
        }
    }
}

