//
//  CollectionType.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import Foundation


enum CollectionType: String, CaseIterable, Comparable {
    case pop = "popular"
    case new = "new"
    case best = "best"
    case family = "family"
    case vampire = "vampire"
    case love = "love"
    case zombie = "zombie"
    case comics = "comics"
    case oskar = "oskar"
    case releases = "releases"
    
    var displayName: String {
        switch self {
        case .pop: return "Популярные"
        case .new: return "Новинки"
        case .best: return "Лучшие"
        case .family: return "Семейные"
        case .vampire: return "Вампиры"
        case .love: return "Любовь"
        case .zombie: return "Зомби"
        case .comics: return "Комиксы"
        case .oskar: return "Оскар 2021"
        case .releases: return "Релизы"
        }
    }
    
    static func < (lhs: CollectionType, rhs: CollectionType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}


enum ContentTypeFilter: String, CaseIterable {
    case all = "ALL"
    case movie = "FILM"
    case series = "TV_SERIES"
    
    var displayName: String {
        switch self {
        case .all: return "Все"
        case .movie: return "Фильмы"
        case .series: return "Сериалы"
        }
    }
}
