//
//  PokemonsView.swift
//  PokedexCodable
//
//  Created by Marlon David Ruiz Arroyave on 24/03/21.
//

import SwiftUI

struct PokemonsView: View {

    @StateObject var viewModel: PokemonsViewModel

    // For tracking
    @State var time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()

    init(viewModel: PokemonsViewModel = .init()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List(viewModel.pokemons, id: \.id) { pokemon in
                if pokemon.height == 0 {
                    ShimmerPokemonRow()
                } else {
                    // Going to track end of data...
                    ZStack {
                        if viewModel.pokemons.last?.id == pokemon.id {
                            GeometryReader { geometry in
                                PokemonRow(pokemon: pokemon)
                                    .onAppear {
                                        self.time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
                                    }
                                    .onReceive(self.time) { _ in
                                        if geometry.frame(in: .global).maxY > UIScreen.main.bounds.height - 160 {
                                            self.time.upstream.connect()
                                                .cancel()
                                            print("Update data...")
                                            viewModel.fetchMorePockemons()
                                        }
                                    }
                            }
                        } else {
                            PokemonRow(pokemon: pokemon)
                        }
                    }
                }
            }
            .navigationTitle("Pokemons")
            .onAppear(perform: loadData)
        }
    }

    private func loadData() {
        viewModel.loadTempData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.fetchPokemons()
        }
    }
}

struct PokemonsView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonsView()
    }
}
