//
//  NetworkDispatcher.swift
//  PokedexCodable
//
//  Created by Marlon David Ruiz Arroyave on 24/03/21.
//

import Foundation
import Combine

enum NetworkRequestError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
}

protocol NetworkDispatcherProtocol {
    var urlSession: URLSession { get }
    func dispatch<ReturnType: Codable>(request: URLRequest) -> AnyPublisher<ReturnType, NetworkRequestError>
}

struct NetworkDispatcher: NetworkDispatcherProtocol {
    let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    /// Dispatches an URLRequest and returns a publisher
    /// - Parameter request: URLRequest
    /// - Returns: A publisher with the provided decoded data or an error
    func dispatch<ReturnType: Codable>(request: URLRequest) -> AnyPublisher<ReturnType, NetworkRequestError> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return urlSession
            .dataTaskPublisher(for: request)
            // Map on Request response
            .tryMap { data, response in
                // If the response is invalid, throw an error
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    throw httpError(response.statusCode)
                }
                // Return Response data
                return data
            }
            // Decode data using our ReturnType
            .decode(type: ReturnType.self, decoder: decoder)
            // Handle any decoding errors
            .mapError { error in
                handleError(error)
            }
            // And finally, expose our publisher
            .eraseToAnyPublisher()
    }
}

extension NetworkDispatcher {
    /// Parses a HTTP StatusCode and returns a proper error
    /// - Parameter statusCode: HTTP status code
    /// - Returns: Mapped Error
    private func httpError(_ statusCode: Int) -> NetworkRequestError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
    /// Parses URLSession Publisher errors and return proper ones
    /// - Parameter error: URLSession publisher error
    /// - Returns: Readable NetworkRequestError
    private func handleError(_ error: Error) -> NetworkRequestError {
        switch error {
        case is Swift.DecodingError:
            return .decodingError
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError
        }
    }
}
