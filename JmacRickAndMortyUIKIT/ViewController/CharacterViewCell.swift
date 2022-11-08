//
//  CharacterViewCell.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 11/2/22.
//

import UIKit

class CharacterViewCell: UICollectionViewCell {
    
    let template: UIView = {
        let uiview = UIView()
        uiview.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        uiview.backgroundColor = .red
        return uiview
    }()
    
     let characterNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = ""
        lb.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        lb.backgroundColor = .blue
        return lb
    }()
    
//    let characterNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    required init?(coder: NSCoder) {
        fatalError("Something went wrong :) ")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
    }
    
    func configureSubViews() {
        self.template.addSubview(characterNameLabel)
        addSubview(template)
    }
    
    func setupCell(character: Result){
        characterNameLabel.text = character.name
    }
    
}
