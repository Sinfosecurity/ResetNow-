//
//  KeychainService.swift
//  ResetNow
//
//  Secure storage for sensitive data like API keys
//  NEVER store API keys in source code, UserDefaults, or plain text files
//

import Foundation
import Security

enum KeychainService {
    private static let service = "com.resetnow.app"
    
    enum Key: String {
        case openAIAPIKey = "openai_api_key"
    }
    
    // MARK: - Save
    
    /// Securely save a value to Keychain
    @discardableResult
    static func save(key: Key, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete existing item first
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Retrieve
    
    /// Retrieve a value from Keychain
    static func retrieve(key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
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
    
    // MARK: - Delete
    
    /// Delete a value from Keychain
    @discardableResult
    static func delete(key: Key) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Check Existence
    
    /// Check if a key exists in Keychain
    static func exists(key: Key) -> Bool {
        retrieve(key: key) != nil
    }
}





