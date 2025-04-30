import Foundation

class RestaurantService {
    static let shared = RestaurantService()
    private let baseURL = "http://localhost:5001"
    
    private init() {}
    
    func searchRestaurants(userId: String, state: String, city: String, cuisine: String) async throws -> RestaurantResponse {
        print("Starting restaurant search with parameters:")
        print("userId: \(userId)")
        print("state: \(state)")
        print("city: \(city)")
        print("cuisine: \(cuisine)")
        
        var components = URLComponents(string: "\(baseURL)/api/recommend")!
        components.queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "city", value: city),
            URLQueryItem(name: "cuisine", value: cuisine),
            URLQueryItem(name: "top_n", value: "5")
        ]
        
        guard let url = components.url else {
            print("Failed to create URL")
            throw RestaurantError.invalidURL
        }
        
        print("Making request to: \(url)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw RestaurantError.invalidResponse
            }
            
            print("Received response with status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["error"] as? String {
                    print("Server error: \(errorMessage)")
                    if let traceback = errorJson["traceback"] as? String {
                        print("Traceback: \(traceback)")
                    }
                    throw RestaurantError.serverError(errorMessage)
                }
                throw RestaurantError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let restaurantResponse = try decoder.decode(RestaurantResponse.self, from: data)
            print("Successfully decoded response with \(restaurantResponse.restaurants.count) restaurants")
            return restaurantResponse
            
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw RestaurantError.decodingError(error)
        } catch let error as RestaurantError {
            print("Restaurant error: \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw RestaurantError.unknown(error)
        }
    }
} 