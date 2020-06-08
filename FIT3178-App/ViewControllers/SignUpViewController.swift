//
//  SignUpViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 21/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPWTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func submit(_ sender: Any) {
        
        // create cleaned versions of data
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard Utilities.validateEmail(emailTextField.text!) else{
            let alert = UIAlertController(title: "Invalid format", message: "Your email address format is incorrect.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            return
        }
        
        guard Utilities.validatePassword(passwordTextField.text!),
            Utilities.isPasswordValid(passwordTextField.text!)
        else{
            let alert = UIAlertController(title: "Invalid format", message: "Your password format is incorrect.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Try again", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            return
        }
         
        // create the user
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if error == nil {
                // store username
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["username": username, "uid": user!.user.uid]) {
                    (error) in
                    
                    if error != nil {
                        print("Error saving user data")
                    }
                }
                
                // jump to tracking list screen
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                vc?.modalPresentationStyle = .fullScreen
                vc?.modalTransitionStyle = .crossDissolve
                self.present(vc!, animated: true, completion: nil)
            }else{
                print(error as Any)
            }
        })
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
