import Foundation

public class UserDefaultsHelper {
    // Singleton instance
    public static let shared = UserDefaultsHelper()
    
    // Prevents external instantiation
    private init() {}
    
    // Define the possible keys as an enum
    // Add more keys here as needed
    public enum Key: String {
        case iCloudEnabled,
             showUsersOnHomesreen,
             sortUsersByName,
             openToSpecificServer
    }
    
    // Func to get a bool value, with a default if not set
    public func get(for key: Key, defaultValue: Bool = false) -> Bool {
        UserDefaults.standard.object(forKey: key.rawValue) as? Bool ?? defaultValue
    }
}
