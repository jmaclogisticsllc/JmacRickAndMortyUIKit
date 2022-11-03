//
//  ViewController.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit

class MainVC: UICollectionViewController {
        
    // List of Characters
    var characters = [Result]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        
        // Call UIViewController
        super.viewDidLoad()
        
        fetchCharacter { results in
            self.characters.append(contentsOf: results)
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CharacterViewCell.self, forCellWithReuseIdentifier: "characterCell")
        collectionView.backgroundColor = .green
    }
    
    func fetchCharacter(completion: @escaping ([Result]) -> Void) {
                
        let urlString = "https://rickandmortyapi.com/api/character"
        
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            do {
                let character = try JSONDecoder().decode(Character.self, from: data!)
                completion(character.results)
                
            } catch {
                print("DEBUG: Parsing Error")
            }
        }
        .resume()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.characters.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let characterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCell", for: indexPath) as! CharacterViewCell
        characterCell.characterNameLabel.text = characters[indexPath.item].name
        
        return characterCell
    }
}
    


