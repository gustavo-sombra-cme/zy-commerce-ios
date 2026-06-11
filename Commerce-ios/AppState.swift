//
//  AppState.swift
//  Commerce-ios
//

import Foundation
import Observation

protocol AppConfigurationResolving {
    func resolve() throws -> AppConfiguration
}

struct LiveAppConfigurationResolver: AppConfigurationResolving {
    func resolve() throws -> AppConfiguration {
        try AppConfiguration.resolved()
    }
}

enum AppLaunchState: Equatable {
    case loading
    case ready
    case failed(message: String)
}

@Observable
final class AppState {
    private(set) var launchState: AppLaunchState = .loading
    private(set) var sessionStore: AppSessionStore?
    private(set) var configuration: AppConfiguration?

    private let configurationResolver: any AppConfigurationResolving
    private let tokenRepository: any AccessTokenRepository
    private var didBootstrap = false

    init(
        configurationResolver: any AppConfigurationResolving = LiveAppConfigurationResolver(),
        tokenRepository: any AccessTokenRepository = KeychainAccessTokenRepository()
    ) {
        self.configurationResolver = configurationResolver
        self.tokenRepository = tokenRepository
    }

    @MainActor
    func bootstrap() {
        guard !didBootstrap else {
            return
        }

        didBootstrap = true

        do {
            let configuration = try configurationResolver.resolve()
            let sessionStore = AppSessionStore(tokenStore: tokenRepository)

            self.configuration = configuration
            self.sessionStore = sessionStore

            sessionStore.bootstrap()
            launchState = .ready
        } catch {
            launchState = .failed(message: error.localizedDescription)
        }
    }

    @MainActor
    func signOut() {
        guard let sessionStore else {
            return
        }

        do {
            try sessionStore.signOut()
        } catch {
            launchState = .failed(message: error.localizedDescription)
        }
    }
}
