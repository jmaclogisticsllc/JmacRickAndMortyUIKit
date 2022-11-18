//
//  CharacterViewCell.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit

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
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .yellow
        imageView.clipsToBounds = true
        return imageView
    }()
    
//    let characterNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    required init?(coder: NSCoder) {
        fatalError("Something went wrong :) ")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        characterNameLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        characterImage.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    }
    
    func configureSubViews() {
        contentView.addSubview(characterImage)
        contentView.addSubview(characterNameLabel)
        contentView.clipsToBounds = true
        
    }
    
    func setupCell(character: Result){
        characterNameLabel.text = character.name
        characterImage.image = UIImage(named: character.image)
    }
    
}
