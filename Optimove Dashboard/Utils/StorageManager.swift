import Foundation

class StorageManager {
    static let shared = StorageManager()
    private let settingsKey = "optimove_settings"
    
    private init() {}
    
    func saveSettings(_ settings: UserSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: settingsKey)
        } catch {
            print("Error saving settings: \(error)")
        }
    }
    
    func loadSettings() -> UserSettings? {
        guard let data = UserDefaults.standard.data(forKey: settingsKey) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(UserSettings.self, from: data)
        } catch {
            print("Error loading settings: \(error)")
            return nil
        }
    }
    
    func hasSettings() -> Bool {
        return UserDefaults.standard.data(forKey: settingsKey) != nil
    }
    
    func clearSettings() {
        UserDefaults.standard.removeObject(forKey: settingsKey)
    }
}
