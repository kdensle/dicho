import Foundation
import Security

struct KeychainStore {
    private let service = "Dicho.OpenAI"
    private let account = "apiKey"

    func readAPIKey() -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return value
    }

    func saveAPIKey(_ apiKey: String) throws {
        try deleteAPIKey(allowMissing: true)

        var item = baseQuery()
        item[kSecValueData as String] = Data(apiKey.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledStatus(status)
        }
    }

    func deleteAPIKey(allowMissing: Bool = false) throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || (allowMissing && status == errSecItemNotFound) else {
            throw KeychainError.unhandledStatus(status)
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

enum KeychainError: LocalizedError {
    case unhandledStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .unhandledStatus(let status):
            "Keychain operation failed with status \(status)."
        }
    }
}

