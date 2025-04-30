import Foundation

/// A utility for mapping between test user names and their actual user IDs
public struct UserMapping {
    /// Dictionary mapping test user names to their actual user IDs
    private static let userMappings: [String: String] = [
        "Test User 1": "_BcWyKQL16ndpBdggh2kNA",
        "Test User 2": "user456",
        "Test User 3": "user789",
        "Test User 4": "user101",
        "Test User 5": "user102"
    ]
    
    /// Get the actual user ID for a test user name or ID
    public static func userId(for input: String) -> String? {
        // First check if it's a test user name
        if let userId = userMappings[input] {
            return userId
        }
        
        // Then check if it's a test user ID format (e.g., "user123")
        if input.hasPrefix("user") {
            return input
        }
        
        // If it's neither, return nil
        return nil
    }
    
    /// Get all available test user names
    public static var testUserNames: [String] {
        return Array(userMappings.keys).sorted()
    }
    
    /// Get a random test user name
    public static var randomTestUser: String {
        return testUserNames.randomElement() ?? "Test User 1"
    }
} 