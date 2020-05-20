//
//  LoginViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 20/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginSegment: UISegmentedControl!
    
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var signUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInView.isHidden = false
        signUpView.isHidden = true
    }
    

    @IBAction func loginSegmentTapped(_ sender: Any) {
        let getIndex = loginSegment.selectedSegmentIndex
        print(getIndex)
        
        switch (getIndex) {
        case 0:
            signInView.isHidden = false
            signUpView.isHidden = true
        case 1:
            signInView.isHidden = true
            signUpView.isHidden = false
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
