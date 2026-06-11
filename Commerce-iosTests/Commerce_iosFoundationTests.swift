//
//  Commerce_iosFoundationTests.swift
//  Commerce-iosTests
//

import Foundation
import Testing
@testable import Commerce_ios

struct Commerce_iosFoundationTests {
    @Test func appConfigurationDefaultsToLocalEnvironment() throws {
        let configuration = try AppConfiguration.resolved()

        #expect(configuration.environment == .local)
        #expect(configuration.baseURL == URL(string: "http://localhost:5015"))
    }

    @Test @MainActor func apiClientInjectsBearerTokenAndDecodesResponse() async throws {
        let session = URLSession(configuration: {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [URLProtocolStub.self]
            return configuration
        }())

        let expectedURL = URL(string: "https://example.com/catalog/items")!
        let tokenProvider = MockAccessTokenProvider(accessToken: "jwt-token")
        let client = APIClient(
            baseURL: URL(string: "https://example.com")!,
            tokenProvider: tokenProvider,
            session: session
        )

        URLProtocolStub.requestHandler = { request in
            #expect(request.url == expectedURL)
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer jwt-token")
            #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")

            let response = HTTPURLResponse(
                url: expectedURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            return (response, #"{"id":42,"name":"Featured"}"#.data(using: .utf8)!)
        }

        let response: CatalogItem = try await client.send(
            path: "catalog/items",
            as: CatalogItem.self
        )

        #expect(response == CatalogItem(id: 42, name: "Featured"))
    }

    @Test func keychainTokenStoreLoadsSavesAndClearsTokens() throws {
        let keychain = MockKeychainClient()
        let store = KeychainAccessTokenRepository(service: "test.service", account: "access-token", keychain: keychain)

        try store.saveAccessToken("abc123")
        #expect(keychain.savedData == Data("abc123".utf8))
        #expect(try store.loadAccessToken() == "abc123")

        try store.clearAccessToken()
        #expect(keychain.didDelete)
    }

    @Test @MainActor func sessionStoreBootstrapsAndPersistsState() throws {
        let tokenStore = MockTokenStore(token: "stored-token")
        let sessionStore = AppSessionStore(tokenStore: tokenStore)

        sessionStore.bootstrap()

        #expect(sessionStore.phase == .authenticated)
        #expect(sessionStore.accessToken == "stored-token")

        try sessionStore.signOut()

        #expect(sessionStore.phase == .unauthenticated)
        #expect(sessionStore.accessToken == nil)
        #expect(tokenStore.didClear)
    }

    @Test @MainActor func appStateBootstrapsDependenciesAndSession() throws {
        let resolver = MockConfigurationResolver(
            configuration: AppConfiguration(
                environment: .development,
                baseURL: URL(string: "https://api.example.com")!
            )
        )
        let tokenStore = MockTokenStore(token: "persisted-token")
        let appState = AppState(
            configurationResolver: resolver,
            tokenRepository: tokenStore
        )

        appState.bootstrap()

        #expect(appState.launchState == .ready)
        #expect(appState.configuration?.baseURL == URL(string: "https://api.example.com"))
        #expect(appState.sessionStore?.phase == .authenticated)
        #expect(appState.sessionStore?.accessToken == "persisted-token")
    }
}

private struct CatalogItem: Decodable, Equatable, Sendable {
    let id: Int
    let name: String
}

private final class MockAccessTokenProvider: AccessTokenProviding {
    let accessToken: String?

    init(accessToken: String?) {
        self.accessToken = accessToken
    }
}

private final class MockKeychainClient: KeychainClient {
    var savedData: Data?
    var storedData: Data?
    var didDelete = false

    func readData(service: String, account: String) throws -> Data? {
        storedData
    }

    func saveData(_ data: Data, service: String, account: String) throws {
        savedData = data
        storedData = data
    }

    func deleteData(service: String, account: String) throws {
        didDelete = true
        storedData = nil
    }
}

@MainActor
private final class MockTokenStore: AccessTokenRepository {
    var token: String?
    var didClear = false

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
        didClear = true
        token = nil
    }
}

private struct MockConfigurationResolver: AppConfigurationResolving {
    let configuration: AppConfiguration

    func resolve() throws -> AppConfiguration {
        configuration
    }
}

private final class URLProtocolStub: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
