//
//  Models.swift
//  RestaurantRepo
//
//  Created by Sungmin Kim on 4/30/25.
//

import Foundation

// MARK: - Restaurant Model
public struct Restaurant: Codable, Identifiable {
    public let business_id: String
    public let name: String
    public let state: String
    public let city: String
    public let categories: String
    public let stars: Double
    public let latitude: Double
    public let longitude: Double
    public let explanation: String
    public let score: Double
    
    public var id: String { business_id }
    
    public init(business_id: String, name: String, state: String, city: String, categories: String, stars: Double, latitude: Double, longitude: Double, explanation: String, score: Double) {
        self.business_id = business_id
        self.name = name
        self.state = state
        self.city = city
        self.categories = categories
        self.stars = stars
        self.latitude = latitude
        self.longitude = longitude
        self.explanation = explanation
        self.score = score
    }
}

// MARK: - Response Models
public struct RestaurantResponse: Codable {
    public let restaurants: [Restaurant]
    public let explanation: String
    public let score: Double
    
    public init(restaurants: [Restaurant], explanation: String, score: Double) {
        self.restaurants = restaurants
        self.explanation = explanation
        self.score = score
    }
}

// MARK: - Error Types
public enum RestaurantError: Error {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case decodingError(Error)
    case unknown(Error)
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}