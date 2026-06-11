//
//  CatalogShellView.swift
//  Commerce-ios
//

import SwiftUI

struct CatalogShellView: View {
    let sessionStore: AppSessionStore
    let configuration: AppConfiguration
    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            CatalogHomeView(
                sessionStore: sessionStore,
                configuration: configuration,
                onSignOut: onSignOut
            )
        }
    }
}
