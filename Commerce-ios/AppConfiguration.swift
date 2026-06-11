//
//  AppConfiguration.swift
//  Commerce-ios
//

import Foundation

enum AppEnvironment: String, CaseIterable, Codable, Sendable {
    case local
    case development
    case production
}

enum AppConfigurationError: Error, Equatable {
    case invalidBaseURL(environment: AppEnvironment, rawValue: String)
    case missingBaseURL(environment: AppEnvironment)
}

struct AppConfiguration: Sendable, Equatable {
    let environment: AppEnvironment
    let baseURL: URL

    init(environment: AppEnvironment, baseURL: URL) {
        self.environment = environment
        self.baseURL = baseURL
    }

    static func resolved(bundle: Bundle = .main, processInfo: ProcessInfo = .processInfo) throws -> AppConfiguration {
        let selectedEnvironment = environment(from: processInfo)

        switch selectedEnvironment {
        case .local:
            return AppConfiguration(environment: .local, baseURL: URL(string: "http://localhost:5015")!)
        case .development:
            return AppConfiguration(
                environment: .development,
                baseURL: try baseURL(for: .development, bundle: bundle)
            )
        case .production:
            return AppConfiguration(
                environment: .production,
                baseURL: try baseURL(for: .production, bundle: bundle)
            )
        }
    }

    static func environment(from processInfo: ProcessInfo = .processInfo) -> AppEnvironment {
        let rawValue = processInfo.environment["ZY_COMMERCE_APP_ENVIRONMENT"]?.lowercased()
        return AppEnvironment(rawValue: rawValue ?? "") ?? .local
    }

    static func baseURL(for environment: AppEnvironment, bundle: Bundle = .main) throws -> URL {
        let key: String

        switch environment {
        case .local:
            return URL(string: "http://localhost:5015")!
        case .development:
            key = "ZY_COMMERCE_API_BASE_URL_DEV"
        case .production:
            key = "ZY_COMMERCE_API_BASE_URL_PROD"
        }

        guard let rawValue = bundle.object(forInfoDictionaryKey: key) as? String, !rawValue.isEmpty else {
            throw AppConfigurationError.missingBaseURL(environment: environment)
        }

        guard let url = URL(string: rawValue) else {
            throw AppConfigurationError.invalidBaseURL(environment: environment, rawValue: rawValue)
        }

        return url
    }
}
