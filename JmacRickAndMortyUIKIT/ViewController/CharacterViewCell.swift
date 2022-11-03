//
//  CharacterViewCell.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit

class CharacterViewCell: UICollectionViewCell {
    
    let characterNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    required init?(coder: NSCoder) {
        fatalError("Something went wrong :) ")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
    }
    
    func configureSubViews() {
        addSubview(characterNameLabel)
    }
    
    func setupCell(character: Result){
        characterNameLabel.text = character.name
    }
    
}
