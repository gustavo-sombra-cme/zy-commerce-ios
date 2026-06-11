//
//  AppShellView.swift
//  Commerce-ios
//

import SwiftUI

struct AppShellView: View {
    let sessionStore: AppSessionStore
    let configuration: AppConfiguration
    let onSignOut: () -> Void

    var body: some View {
        switch sessionStore.phase {
        case .loading:
            LoadingView(message: "Preparing your account")
        case .unauthenticated:
            AuthenticationShellView()
        case .authenticated:
            CatalogShellView(
                sessionStore: sessionStore,
                configuration: configuration,
                onSignOut: onSignOut
            )
        case .failed(let message):
            FailureView(message: message)
        }
    }
}
