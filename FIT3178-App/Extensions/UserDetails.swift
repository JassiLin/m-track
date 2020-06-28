//
//  UserDetails.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import Firebase

extension UITableViewController {
    
    func setUpNavigationBarItems(){

        let loginIcon: UIBarButtonItem?
        
        if Auth.auth().currentUser == nil {
        
           loginIcon = UIBarButtonItem(image: UIImage(named: "login"), style: .plain, target: self, action: #selector(signIn(_:)))

        }else{
            var username: String?
            let firebaseDB = Firestore.firestore()
            let userRef = firebaseDB.collection("users")
            userRef.document(Auth.auth().currentUser!.uid).addSnapshotListener { (snapshot, err) in
                guard snapshot != nil else{
                    return
                }
//                username = snapshot?.get("username") as? String
                username = (snapshot!.data()! ["username"] as! String)
//                self.imageUrl = URL(string:snapshot?.get("imageUrl") as! String)
                
//                if let image = self.loadImageData(filename: self.imageName!) {
//                    self.profileImageView.image = image
//                } else{
//                    if let url = self.imageUrl {
//                        self.downloadImage(at: url) { [weak self] image in
//                        guard let `self` = self else {
//                          return
//                        }
//                        guard let image = image else {
//                          return
//                        }
//                        self.profileImageView.image = image
//                      }
//                    }
//                }

            }
            username = AppSettings.displayName
            loginIcon = UIBarButtonItem(title: username,
                            style: .plain,
                            target: self,
                            action: #selector(signIn(_:)))

        }
        navigationItem.rightBarButtonItem = loginIcon

        
    }
    
    @objc func signIn(_ sender: Any){
        
         if Auth.auth().currentUser == nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "Login")
            vc.modalPresentationStyle = .popover
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
         }else{
            let setting = UIStoryboard(name: "Setting", bundle: nil)
            let vc = setting.instantiateViewController(withIdentifier: "Profile")
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
}
