//
//  CharacterViewCell.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit
import Kingfisher

protocol CharacterViewCellDelegate {
    func didSelectCharacter(cell: CharacterViewCell, character: Result)
}

class CharacterViewCell: UICollectionViewCell {
    
    var delegate: CharacterViewCellDelegate?
    
    var character: Result?
    
    var characterName: String = "" {
        didSet {
            characterNameLabel.text = characterName
        }
    }
    
     let characterNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.backgroundColor = .blue
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let characterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "house")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    required init?(coder: NSCoder) {
        fatalError("Something went wrong :) ")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
    }
                                                
    
    func configureSubViews() {
            addSubview(characterImage)
            addSubview(characterNameLabel)
            clipsToBounds = true

            // Add constraints to the image view
            NSLayoutConstraint.activate([
                characterImage.topAnchor.constraint(equalTo: topAnchor),
                characterImage.leadingAnchor.constraint(equalTo: leadingAnchor),
                characterImage.trailingAnchor.constraint(equalTo: trailingAnchor),
                characterImage.bottomAnchor.constraint(equalTo: characterNameLabel.topAnchor),
            ])
            
            // Add constraints to the label
            characterNameLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                characterNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                characterNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                characterNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                characterNameLabel.heightAnchor.constraint(equalToConstant: 50.0)
            ])
        }
    
    func setupCell(character: Result) {
        self.character = character
        
        // Setup TapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        addGestureRecognizer(tapGesture)
        
        // Add Character Name to Label
        characterNameLabel.text = character.name
        
        // Add the Image to the CharacterImageView
        let character_image = URL(string: character.image)
        characterImage.kf.setImage(with: character_image)
    }
    
    // Handle the Tap
    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let delegate = delegate else { return }
        delegate.didSelectCharacter(cell: self, character: character!)
    }
}
