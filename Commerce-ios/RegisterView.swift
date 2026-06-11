//
//  RegisterView.swift
//  Commerce-ios
//

import SwiftUI

struct RegisterView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create your account")
                .font(.largeTitle.bold())
            Text("Registration flow placeholder for the first auth release.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Register")
    }
}
