//
//  CharacterDetailViewController.swift
//  JmacRickAndMortyUIKIT
//
//  Created by Tom on 2/10/23.
//

import UIKit



class CharacterDetailViewController: UIViewController {
    
    var selectedCharacter: Result?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the CharacterViewCell did not pass a nil value
        if let character = selectedCharacter {
            // Value passed
            print("This is the character: \(character)")
        }
        
        // Continues without throwing and error
    }
}
