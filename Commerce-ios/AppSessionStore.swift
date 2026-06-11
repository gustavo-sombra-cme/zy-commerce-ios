//
//  AppSessionStore.swift
//  Commerce-ios
//

import Foundation
import Observation

enum AppSessionPhase: Equatable {
    case loading
    case unauthenticated
    case authenticated
    case failed(message: String)
}

@MainActor
@Observable
final class AppSessionStore: AccessTokenProviding {
    private(set) var phase: AppSessionPhase = .loading
    private(set) var accessToken: String?

    private let tokenStore: any AccessTokenRepository

    init(tokenStore: any AccessTokenRepository) {
        self.tokenStore = tokenStore
    }

    func bootstrap() {
        do {
            accessToken = try tokenStore.loadAccessToken()
            phase = accessToken == nil ? .unauthenticated : .authenticated
        } catch {
            accessToken = nil
            phase = .failed(message: error.localizedDescription)
        }
    }

    func signIn(accessToken: String) throws {
        try tokenStore.saveAccessToken(accessToken)
        self.accessToken = accessToken
        phase = .authenticated
    }

    func signOut() throws {
        try tokenStore.clearAccessToken()
        accessToken = nil
        phase = .unauthenticated
    }
}
