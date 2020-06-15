//
//  TrackingListTableViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 12/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import CoreData
import Floaty
import FirebaseAuth
import Firebase

class TrackingListTableViewController: UITableViewController, DatabaseListener, FloatyDelegate {
    
    var listenerType: ListenerType = .record
    private var recordListener: ListenerRegistration?
    
    private var recordSelected: TrackingRecord?
    private var trackingNoSelected, carrierSelected, name: String?
    let SECTION_SYNC_RECORD = 0
    let SECTION_RECORD = 1
    let CELL_RECORD = "recordCell"
    let CELL_SYNC_RECORD = "syncRecordCell"
    let cellSpacingHeight: CGFloat = 5
    
    var records: [TrackingRecord] = []
    var syncRecords: [Record] = []
    weak var databaseController: DatabaseProtocol?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let db = Firestore.firestore()
    
    deinit {
        recordListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 151

        // set navigation title
        self.navigationItem.title = "M-TRACK"
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20,weight: UIFont.Weight.bold)]
        
        if Auth.auth().currentUser != nil {
            self.navigationItem.rightBarButtonItem?.title = "You're logged in"
            
            let ref = db.collection("users").document(Auth.auth().currentUser!.uid).collection("trackingRecord")
            recordListener = ref.addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                  print("Error listening for record updates: \(error?.localizedDescription ?? "No error")")
                  return
                }
            
                snapshot.documentChanges.forEach { change in
                  self.handleDocumentChange(change)
                }
                
            }
        }
        
        databaseController = appDelegate.databaseController
        
        // set float button
        let floatyBtn = Floaty()
        floatyBtn.addItem("Add tracking", icon: UIImage(named: "track")!, handler: {
            _ in
            self.performSegue(withIdentifier: "ListToAddSegue", sender: self)
        })
        floatyBtn.paddingY = 200
        floatyBtn.sticky = true
        self.view.addSubview(floatyBtn)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Functions
    
    // DB listener function
    func onRecordChange(change: DatabaseChange, record: [TrackingRecord]) {
        records = record
        tableView.reloadData()
    }
    
    // Firebase functions
    private func addRecordToTable(_ record: Record) {
        guard !syncRecords.contains(record) else {
        return
        }

        syncRecords.append(record)
        syncRecords.sort()

        guard let index = syncRecords.firstIndex(of: record) else {
        return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: SECTION_SYNC_RECORD)], with: .automatic)
        tableView.reloadData()
    }
    
    private func updateRecordInTable(_ record: Record) {
        guard let index = syncRecords.firstIndex(of: record) else {
        return
      }
      
          syncRecords[index] = record
          tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeRecordFromTable(_ record: Record) {
        guard let index = syncRecords.firstIndex(of: record) else {
        return
      }
      
        syncRecords.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    private func handleDocumentChange(_ change: DocumentChange) {
        guard let record = Record(document: change.document) else {
          return
        }
        
        switch change.type {
        case .added:
          addRecordToTable(record)
          
        case .modified:
          updateRecordInTable(record)
          
        case .removed:
          removeRecordFromTable(record)
        }
    }
    
    // Go to Sign-in screen
    @IBAction func signIn(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "Login")
            vc.modalPresentationStyle = .popover
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListToDetailsSegue"{
            let destination = segue.destination as! TrackingDetailsTableViewController
            destination.trackingNo = trackingNoSelected
            destination.carrier_code = carrierSelected
            destination.name = name!
        }
    }
    

}


// MARK: - Table view data source
extension TrackingListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 2
        }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
          case SECTION_SYNC_RECORD:
             return syncRecords.count
          case SECTION_RECORD:
            return records.count
          default:
             return 0
        }
    }
        
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
          case SECTION_SYNC_RECORD:
             return "Synchrnoized Records"
          case SECTION_RECORD:
            return "Local Records"
          default:
             return nil
        }
    }
        
    //    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return cellSpacingHeight
    //    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case SECTION_RECORD:
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_RECORD, for: indexPath) as! TrackingListTableViewCell
            let record = records[indexPath.row]
            
            let dateString = Utilities.dateToString(record.value(forKey: "date") as! Date)
            
            cell.nameLabel.text = record.value(forKey: "name") as? String ?? "[empty]"
            cell.dateLabel.text = dateString
            cell.detailsLabel.text = record.value(forKey: "details") as? String ?? "No details"
            cell.locationLabel.text = record.value(forKey: "location") as? String ?? "No location available"

            self.trackingNoSelected = records[indexPath.row].trackingNo
            self.carrierSelected = records[indexPath.row].carrier
            self.name = records[indexPath.row].name
            
            return cell
        case SECTION_SYNC_RECORD:
            if Auth.auth().currentUser != nil {
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_RECORD, for: indexPath) as! TrackingListTableViewCell
                let record = syncRecords[indexPath.row]
                
                cell.nameLabel.text = record.name as String
                cell.dateLabel.text = record.date
                cell.detailsLabel.text = record.latestDetails
                cell.locationLabel.text = record.location

                self.trackingNoSelected = record.trackingNo
                self.carrierSelected = record.carrier
                self.name = record.name
                
                return cell
            }else{
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
        
        // MARK: - didSelectRowAt
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if indexPath.section == SECTION_RECORD {
                self.trackingNoSelected = records[indexPath.row].trackingNo
                self.carrierSelected = records[indexPath.row].carrier
                self.name = records[indexPath.row].name
            }
            
            if indexPath.section == SECTION_SYNC_RECORD {
                self.trackingNoSelected = syncRecords[indexPath.row].trackingNo
                self.carrierSelected = syncRecords[indexPath.row].carrier
                self.name = syncRecords[indexPath.row].name
            }
            
            performSegue(withIdentifier: "ListToDetailsSegue", sender: self)
        }

        /*
        // Override to support conditional editing of the table view.
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }
        */

        /*
        // Override to support editing the table view.
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
        */

        /*
        // Override to support rearranging the table view.
        override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

        }
        */

        /*
        // Override to support conditional rearranging of the table view.
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the item to be re-orderable.
            return true
        }
        */
}
