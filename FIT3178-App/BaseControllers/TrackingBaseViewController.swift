////
////  TrackingBaseViewController.swift
////  FIT3178-App
////
////  Created by Jingmei Lin on 18/6/20.
////  Copyright © 2020 Jingmei Lin. All rights reserved.
////
//
//import UIKit
//import FirebaseAuth
//import Firebase
//import Floaty
//
//class TrackingBaseViewController: UITableViewController {
//
//    private let defaults = UserDefaults.standard
//    private let firebaseDB = Firestore.firestore()
//    private var username: String = ""
//
//    override func viewWillAppear(_ animated: Bool) {
//        if Auth.auth().currentUser != nil {
//            getUsername()
//        }
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 151
//
//    }
//
//    private func setUpNavigationBarItems(){
//
//        let loginBtn: UIBarButtonItem?
//        if Auth.auth().currentUser == nil {
//            loginBtn = UIBarButtonItem(image: UIImage(named: "person"),
//                                            style: .plain,
//                                            target: self,
//                                            action: #selector(signIn(_:)))
//
//        }else{
////            getUsername()
//            let username = AppSettings.displayName ?? "N/A"
//            loginBtn = UIBarButtonItem(title: username,
//                                            style: .plain,
//                                            target: self,
//                                            action: #selector(signIn(_:)))
//
//        }
//        navigationItem.rightBarButtonItem = loginBtn
//
//    }
//
//    @IBAction func signIn(_ sender: Any) {
//        if Auth.auth().currentUser == nil {
//            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = mainStoryboard.instantiateViewController(withIdentifier: "Login")
//            vc.modalPresentationStyle = .popover
//            vc.modalTransitionStyle = .crossDissolve
//            self.present(vc, animated: true, completion: nil)
//        }
//    }
//
//    private func getUsername() {
//        let userRef = self.firebaseDB.collection("users")
//        userRef.document(Auth.auth().currentUser!.uid).addSnapshotListener { (querySnapshot, error) in
//            guard let snapshot = querySnapshot else {
//                print("Error listening for record updates: \(error?.localizedDescription ?? "No error")")
//                return
//            }
//            self.username = snapshot.get("username") as! String
//            DispatchQueue.main.async{
//                self.setUpNavigationBarItems()
//            }
//        }
//    }
//}
