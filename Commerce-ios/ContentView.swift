//
//  ContentView.swift
//  Commerce-ios
//
//  Created by Hussein Jaber on 10/06/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var appState: AppState

    init(appState: AppState = AppState()) {
        _appState = State(initialValue: appState)
    }

    var body: some View {
        Group {
            switch appState.launchState {
            case .loading:
                LoadingView(message: "Loading Commerce")
            case .ready:
                if let sessionStore = appState.sessionStore,
                   let configuration = appState.configuration {
                    AppShellView(
                        sessionStore: sessionStore,
                        configuration: configuration,
                        onSignOut: appState.signOut
                    )
                } else {
                    LoadingView(message: "Loading Commerce")
                }
            case .failed(let message):
                FailureView(message: message)
            }
        }
        .task {
            appState.bootstrap()
        }
    }
}
