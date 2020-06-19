//
//  SettingsViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 21/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var signOutBtn: UIButton!
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()

        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
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
    
    override func viewWillAppear(_ animated: Bool) {
        let username = AppSettings.displayName
        nameLabel.text = username
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser == nil{
            signOutBtn.isHidden = true
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
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: view.topAnchor, paddingTop: 44,
                                width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        view.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 12)
    }
    
    @IBAction func signOut(_ sender: Any) {
        let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
          do {
            try Auth.auth().signOut()
          } catch {
            print("Error signing out: \(error.localizedDescription)")
          }
            AppSettings.displayName.removeAll()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
            vc?.modalPresentationStyle = .fullScreen
            vc?.modalTransitionStyle = .crossDissolve
            self.present(vc!, animated: true, completion: nil)
        }))
        self.present(ac, animated: true, completion: nil)
    }

}
