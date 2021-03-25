//
//  PokemonsManager.swift
//  PokedexCodable
//
//  Created by Marlon David Ruiz Arroyave on 24/03/21.
//

import Foundation
import Combine

struct PokemonsManager: PokemonsManagerProtocol {
    static var pokemonsOffset = 0
    static let limit = 20
    static var count = 20
    var apiClient: API

    init(apiClient: API = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchPokemonsList() -> AnyPublisher<PageObject, NetworkRequestError> {
        return apiClient.dispatch(PokemonsRequest())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchPokemon(by value: String) -> AnyPublisher<Pokemon, NetworkRequestError> {
        return apiClient.dispatch(PokemonRequest(value: value))
    }
}

struct PokemonsRequest: Request {
    typealias ReturnType = PageObject
    var path: String = "/pokemon"
    var queryItems: [URLQueryItem]?

    init() {
        let offsetItem: URLQueryItem = URLQueryItem(name: Constants.offset,
                                                    value: String(PokemonsManager.pokemonsOffset))
        let limitItem: URLQueryItem = URLQueryItem(name: Constants.limit,
                                                   value: String(PokemonsManager.limit))
        PokemonsManager.pokemonsOffset += PokemonsManager.limit
        queryItems = [offsetItem, limitItem]
    }
}

struct PokemonRequest: Request {
    typealias ReturnType = Pokemon
    let path: String

    init(value: String) {
        path = "/pokemon/\(value)"
    }
}
