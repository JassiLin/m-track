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

class TrackingListTableViewController: UITableViewController, DatabaseListener, FloatyDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    let image: UIImage? = nil
    let config = URLSessionConfiguration.default
    lazy var session = {
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }()
    
    private let firebaseDB = Firestore.firestore()
    var listenerType: ListenerType = .record
    private var recordListener: ListenerRegistration?
    
    private var recordSelected: TrackingRecord?
    private var trackingNoSelected, carrierSelected, name, ID: String?
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
    var ref: CollectionReference?
    var section: Int?
    deinit {
        recordListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation items
        
        self.navigationItem.title = "M-TRACK"
        
        let appearance = UINavigationBarAppearance(idiom: .phone)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        appearance.backgroundColor = .grayishRed
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        if Auth.auth().currentUser != nil {
            
            ref = db.collection("users").document(Auth.auth().currentUser!.uid).collection("trackingRecord")
            recordListener = ref!.addSnapshotListener { querySnapshot, error in
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
        addFloatyBtn()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpNavigationBarItems()
        databaseController?.addListener(listener: self)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Firebase Functions
    
    // DB listener function
    func onRecordChange(change: DatabaseChange, record: [TrackingRecord]) {
        records = record
        tableView.reloadData()
    }

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

    // MARK: - Functions
    
    private func downloadEpisodeImage(imageURLString: String) -> Int? {
        //        print(imageURLString)
        
        if let imageURL = URL(string: imageURLString) {
            let task = session.downloadTask(with: imageURL)
            task.resume()
            
            return task.taskIdentifier
        }
        return nil
    }

    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let _ = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            //            print("Progress \(downloadTask.currentRequest!.description): \(progress)")
        }
    }
    
    internal func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        do {
            let data = try Data(contentsOf: location)
            
            // Find the index of the cell that this download coresponds to.
            var cellIndex = -1
            for index in 0..<syncRecords.count {
                let record = syncRecords[index]
                if record.downloadTaskIdentifier == downloadTask.taskIdentifier {
                    syncRecords[index].imageView = UIImage(data: data)
                    cellIndex = index
                }
            }
            
            // If found the episode/cell to update, reload that row of tableview.
            if cellIndex >= 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: cellIndex, section: 0)], with: .automatic)
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    

    @IBAction func sync(_ sender: Any) {
        print(records)
        if Auth.auth().currentUser != nil {
            for record in records{
                let tracking = [
                    "trackingNo": record.trackingNo,
                    "carrier": record.carrier,
                    "name": record.name,
                    "location": record.location,
                    "date": record.strDate,
                    "status": record.status,
                    "latestDetails": record.details,
                    "imgUrl": ""
                ]
                let userRef = firebaseDB.collection("users")
                userRef.document(Auth.auth().currentUser!.uid).collection("trackingRecord").addDocument(data: tracking as [String : Any]){(error) in
                               
                               if error != nil {
                                   print("Error saving tracking data")
                               }else{
                                    self.databaseController?.deleteRecord(record: record)
                                    print("success")
                                    self.tableView.reloadData()
                                     let tracking = UIStoryboard(name: "Tracking", bundle: nil)
                                    let vc = tracking.instantiateViewController(withIdentifier: "AddTracking")
                                    vc.modalPresentationStyle = .fullScreen
                                    vc.modalTransitionStyle = .crossDissolve
                                    self.present(vc, animated: true, completion: nil)
                               }
                           }
            }
        }
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ListToDetailsSegue"{
            let destination = segue.destination as! TrackingDetailsTableViewController
            destination.section = section
            if Auth.auth().currentUser != nil {
                destination.ID = ID
            }else{
                destination.trackingNo = trackingNoSelected
                destination.carrier_code = carrierSelected
                destination.name = name
            }

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
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case SECTION_RECORD:
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_RECORD, for: indexPath) as! TrackingListTableViewCell
            let record = records[indexPath.row]
            
//            let dateString = Utilities.dateToString(record.value(forKey: "date") as! Date)
            
            cell.nameLabel.text = record.value(forKey: "name") as? String ?? "[empty]"
            cell.dateLabel.text = record.value(forKey: "strDate") as? String
            cell.detailsLabel.text = record.value(forKey: "details") as? String ?? "No details"
            cell.locationLabel.text = record.value(forKey: "location") as? String ?? "No location available"

            self.trackingNoSelected = records[indexPath.row].trackingNo
            self.carrierSelected = records[indexPath.row].carrier
            self.name = records[indexPath.row].name
            
            let status = record.value(forKey: "status") as? String
            let compared = "Delivered"
            let IV = UIImageView()
            cell.addSubview(IV)
            IV.anchor(top: cell.topAnchor, left: cell.leftAnchor, bottom: cell.locationLabel.topAnchor,  paddingTop: 15, paddingLeft: 25, paddingBottom: 10,  width: 45, height: 45)
            if status?.caseInsensitiveCompare(compared) == .orderedSame {
                
                IV.image = UIImage(named: "delivered")
            }else{
                IV.image = UIImage(named: "delivering")
            }
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
                
                let IV = UIImageView()
                cell.addSubview(IV)
                IV.image = image
                
                IV.anchor(top: cell.topAnchor, left: cell.leftAnchor, bottom: cell.locationLabel.topAnchor,  paddingTop: 15, paddingLeft: 25, paddingBottom: 10,  width: 45, height: 45)
                
                if record.imgUrl != "" {
                    
                    if let image = record.imageView {
                        // Use the image if already retreived.
                        IV.image = image
                    }else if record.downloadTaskIdentifier == nil {
                        // Otherwise, request image.
                        syncRecords[indexPath.row].downloadTaskIdentifier = downloadEpisodeImage(imageURLString: record.imgUrl!)
                    }
                }
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
            section = 0
        }
        
        if indexPath.section == SECTION_SYNC_RECORD {
            self.trackingNoSelected = syncRecords[indexPath.row].trackingNo
            self.carrierSelected = syncRecords[indexPath.row].carrier
            self.name = syncRecords[indexPath.row].name
            self.ID = syncRecords[indexPath.row].id
            section = 1
        }
        
        performSegue(withIdentifier: "ListToDetailsSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let id = syncRecords[indexPath.row].id
            ref?.document(id!).delete(completion: { (Error) in
                if let err = Error {
                    print(err)
                }
                tableView.reloadData()
            })
        }
    }

}
