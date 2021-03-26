//
//  PokemonsViewModel.swift
//  PokedexCodable
//
//  Created by Marlon David Ruiz Arroyave on 24/03/21.
//

import Foundation
import Combine

class PokemonsViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = [Pokemon]()
    @Published var isLoadingPage: Bool = false

    private var subscriptions: Set<AnyCancellable> = []
    private var pageObject: PageObject?
    private var pokemonsManager: PokemonsManagerProtocol

    init(pokemonsManager: PokemonsManagerProtocol = PokemonsManager()) {
        self.pokemonsManager = pokemonsManager
    }

    func fetchPokemons() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            guard PokemonsManager.pokemonsOffset + PokemonsManager.limit <= PokemonsManager.count else { return }
            self.isLoadingPage = true
            var newPokemons: [Pokemon] = []
            self.pokemonsManager.fetchPokemonsList()
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                    }
                }, receiveValue: { pageObject in
                    self.pageObject = pageObject
                    PokemonsManager.count = pageObject.count

                    pageObject.results?.forEach { [weak self] namedAPIResource in
                        guard let self = self else { return }
                        // Fetch Pokemon by id
//                        guard let id = namedAPIResource.url.split(separator: "/").last else { return }
//                        self.pokemonsManager.fetchPokemon(by: String(id))
                        self.pokemonsManager.fetchPokemon(by: namedAPIResource.name)
                            .sink(receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    print(error.localizedDescription)
                                }
                            }, receiveValue: { pokemon in
                                newPokemons.append(pokemon)
                                if newPokemons.count == PokemonsManager.limit {
                                    DispatchQueue.main.async { [weak self] in
                                        guard let self = self else { return }
                                        self.isLoadingPage = false
                                        if PokemonsManager.pokemonsOffset == 20 {
                                            self.pokemons.removeAll()
                                        } else {
                                            self.pokemons.removeLast()
                                        }
                                        newPokemons.sort(by: {
                                            $0.id < $1.id
                                        })
                                        self.pokemons.append(contentsOf: newPokemons)
                                    }
                                }
                            })
                            .store(in: &self.subscriptions)
                    }
                })
                .store(in: &self.subscriptions)
        }
    }

    func fetchMorePockemons() {
        guard !isLoadingPage, let shimmerPokemon = Pokemon.pokemonMock() else { return }
        pokemons.append(shimmerPokemon)
        self.fetchPokemons()
    }

    // Initial shimmer data
    // Showing until data is loading
    func loadTempData() {
        var pokemons: [Pokemon] = []

        for _ in 1...20 {
            guard let temp = Pokemon.pokemonMock() else { return }
            pokemons.append(temp)
        }

        self.pokemons = pokemons
    }
}
