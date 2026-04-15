@testable import CoreNetworking
import XCTest

struct Ticket: Codable, Equatable {
    let id: Int
    let title: String
}

struct PostData: Encodable, Equatable {
    let title: String
}

final class CoreNetworkingTests: XCTestCase {
    func testShouldLoadDataWhenSuccess() async throws {
        let expected = Ticket(id: 1, title: "Ticket 1")
        let session = try MockURLSession(value: expected)
        let sut = NetworkService(session: session)

        let result: Ticket = try await sut.loadData(from: "https://example.com/ticket", headers: [:])
        XCTAssertEqual(result, expected)
    }
    
    func testShouldPostDataWhenSuccess() async throws {
        let expected = Ticket(id: 1, title: "Ticket 1")
        let session = try MockURLSession(value: expected)
        let sut = NetworkService(session: session)

        let result: Ticket = try await sut.postData(to: "https://example.com/ticket", body: PostData(title: "title"), headers: [:])
        XCTAssertEqual(result, expected)
    }

    func testShouldNotLoadDataWhenInvalidURL() async {
        let sut = NetworkService()
        do {
            let _: Ticket = try await sut.loadData(from: "", headers: [:])
            XCTFail("Expected invalidURL error")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testShouldNotPostDataWhenInvalidURL() async {
        let sut = NetworkService()
        do {
            let _: Ticket = try await sut.postData(to: "", body: PostData(title: "title"), headers: [:])
            XCTFail("Expected invalidURL error")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .invalidURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testShouldReturnHttpError404WhenLoadData() async throws {
        let session = try MockURLSession(value: Ticket(id: 0, title: ""), statusCode: 404)
        let sut = NetworkService(session: session)
        do {
            let _: Ticket = try await sut.loadData(from: "https://example.com/ticket", headers: [:])
            XCTFail("Expected httpError")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .httpError(statusCode: 404))
        }
    }
    
    func testShouldReturnHttpError404WhenPostData() async throws {
        let session = try MockURLSession(value: Ticket(id: 0, title: ""), statusCode: 404)
        let sut = NetworkService(session: session)
        do {
            let _: Ticket = try await sut.postData(to: "https://example.com/ticket", body: PostData(title: "title"), headers: [:])
            XCTFail("Expected httpError")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .httpError(statusCode: 404))
        }
    }

    func testShouldReturnDecodingErrorWhenLoadData() async throws {
        let garbled = Data("{ \"wrong\": true }".utf8)
        let response = try XCTUnwrap(try HTTPURLResponse(
            url: XCTUnwrap(URL(string: "https://example.com")),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        let session = MockURLSession(result: .success((garbled, response)))
        let sut = NetworkService(session: session)
        do {
            let _: Ticket = try await sut.loadData(from: "https://example.com/ticket", headers: [:])
            XCTFail("Expected decodingError")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .decodingError)
        }
    }
    
    func testShouldReturnDecodingErrorWhenPostData() async throws {
        let garbled = Data("{ \"wrong\": true }".utf8)
        let response = try XCTUnwrap(try HTTPURLResponse(
            url: XCTUnwrap(URL(string: "https://example.com")),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        let session = MockURLSession(result: .success((garbled, response)))
        let sut = NetworkService(session: session)
        do {
            let _: Ticket = try await sut.postData(to: "https://example.com/ticket", body: PostData(title: "title"), headers: [:])
            XCTFail("Expected decodingError")
        } catch let error as NetworkService.NetworkError {
            XCTAssertEqual(error, .decodingError)
        }
    }

    func testShouldReturnNetworkFailureWhenLoadData() async {
        let session = MockURLSession(error: URLError(.notConnectedToInternet))
        let sut = NetworkService(session: session)

        do {
            let _: Ticket = try await sut.loadData(from: "https://example.com/ticket", headers: [:])
            XCTFail("Expected URLError")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testShouldReturnNetworkFailureWhenPostData() async {
        let session = MockURLSession(error: URLError(.notConnectedToInternet))
        let sut = NetworkService(session: session)

        do {
            let _: Ticket = try await sut.postData(to: "https://example.com/ticket", body: PostData(title: "title"), headers: [:])
            XCTFail("Expected URLError")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .notConnectedToInternet)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
