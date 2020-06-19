//
//  UserDetails.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

extension UITableViewController {
    
    func setUpNavigationBarItems(){
            
        let loginBtn: UIBarButtonItem?
        
        if Auth.auth().currentUser == nil {
            
            loginBtn = UIBarButtonItem(image: UIImage(systemName: "person"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(signIn(_:)))
            loginBtn?.width = 25
        }else{

            let username = AppSettings.displayName
            loginBtn = UIBarButtonItem(title: username,
                                            style: .plain,
                                            target: self,
                                            action: #selector(signIn(_:)))
            let loginIcon = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem = loginIcon
        }
        
        navigationItem.rightBarButtonItem = loginBtn
        
    }
    
    @objc func signIn(_ sender: Any){
        
         if Auth.auth().currentUser == nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "Login")
            vc.modalPresentationStyle = .popover
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
}
