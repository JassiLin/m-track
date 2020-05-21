//
//  ChannelsViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 21/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChannelsTableViewController: UITableViewController {

    private var channels = [Channel]()
    let CELL_CHANNELS = "channelCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            
            let alert = UIAlertController(title: "Login requirement", message: "You need to sign in first to access chat function.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { action in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                vc?.modalPresentationStyle = .fullScreen
                vc?.modalTransitionStyle = .crossDissolve
                self.present(vc!, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Consider again", style: .cancel, handler: {action in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                vc?.modalPresentationStyle = .fullScreen
                vc?.modalTransitionStyle = .crossDissolve
                self.present(vc!, animated: true, completion: nil)
            }))

            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
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
