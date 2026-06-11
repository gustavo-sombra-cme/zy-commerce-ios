//
//  APIClient.swift
//  Commerce-ios
//

import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct EmptyResponse: Decodable, Sendable {}

struct APIEndpoint: Sendable, Equatable {
    var path: String
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var body: Data? = nil

    func urlRequest(baseURL: URL) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let resolvedURL = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: resolvedURL)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}

enum APIClientError: Error, Equatable {
    case invalidResponse
    case unacceptableStatusCode(Int)
}

final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: (any AccessTokenProviding)?
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        tokenProvider: (any AccessTokenProviding)? = nil,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.session = session
        self.decoder = decoder
    }

    func send<Response: Decodable & Sendable>(_ endpoint: APIEndpoint, as type: Response.Type = Response.self) async throws -> Response {
        var request = try endpoint.urlRequest(baseURL: baseURL)

        if let accessToken = tokenProvider?.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIClientError.unacceptableStatusCode(httpResponse.statusCode)
        }

        if Response.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse() as! Response
        }

        return try decoder.decode(Response.self, from: data)
    }

    func send<Response: Decodable & Sendable>(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil,
        as type: Response.Type = Response.self
    ) async throws -> Response {
        let endpoint = APIEndpoint(path: path, method: method, queryItems: queryItems, headers: headers, body: body)
        return try await send(endpoint, as: type)
    }
}
