//
//  BookCard.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import SwiftUI

struct BookCard: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            bookCover
            
            // Название книги
            Text(book.title)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
            
            // Авторы (если есть)
            if !book.authors.isEmpty {
                Text(book.authors.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            // Год издания (если есть)
            if let year = book.year {
                Text(String(year))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 150)
        .padding(.bottom, 5)
    }
    
    private var bookCover: some View {
        Group {
            if let coverUrl = book.coverUrl, !coverUrl.isEmpty {
                AsyncImage(url: URL(string: coverUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 225)
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 150, height: 225)
        .cornerRadius(10)
        .clipped()
        .shadow(radius: 3)
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "book.closed.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .foregroundColor(.white)
        }
    }
}


