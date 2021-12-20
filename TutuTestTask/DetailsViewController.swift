//
//  DetailsViewController.swift
//  TutuTestTask
//
//  Created by Phlegma on 17.12.2021.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var user: UserData?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var phoneField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = user {
            usernameField.text = user.username
            emailField.text = user.email
            websiteField.text = user.website
            phoneField.text = user.phone
        }

    }
    


}
