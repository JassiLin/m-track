//
//  LoginViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 20/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var loginSegment: UISegmentedControl!
    
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var signUpView: UIView!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInView.isHidden = false
        signUpView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user != nil {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                vc?.modalPresentationStyle = .fullScreen
                vc?.modalTransitionStyle = .crossDissolve
                self.present(vc!, animated: true, completion: nil)
            }
        })
    }

    @IBAction func loginSegmentTapped(_ sender: Any) {
        let getIndex = loginSegment.selectedSegmentIndex
        
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
