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

    private let db = Firestore.firestore()
    private var channels = [Channel]()
    private var currentChannelAlertController: UIAlertController?
    private var channelListener: ListenerRegistration?
    
    
    deinit {
      channelListener?.remove()
    }
    
    let CELL_CHANNELS = "channelCell"

//    init(currentUser: User) {
//      self.currentUser = currentUser
//      super.init(nibName: nil, bundle: nil)
//
//      title = "Channels"
//    }

//    required init?(coder aDecoder: NSCoder) {
//
//        self.currentUser = Auth.auth().currentUser!
//
//        super.init(coder: aDecoder)
//    }
    
    private var channelReference: CollectionReference {
        return db.collection("channels")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(channels.count)
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
        }else{
            channelListener = channelReference.addSnapshotListener { querySnapshot, error in
              guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
              }
              
              snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
              }
            }
        }
        
        
    }
    
    @IBAction func addChannel(_ sender: Any) {
        
        let ac = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addTextField { field in
          field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
          field.enablesReturnKeyAutomatically = true
          field.autocapitalizationType = .words
          field.clearButtonMode = .whileEditing
          field.placeholder = "Channel name"
          field.returnKeyType = .done
          field.tintColor = .grayishViolet
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { _ in
          self.createChannel()
        })
        createAction.isEnabled = false
        ac.addAction(createAction)
        ac.preferredAction = createAction
        
        present(ac, animated: true) {
          ac.textFields?.first?.becomeFirstResponder()
        }
        currentChannelAlertController = ac
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CHANNELS, for: indexPath)
      
      cell.accessoryType = .disclosureIndicator
      cell.textLabel?.text = channels[indexPath.row].name
      
      return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let channel = channels[indexPath.row]
        let vc = ChatViewController(user: Auth.auth().currentUser!, channel: channel)
      navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - functions
    private func createChannel() {
        guard let ac = currentChannelAlertController else {
          return
        }

        guard let channelName = ac.textFields?.first?.text else {
          return
        }

        let channel = Channel(name: channelName)
        channelReference.addDocument(data: channel.representation) { error in
            if let err = error {
                print("Error saving channel: \(err.localizedDescription)")
            }
        }
    }
        
    private func addChannelToTable(_ channel: Channel) {
        guard !channels.contains(channel) else {
        return
        }

        channels.append(channel)
        channels.sort()

        guard let index = channels.firstIndex(of: channel) else {
        return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        tableView.reloadData()
    }
    
    private func updateChannelInTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
        return
      }
      
      channels[index] = channel
      tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChannelFromTable(_ channel: Channel) {
        guard let index = channels.firstIndex(of: channel) else {
        return
      }
      
      channels.remove(at: index)
      tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
      guard let channel = Channel(document: change.document) else {
        return
      }
      
      switch change.type {
      case .added:
        addChannelToTable(channel)
        
      case .modified:
        updateChannelInTable(channel)
        
      case .removed:
        removeChannelFromTable(channel)
      }
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let ac = currentChannelAlertController else {
        return
        }

        ac.preferredAction?.isEnabled = field.hasText
    }
}
