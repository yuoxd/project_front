//
//  ContentItem.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import Foundation

struct ContentItem: Codable, Identifiable, Hashable {
    let id: Int
    let kpId: Int
    let imdbId: String?
    let titleRu: String
    let titleEn: String?
    let titleOriginal: String?
    let posterUrl: String?
    let posterUrlPreview: String?
    let year: Int?
    let filmLength: Int?
    let slogan: String?
    let description: String?
    let shortDescription: String?
    let ratingKinopoisk: Double?
    let ratingImdb: Double?
    let ratingAgeLimits: String?
    let type: String?
    let isSeries: Bool
    let startYear: Int?
    let endYear: Int?
    
    // Для обратной совместимости
    var title: String { titleRu }
    var poster: String? { posterUrl }
    var content_type: String? { type }
    var is_series: Bool { isSeries }
    var rating_kinopoisk: Double? { ratingKinopoisk }
    var rating_imdb: Double? { ratingImdb }
    var filmLengthMinutes: Int? { filmLength }
    var rating_age_limits: String? { ratingAgeLimits }
    var short_description: String? { shortDescription }
    var ai_summary: String? { nil }
    var genres: [String]? { nil }
    var countries: [String]? { nil }
    var seasons_info: [SeasonInfo]? { nil }

    struct SeasonInfo: Codable, Hashable {
        let number: Int?
        let year: Int?
        let episodes: [Episode]?
        
        struct Episode: Codable, Hashable {
            let number: Int?
            let title: String?
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case kpId = "kp_id"
        case imdbId = "imdb_id"
        case titleRu = "title_ru"
        case titleEn = "title_en"
        case titleOriginal = "title_original"
        case posterUrl = "poster_url"
        case posterUrlPreview = "poster_url_preview"
        case year
        case filmLength = "film_length"
        case slogan
        case description
        case shortDescription = "short_description"
        case ratingKinopoisk = "rating_kinopoisk"
        case ratingImdb = "rating_imdb"
        case ratingAgeLimits = "rating_age_limits"
        case type
        case isSeries = "is_series"
        case startYear = "start_year"
        case endYear = "end_year"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Обязательные поля с обработкой ошибок
        kpId = try container.decode(Int.self, forKey: .kpId)
        id = kpId
        
        // Обработка title_ru, который может быть null
        if let title = try? container.decodeIfPresent(String.self, forKey: .titleRu) {
            titleRu = title
        } else {
            titleRu = "Без названия"
        }
        
        // Остальные поля с гибким декодированием
        isSeries = (try? container.decode(Bool.self, forKey: .isSeries)) ?? false
        imdbId = try? container.decodeIfPresent(String.self, forKey: .imdbId)
        titleEn = try? container.decodeIfPresent(String.self, forKey: .titleEn)
        titleOriginal = try? container.decodeIfPresent(String.self, forKey: .titleOriginal)
        posterUrl = try? container.decodeIfPresent(String.self, forKey: .posterUrl)
        posterUrlPreview = try? container.decodeIfPresent(String.self, forKey: .posterUrlPreview)
        
        // Числовые поля с разными форматами
        year = try? Self.decodeFlexibleNumber(from: container, forKey: .year)
        startYear = try? Self.decodeFlexibleNumber(from: container, forKey: .startYear)
        endYear = try? Self.decodeFlexibleNumber(from: container, forKey: .endYear)
        filmLength = try? Self.decodeFlexibleNumber(from: container, forKey: .filmLength)
        
        // Остальные поля
        slogan = try? container.decodeIfPresent(String.self, forKey: .slogan)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        shortDescription = try? container.decodeIfPresent(String.self, forKey: .shortDescription)
        ratingKinopoisk = try? container.decodeIfPresent(Double.self, forKey: .ratingKinopoisk)
        ratingImdb = try? container.decodeIfPresent(Double.self, forKey: .ratingImdb)
        ratingAgeLimits = try? container.decodeIfPresent(String.self, forKey: .ratingAgeLimits)
        type = try? container.decodeIfPresent(String.self, forKey: .type)
    }
    
    private static func decodeFlexibleNumber(from container: KeyedDecodingContainer<CodingKeys>,
                                          forKey key: CodingKeys) throws -> Int? {
        // Пробуем разные форматы чисел
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        } else if let stringValue = try? container.decode(String.self, forKey: key),
                  let intValue = Int(stringValue) {
            return intValue
        } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return Int(doubleValue)
        }
        return nil
    }
    
    var isMovie: Bool {
        return type?.lowercased() == "film" || (!isSeries && type == nil)
    }
}
