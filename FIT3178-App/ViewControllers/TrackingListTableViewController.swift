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

class TrackingListTableViewController: UITableViewController, DatabaseListener, FloatyDelegate {
    
    var listenerType: ListenerType = .record
    
    private var recordSelected: TrackingRecord?
    private var trackingNoSelected, carrierSelected: String?
    let CELL_RECORD = "recordCell"
    let cellSpacingHeight: CGFloat = 5
    
    var records: [TrackingRecord] = []
//    var recordList: [NSManagedObject]!
    weak var databaseController: DatabaseProtocol?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 151
        

        // set navigation title
        self.navigationItem.title = "M-TRACK"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20,weight: UIFont.Weight.bold)]
        
        if Auth.auth().currentUser != nil {
            self.navigationItem.rightBarButtonItem?.title = "You're logged in"
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
    
    // DB listener function
    func onRecordChange(change: DatabaseChange, record: [TrackingRecord]) {
        records = record
        tableView.reloadData()
    }
    
    // Go to Sign-in screen
    @IBAction func signIn(_ sender: Any) {
        if Auth.auth().currentUser == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            vc?.modalPresentationStyle = .fullScreen
            vc?.modalTransitionStyle = .crossDissolve
            self.present(vc!, animated: true, completion: nil)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return records.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_RECORD, for: indexPath) as! TrackingListTableViewCell
        let record = records[indexPath.section]
        
        let dateString = self.dateToString(record.value(forKey: "date") as! Date)
        
        cell.nameLabel.text = record.value(forKey: "name") as? String ?? "[empty]"
        cell.dateLabel.text = dateString
        cell.detailsLabel.text = record.value(forKey: "details") as? String ?? "No details"
        cell.locationLabel.text = record.value(forKey: "location") as? String ?? "No location available"
        
        self.trackingNoSelected = records[indexPath.section].trackingNo
        self.carrierSelected = records[indexPath.section].carrier
        
        return cell
    }
    
    // MARK: - didSelectRowAt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListToDetailsSegue"{
            let destination = segue.destination as! TrackingDetailsTableViewController
            destination.trackingNo = trackingNoSelected
            destination.carrier_code = carrierSelected
        }
    }
    
    
    private func dateToString(_ date:Date, dateFormat:String = "dd-MM-yyyy HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "en_AU")
        formatter.dateFormat = dateFormat
        let dateString = formatter.string(from: date)
        return dateString
    }

}
