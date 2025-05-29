//
//  ContentCollectionView.swift
//  frontend
//
//  Created by 596 on 17.05.2025.
//

import SwiftUI

struct ContentCollectionView: View {
    let title: String
    let items: [ContentItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок коллекции
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal)
            
            // Горизонтальный список элементов
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(items) { item in
                        NavigationLink(
                            destination: destinationView(for: item)
                        ) {
                            ContentCardView(item: item)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    // Определяет представление для перехода в зависимости от типа контента
    @ViewBuilder
    private func destinationView(for item: ContentItem) -> some View {
        if item.is_series {
            SeriesDetailView(seriesId: String(item.id))
        } else {
            MovieDetailView(movieId: String(item.id))
        }
    }
}

// Карточка для отдельного элемента контента
struct ContentCardView: View {
    let item: ContentItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Постер
            AsyncImage(url: URL(string: item.poster ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 225)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure:
                    placeholderImage
                case .empty:
                    ProgressView()
                        .frame(width: 150, height: 225)
                @unknown default:
                    placeholderImage
                }
            }
            .shadow(radius: 4)
            
            // Название
            Text(item.title)
                .font(.subheadline.bold())
                .lineLimit(1)
                .foregroundColor(.primary)
            
            // Год и тип
            HStack(spacing: 8) {
                if let year = item.year {
                    Text(String(year))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(item.is_series ? "Сериал" : "Фильм")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 150)
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: item.is_series ? "tv" : "film")
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .foregroundColor(.white)
        }
        .frame(width: 150, height: 225)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Превью
