// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - Network Service Protocol

public protocol NetworkServiceProtocol {
    func loadData<T: Decodable>(from urlString: String, headers: [String: String]) async throws -> T
    func postData<T: Decodable, B: Encodable>(to urlString: String, body: B, headers: [String: String]) async throws -> T
}

// MARK: - Network Service

public class NetworkService: NetworkServiceProtocol {
    public enum NetworkError: Error, Equatable {
        case invalidURL
        case httpError(statusCode: Int)
        case decodingError
        case unknown
    }

    private let session: URLSessionProtocol

    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    public func loadData<T: Decodable>(from urlString: String,
                                       headers: [String: String]) async throws -> T
    {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await session.data(for: request)
        return try validate(response: response, data: data)
    }
    
    public func postData<T: Decodable, B: Encodable>(to urlString: String, body: B, headers: [String: String]) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(body)
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await session.data(for: request)
        return try validate(response: response, data: data)
    }

    private func validate<T: Decodable>(response: URLResponse, data: Data) throws -> T {
        guard let http = response as? HTTPURLResponse else { throw NetworkError.unknown }

        guard (200 ..< 300).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
