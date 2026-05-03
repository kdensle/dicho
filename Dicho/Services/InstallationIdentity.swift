import Foundation

enum InstallationIdentity {
    private static let key = "dichoInstallationID"

    static var current: String {
        if let savedID = UserDefaults.standard.string(forKey: key), !savedID.isEmpty {
            return savedID
        }

        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
}
