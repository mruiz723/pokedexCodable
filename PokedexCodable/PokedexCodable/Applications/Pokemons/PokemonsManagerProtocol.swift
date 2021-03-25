//
//  PokemonsManagerProtocol.swift
//  PokedexCodable
//
//  Created by Marlon David Ruiz Arroyave on 24/03/21.
//

import Foundation
import Combine

protocol PokemonsManagerProtocol {
    var apiClient: API { get set }
    func fetchPokemonsList() -> AnyPublisher<PageObject, NetworkRequestError>
    func fetchPokemon(by value: String) -> AnyPublisher<Pokemon, NetworkRequestError>
}
