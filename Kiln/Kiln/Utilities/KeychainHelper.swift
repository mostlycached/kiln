import Foundation
import Security

/// Helper for securely storing and retrieving API keys from Keychain
final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    private let service = "com.kiln.app"
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
        case invalidData
    }
    
    /// Save a string to Keychain
    func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        // Delete existing item first
        try? delete(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    /// Retrieve a string from Keychain
    func retrieve(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    /// Delete an item from Keychain
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}

// MARK: - Convenience for API Key
extension KeychainHelper {
    private static let geminiAPIKeyKey = "gemini_api_key"
    
    var geminiAPIKey: String? {
        get { retrieve(forKey: Self.geminiAPIKeyKey) }
        set {
            if let newValue = newValue {
                try? save(newValue, forKey: Self.geminiAPIKeyKey)
            } else {
                try? delete(forKey: Self.geminiAPIKeyKey)
            }
        }
    }
    
    var hasAPIKey: Bool {
        geminiAPIKey != nil && !geminiAPIKey!.isEmpty
    }
}
