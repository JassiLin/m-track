//
//  SettingsViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 21/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var carrierListLabel: UILabel!
    @IBOutlet weak var signOutBtn: UIButton!
    
//    let window: UIWindow?
    var userRef: CollectionReference?
    private let firebaseDB = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    var imageUrl: URL?
    var imageName: String?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()

        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.white.cgColor

        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
//        label.text = username
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .dark
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFloatyBtn()
        // Set switch button
        if AppSettings.darkMode != nil{
            if AppSettings.darkMode == 1{
                darkModeSwitch.isOn = true
            }else{
                darkModeSwitch.isOn = false
            }
        }else{
            darkModeSwitch.isOn = false
        }
        
        if Auth.auth().currentUser == nil{
            signOutBtn.setTitle("Sign In", for: .normal)
            
        }

        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height
        let grayishRedView = UIView(frame: frame)
        grayishRedView.backgroundColor = .grayishRed
        self.tableView.addSubview(grayishRedView)
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200))
        tableView.tableHeaderView = header
        header.backgroundColor = .grayishRed
        header.addSubview(profileImageView)
        
        if Auth.auth().currentUser != nil{
            userRef = firebaseDB.collection("users")
            userRef!.document(Auth.auth().currentUser!.uid).addSnapshotListener { (snapshot, err) in
                guard snapshot != nil else{
                    return
                }
                self.nameLabel.text = snapshot?.get("username") as? String
                self.imageUrl = URL(string:snapshot?.get("imageUrl") as! String)
                self.imageName = snapshot?.get("imageName") as? String
                
                if let image = self.loadImageData(filename: self.imageName!) {
                    self.profileImageView.image = image
                } else{
                    if let url = self.imageUrl {
                        self.downloadImage(at: url) { [weak self] image in
                        guard let `self` = self else {
                          return
                        }
                        guard let image = image else {
                          return
                        }
                        self.profileImageView.image = image
                      }
                    }
                }

            }
        }else{
            profileImageView.image = UIImage(named:"User")
            nameLabel.text = "LOGIN"
        }
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: view.topAnchor, paddingTop: 44,
                                width: 100, height: 100)
        profileImageView.layer.cornerRadius = 100 / 2
        
        view.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 12)
        
        // Set gesture recognizer
        if Auth.auth().currentUser != nil {
            profileLabel.isUserInteractionEnabled = true
            profileImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target:self, action: #selector(profileTapped))
            let textTap = UITapGestureRecognizer(target:self, action: #selector(profileTapped))
            profileLabel.addGestureRecognizer(tap)
            profileImageView.addGestureRecognizer(textTap)
        }
        
        
    }
    
    
    private func loadImageData(filename:String) -> UIImage?{
       
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage (contentsOfFile: imageURL.path)
        return image
    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
      let ref = Storage.storage().reference(forURL: url.absoluteString)
      let megaByte = Int64(1 * 1024 * 1024)
      
      ref.getData(maxSize: megaByte) { data, error in
        guard let imageData = data else {
          completion(nil)
          return
        }
        completion(UIImage(data: imageData))
      }
    }
    
    @objc private func profileTapped(){
        performSegue(withIdentifier: "settingsToProfileSegue", sender: self)
    }
    
    @IBAction func signOut(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
              do {
                try Auth.auth().signOut()
              } catch {
                print("Error signing out: \(error.localizedDescription)")
              }
                AppSettings.displayName.removeAll()
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "TabBar")
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }))
            self.present(ac, animated: true, completion: nil)
        }else{
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "Login")
            vc.modalPresentationStyle = .popover
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
    }

    

}
