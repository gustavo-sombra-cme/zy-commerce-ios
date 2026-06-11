//
//  FailureView.swift
//  Commerce-ios
//

import SwiftUI

struct FailureView: View {
    let message: String

    var body: some View {
        ContentUnavailableView(
            "Unable to start the app",
            systemImage: "exclamationmark.triangle.fill",
            description: Text(message)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
