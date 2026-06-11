//
//  LoginView.swift
//  Commerce-ios
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome back")
                .font(.largeTitle.bold())

            Text("Sign in to access your cart, catalog, and account.")
                .foregroundStyle(.secondary)

            NavigationLink("Create an account") {
                RegisterView()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Sign In")
    }
}
