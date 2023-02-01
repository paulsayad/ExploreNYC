//
//  SettingsViewController.swift
//  ExploreNYC
//
//  Created by Paul Sayad on 5/13/22.
//

import UIKit

protocol SettingsViewControllerDelegate {
    func flipDarkMode(enabled: Bool)
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var darkButton: UIButton!
    var delegate: SettingsViewControllerDelegate?
    var darkMode = UserDefaults.standard.bool(forKey: "theme")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(darkMode){
            self.view.backgroundColor = .lightGray
            darkButton.backgroundColor = .black
            darkButton.setTitleColor(.white, for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func toggleTheme(_ sender: Any) {
        if(!darkMode) {
            print("swapping")
            self.view.backgroundColor = .lightGray
            darkButton.backgroundColor = .black
            darkButton.setTitleColor(.white, for: .normal)
            darkMode = true
        } else {
            self.view.backgroundColor = .systemTeal
            darkButton.backgroundColor = .lightGray
            darkButton.setTitleColor(.black, for: .normal)
            darkMode = false
        }
        delegate?.flipDarkMode(enabled: true)
    }
}
