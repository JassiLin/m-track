//
//  UserListTableViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 24/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import Firebase

class UserListTableViewController: UITableViewController {

    private let db = Firestore.firestore()
    private var users = [UserData]()
    private var userListener: ListenerRegistration?
    
    private var userRef: CollectionReference {
        return db.collection("users")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userListener = userRef.addSnapshotListener { querySnapshot, error in
          guard let snapshot = querySnapshot else {
            print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
            return
          }
          
          snapshot.documentChanges.forEach { change in
            self.handleDocumentChange(change)
          }
        }
    }
            
    private func addUserToTable(_ user: UserData) {
        guard !users.contains(user) else {
        return
        }

        users.append(user)
        users.sort()

        guard let index = users.firstIndex(of: user) else {
        return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        tableView.reloadData()
    }
    
    private func updateUserInTable(_ user: UserData) {
        guard let index = users.firstIndex(of: user) else {
        return
      }
      
      users[index] = user
      tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeUserFromTable(_ user: UserData) {
        guard let index = users.firstIndex(of: user) else {
        return
      }
      
      users.remove(at: index)
      tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
      guard let user = UserData(document: change.document) else {
        return
      }
      
      switch change.type {
      case .added:
        addUserToTable(user)
        
      case .modified:
        updateUserInTable(user)
        
      case .removed:
        removeUserFromTable(user)
      }
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

// MARK: - Table view data source

extension UserListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = users[indexPath.row].username
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//      let channel = channels[indexPath.row]
//        let vc = ChatViewController(user: Auth.auth().currentUser!, channel: channel)
//      navigationController?.pushViewController(vc, animated: true)
    }


}
