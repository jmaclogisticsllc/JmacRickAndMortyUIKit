//
//  NetworkManager.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import Foundation

enum CharacterError: Error {
    case invalidServerResponse
}

class RickAndMortyService {
    
    func fetchCharacter(completionHanlder: @escaping ([Result]) -> Void) {
        let urlString = "https://rickandmortyapi.com/api/character"
        
        let url = URL(string: urlString)!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            do {
                let character = try JSONDecoder().decode(Character.self, from: data!)
                completionHanlder(character.results)

            } catch {
                print("DEBUG: Parsing Error")
            }
        }
        dataTask.resume()
    }
}
