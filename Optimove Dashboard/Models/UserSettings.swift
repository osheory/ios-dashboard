import Foundation

struct UserSettings: Codable {
    let username: String
    let password: String
    let siteUrl: String
    
    init(username: String, password: String, siteUrl: String) {
        self.username = username
        self.password = password
        self.siteUrl = siteUrl
    }
}
