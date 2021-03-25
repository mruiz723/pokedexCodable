//
//  APIClient.swift
//  PokedexCodable
//
//  Created by Marlon David Ruiz Arroyave on 24/03/21.
//

import Foundation
import Combine

protocol API {
    var baseURL: String { get }
    var networkDispatcher: NetworkDispatcherProtocol { get }
    func dispatch<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError>
}

struct APIClient: API {
    let baseURL: String
    let networkDispatcher: NetworkDispatcherProtocol

    init(baseURL: String = Constants.baseURL,
         networkDispatcher: NetworkDispatcherProtocol = NetworkDispatcher()) {
        self.baseURL = baseURL
        self.networkDispatcher = networkDispatcher
    }

    /// Dispatches a Request and returns a Result
    /// - Parameter request: Request to Dispatch
    /// - Returns: A Result containing decoded data or an error
    func dispatch<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(outputType: R.ReturnType.self, failure: NetworkRequestError.badRequest).eraseToAnyPublisher()
        }

        typealias RequestPublisher = AnyPublisher<R.ReturnType, NetworkRequestError>
        let requestPublisher: RequestPublisher = networkDispatcher.dispatch(request: urlRequest)
        return requestPublisher.eraseToAnyPublisher()
    }
}
