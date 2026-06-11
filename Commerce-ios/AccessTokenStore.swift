//
//  AccessTokenStore.swift
//  Commerce-ios
//

import Foundation
import Security

protocol AccessTokenRepository {
    func loadAccessToken() throws -> String?
    func saveAccessToken(_ accessToken: String?) throws
    func clearAccessToken() throws
}

protocol AccessTokenProviding: AnyObject {
    var accessToken: String? { get }
}

enum KeychainStoreError: Error, Equatable {
    case unexpectedStatus(OSStatus)
    case invalidStoredValue
}

protocol KeychainClient {
    func readData(service: String, account: String) throws -> Data?
    func saveData(_ data: Data, service: String, account: String) throws
    func deleteData(service: String, account: String) throws
}

struct SystemKeychainClient: KeychainClient {
    func readData(service: String, account: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainStoreError.unexpectedStatus(status)
        }
    }

    func saveData(_ data: Data, service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }

        if updateStatus != errSecItemNotFound {
            throw KeychainStoreError.unexpectedStatus(updateStatus)
        }

        var addQuery = query
        addQuery[kSecValueData as String] = data

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainStoreError.unexpectedStatus(addStatus)
        }
    }

    func deleteData(service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainStoreError.unexpectedStatus(status)
        }
    }
}

final class KeychainAccessTokenRepository: AccessTokenRepository {
    private let service: String
    private let account: String
    private let keychain: KeychainClient

    init(
        service: String = Bundle.main.bundleIdentifier ?? "com.hussein.Commerce-ios",
        account: String = "access-token",
        keychain: KeychainClient = SystemKeychainClient()
    ) {
        self.service = service
        self.account = account
        self.keychain = keychain
    }

    func loadAccessToken() throws -> String? {
        guard let data = try keychain.readData(service: service, account: account) else {
            return nil
        }

        guard let token = String(data: data, encoding: .utf8), !token.isEmpty else {
            throw KeychainStoreError.invalidStoredValue
        }

        return token
    }

    func saveAccessToken(_ accessToken: String?) throws {
        guard let accessToken, !accessToken.isEmpty else {
            try clearAccessToken()
            return
        }

        guard let data = accessToken.data(using: .utf8) else {
            throw KeychainStoreError.invalidStoredValue
        }

        try keychain.saveData(data, service: service, account: account)
    }

    func clearAccessToken() throws {
        try keychain.deleteData(service: service, account: account)
    }
}
