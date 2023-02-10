//
//  CharacterViewCell.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit
import Kingfisher

class CharacterViewCell: UICollectionViewCell {
    
     let characterNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.backgroundColor = .blue
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
            characterNameLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

            addSubview(characterImage)
            addSubview(characterNameLabel)
            clipsToBounds = true

            // Add constraints to the image view
            NSLayoutConstraint.activate([
                characterImage.topAnchor.constraint(equalTo: topAnchor),
                characterImage.leadingAnchor.constraint(equalTo: leadingAnchor),
                characterImage.trailingAnchor.constraint(equalTo: trailingAnchor),
                characterImage.bottomAnchor.constraint(equalTo: characterNameLabel.topAnchor),
                characterImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
            ])
            
            // Add constraints to the label
            characterNameLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                characterNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                characterNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                characterNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                characterNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2)
            ])
        }
    
    func setupCell(character: Result){
        characterNameLabel.text = character.name
        print("This is the image: \(character.image)")
        let character_image = URL(string: character.image)
        characterImage.kf.setImage(with: character_image)
    }
    
}
