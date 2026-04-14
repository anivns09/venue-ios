//
//  MockURLSession.swift
//  CoreNetworking
//
//  Created by Anirudh Pandey on 15/4/2026.
//

@testable import CoreNetworking
import Foundation

final class MockURLSession: URLSessionProtocol {
    var result: Result<(Data, URLResponse), Error>

    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }

    /// Succeed with any JSON-encodable value and an optional status code.
    convenience init(value: some Encodable, statusCode: Int = 200) throws {
        let data = try JSONEncoder().encode(value)
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        self.init(result: .success((data, response)))
    }

    /// Fail with a given error.
    convenience init(error: Error) {
        self.init(result: .failure(error))
    }

    func data(from _: URL) async throws -> (Data, URLResponse) {
        try resolve()
    }

    func data(for _: URLRequest) async throws -> (Data, URLResponse) {
        try resolve()
    }
}

private extension MockURLSession {
    func resolve() throws -> (Data, URLResponse) {
        switch result {
        case let .success(tuple): return tuple
        case let .failure(error): throw error
        }
    }
}
