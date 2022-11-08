//
//  ViewController.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit

class CharacterViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let service: RickAndMortyService = RickAndMortyService()
        
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
        
        service.fetchCharacter { results in
            self.characters.append(contentsOf: results)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CharacterViewCell.self, forCellWithReuseIdentifier: "characterCell")
        collectionView.backgroundColor = .green
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.characters.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let characterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCell", for: indexPath) as! CharacterViewCell
        characterCell.setupCell(character: characters[indexPath.item])
        return characterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}


