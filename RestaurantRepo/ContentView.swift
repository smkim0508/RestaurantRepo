//
//  ContentView.swift
//  RestaurantRepo
//
//  Created by Sungmin Kim on 4/30/25.
//
import UIKit
import SwiftUI
import MapKit

struct ContentView: View {
    @State private var userId = ""
    @State private var state = ""
    @State private var city = ""
    @State private var cuisine = ""
    @State private var restaurants: [Restaurant] = []
    @State private var explanation = ""
    @State private var score = 0.0
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Discover")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Your Next Favorite Spot")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Search Section
                        VStack(spacing: 16) {
                            // User ID
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(.secondary)
                                    TextField("Enter User ID", text: $userId)
                                        .textFieldStyle(PlainTextFieldStyle())
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            // State
                            HStack {
                                Image(systemName: "map")
                                    .foregroundColor(.secondary)
                                TextField("State (e.g., CA)", text: $state)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // City
                            HStack {
                                Image(systemName: "building.2")
                                    .foregroundColor(.secondary)
                                TextField("City (e.g., San Francisco)", text: $city)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Cuisine
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.secondary)
                                TextField("Cuisine (e.g., Korean, Thai)", text: $cuisine)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Search Button
                            Button(action: {
                                Task {
                                    await searchRestaurants()
                                }
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Find Restaurants")
                                            .fontWeight(.semibold)
                                        Image(systemName: "magnifyingglass")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isLoading)
                        }
                        .padding(.horizontal)
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Results Section
                        if !restaurants.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                // Explanation
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Recommendation By:")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(explanation)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    HStack {
                                        Text("Confidence Score:")
                                            .font(.subheadline)
                                        Text(String(format: "%.2f", score))
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                                Text("Recommended Restaurants")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                ForEach(restaurants) { restaurant in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text(restaurant.name)
                                                .font(.headline)
                                            Spacer()
                                            HStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.orange)
                                                Text(String(format: "%.1f", restaurant.stars))
                                                    .font(.subheadline)
                                            }
                                        }
                                        
                                        Text("\(restaurant.city), \(restaurant.state)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(restaurant.categories)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        } else if !isLoading {
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("Enter your preferences to find restaurants")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                    }
                }
            }
            .navigationTitle("Restaurant Repo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func searchRestaurants() async {
        isLoading = true
        errorMessage = nil
        
        guard let effectiveUserId = UserMapping.userId(for: userId) else {
            errorMessage = "Invalid user ID. Please enter a valid user ID or test user name"
            isLoading = false
            return
        }
        
        do {
            let response = try await RestaurantService.shared.searchRestaurants(
                userId: effectiveUserId,
                state: state,
                city: city,
                cuisine: cuisine
            )
            
            restaurants = response.restaurants
            explanation = response.explanation
            score = response.score
            
        } catch {
            errorMessage = "Failed to load restaurants. Please try again."
            print("Error: \(error)")
        }
        
        isLoading = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

