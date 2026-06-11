//
//  CatalogHomeView.swift
//  Commerce-ios
//

import SwiftUI

struct CatalogHomeView: View {
    let sessionStore: AppSessionStore
    let configuration: AppConfiguration
    let onSignOut: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Catalog shell")
                .font(.largeTitle.bold())

            Text("API base URL: \(configuration.baseURL.absoluteString)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Authenticated requests will reuse the stored JWT access token.")
                .foregroundStyle(.secondary)

            Button("Sign out", action: onSignOut)
                .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Home")
    }
}
