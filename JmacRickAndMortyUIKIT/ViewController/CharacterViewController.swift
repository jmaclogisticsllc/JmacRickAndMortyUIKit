//
//  ViewController.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit

class CharacterViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CharacterViewCellDelegate {
    
    private let service: RickAndMortyService = RickAndMortyService()

    // List of Characters
    var characters = [Result]()
    
    override func loadView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.view = collectionView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        
        // Call UIViewController
        super.viewDidLoad()
        collectionView.backgroundColor = .green
        
        service.fetchCharacter { results in
            self.characters.append(contentsOf: results)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CharacterViewCell.self, forCellWithReuseIdentifier: "characterCell")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.characters.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let characterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCell", for: indexPath) as! CharacterViewCell
        characterCell.setupCell(character: characters[indexPath.item])
        characterCell.delegate = self
        return characterCell
    }
    
    func didSelectCharacter(cell: CharacterViewCell, character: Result) {
        let characterDetailVC = CharacterDetailViewController()
        characterDetailVC.selectedCharacter = character
        characterDetailVC.view.backgroundColor = .white
        characterDetailVC.title = character.name
        
        self.navigationController?.pushViewController(characterDetailVC, animated: true)
    }
}


