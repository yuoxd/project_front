//
//  ContentCardView.swift
//  frontend
//
//  Created by 596 on 17.05.2025.
//

import SwiftUI

struct ContentCard: View {
    let content: ContentItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster
            AsyncImage(url: URL(string: content.poster ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                case .failure, .empty:
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: content.is_series ? "tv" : "film")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundColor(.white)
                    }
                    .frame(height: 200)
                @unknown default:
                    Color.gray.opacity(0.3)
                        .frame(height: 200)
                }
            }
            .cornerRadius(8)
            .shadow(radius: 4)
            
            // Title
            Text(content.title)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            
            // Info (Year and Type)
            HStack(spacing: 8) {
                if let year = content.year {
                    Text(String(year))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(content.is_series ? "Сериал" : "Фильм")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
            
            // Rating
            if let rating = content.rating_kinopoisk ?? content.rating_imdb {
                RatingBadge(
                    value: String(format: "%.1f", rating),
                    systemName: "star.fill",
                    color: .orange
                )
            }
        }
        .padding(.bottom, 8)
    }
}


