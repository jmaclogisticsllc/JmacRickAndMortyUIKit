//
//  CharacterDetailViewController.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 2/10/23.
//

import UIKit



class CharacterDetailViewController: UIViewController {
    
    var selectedCharacter: Result?
    
    let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let characterNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the CharacterViewCell did not pass a nil value
        if let character = selectedCharacter {
            // Value passed
            print("This is the character: \(character)")
            characterNameLabel.text = character.name
            let chacterImage = URL(string: character.image)
            characterImageView.kf.setImage(with: chacterImage)
        }
        
        view.addSubview(characterImageView)
        view.addSubview(characterNameLabel)
        
        // Add constraints to the characterImageView
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            characterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 200),
            characterImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Add constraints to the characterNameLabel
        NSLayoutConstraint.activate([
            characterNameLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 20),
            characterNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            characterNameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
