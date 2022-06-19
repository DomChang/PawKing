//
//  KeychainManager.swift
//  PawKing
//
//  Created by ChunKai Chang on 2022/6/18.
//

import Foundation

enum KeychainService: String {
    
    case userId
}

enum KeychainAccount: String {
    
    case pawKing
}

class KeychainManager {
    
    static let shared =  KeychainManager()
    
    private init() {}
    
    func save(_ token: Data, service: String, account: String) {
        
        // Create query
        let query = [
            kSecValueData: token,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess {
            // Print out the error
            print("Error: \(status)")
        }
        
        if status == errSecDuplicateItem {
               // Item already exist, thus update it.
               let query = [
                   kSecAttrService: service,
                   kSecAttrAccount: account,
                   kSecClass: kSecClassGenericPassword,
               ] as CFDictionary

               let attributesToUpdate = [kSecValueData: token] as CFDictionary

               // Update existing item
               SecItemUpdate(query, attributesToUpdate)
           }
    }
    
    
    func read(service: String, account: String) -> Data? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
}
