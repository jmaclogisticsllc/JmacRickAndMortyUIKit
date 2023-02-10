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
        
        if let character = selectedCharacter {
            print("This is the character: \(character)")
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
