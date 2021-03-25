//
//  ContentView.swift
//  PokedexCodable
//
//  Created by Marlon David Ruiz Arroyave on 20/03/21.
//

import SwiftUI

class User: ObservableObject, Codable {
    // 1
    enum CodingKeys: CodingKey {
        case name
    }

    @Published var name = "Globant"

    // 2
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }

    // 3
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
