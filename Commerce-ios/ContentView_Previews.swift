//
//  ContentView_Previews.swift
//  Commerce-ios
//

import Foundation
import SwiftUI

#Preview {
    ContentView(
        appState: AppState(
            configurationResolver: PreviewAppConfigurationResolver(),
            tokenRepository: PreviewAccessTokenRepository(token: "preview-token")
        )
    )
}

private struct PreviewAppConfigurationResolver: AppConfigurationResolving {
    func resolve() throws -> AppConfiguration {
        AppConfiguration(
            environment: .local,
            baseURL: URL(string: "http://localhost:5015")!
        )
    }
}

private final class PreviewAccessTokenRepository: AccessTokenRepository {
    private var token: String?

    init(token: String?) {
        self.token = token
    }

    func loadAccessToken() throws -> String? {
        token
    }

    func saveAccessToken(_ accessToken: String?) throws {
        token = accessToken
    }

    func clearAccessToken() throws {
        token = nil
    }
}
