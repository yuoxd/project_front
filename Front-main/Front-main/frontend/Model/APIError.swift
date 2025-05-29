//
//  APIError.swift
//  frontend
//
//  Created by 596 on 16.05.2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case unknownError
    case invalidQuery(String)
    case saveErrorWithMessage(String)
    case networkError(String)
    case invalidRequest(message: String)
    case invalidCredentials
    case unauthorized
    case userAlreadyExists
    case serverErrorWithMessage(Int, String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL адрес"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .decodingError(let error):
            return "Ошибка обработки данных: (error.localizedDescription)"
        case .serverError(let code):
            return "Ошибка сервера (код (code))"
        case .unknownError:
            return "Неизвестная ошибка"
        case .invalidQuery(let message):
            return "Неверный запрос: (message)"
        case .saveErrorWithMessage(let message):
            return message
        case .networkError(let message):
            return message
        case .invalidRequest(let message):
            return message
        case .invalidCredentials:
            return "Ошибка запроса"
        case .unauthorized:
            return "Вы не авторизованы"
        case .userAlreadyExists:
            return "Аккаунт уже существует"
        case .serverErrorWithMessage(_, let message):
            return message
        }
    }
}

