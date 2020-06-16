//
//  TrackingDetailsTableViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import Floaty
import FirebaseAuth
import Firebase

class TrackingDetailsTableViewController: UITableViewController {

    private let firebaseDB = Firestore.firestore()
    
    var trackingNo, carrier_code, ID: String?
    var date: [String] = []
    var location: [String] = []
    var status: [String] = []
    var desc: [String] = []
    
    private var selectedDate: String = ""
    private var selectedLocation: String = ""
    private var selectedStatus: String = ""
    private var selectedDesc: String = ""
    
    var indicator = UIActivityIndicatorView()
    var name:String = ""
    var rControl = UIRefreshControl()
    
    var index: Int = 0
    let SECTION_INFO = 0
    let SECTION_DETAILS = 1
    let CELL_INFO = "infoCell"
    let CELL_DETAILS = "detailsCell"
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Get information by document ID
        let userRef = firebaseDB.collection("users")
        
        userRef.document(Auth.auth().currentUser!.uid).collection("trackingRecord").document(self.ID!).addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for record updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            self.trackingNo = snapshot.get("trackingNo") as? String
            self.name = snapshot.get("name") as! String
            self.carrier_code = snapshot.get("carrier") as? String
            
            self.requestTrackingDetails()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 151

        if Auth.auth().currentUser != nil {
            self.navigationItem.rightBarButtonItem?.title = "You're logged in"
        }
        
        // pull to refresh
        rControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        rControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(rControl)
        
        // set float button
        let floatyBtn = Floaty()
        floatyBtn.addItem("Add tracking", icon: UIImage(named: "track")!, handler: {
            _ in
            self.performSegue(withIdentifier: "DetailsToAddSegue", sender: self)
        })
        floatyBtn.addItem("Edit tracking", icon: UIImage(named: "track")!, handler: {
            _ in
            self.performSegue(withIdentifier: "DetailsToEditSegue", sender: self)
        })
        floatyBtn.paddingY = 200
        floatyBtn.sticky = true
        self.view.addSubview(floatyBtn)
       
    }
    
    @IBAction func editRecord(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(identifier: "EditRecord") as? EditTrackingViewController
        vc?.name = name
        vc?.trackingNo = trackingNo
        
        performSegue(withIdentifier: "DetailsToEditSegue", sender: self)
    }
    
    private func requestTrackingDetails(){
//        indicator.style = UIActivityIndicatorView.Style.medium
//        indicator.center = self.tableView.center
//        self.view.addSubview(indicator)

        clearData(array: &date)
        clearData(array: &desc)
        clearData(array: &status)
        clearData(array: &location)
        
        let headers = [
            "x-rapidapi-host": "order-tracking.p.rapidapi.com",
            "x-rapidapi-key": "721ec697admshac6e25b8181ed51p1221c1jsn84964ace47ae",
            "content-type": "application/json",
            "accept": "application/json"
        ]
        
        let parameters = [
            "tracking_number": trackingNo!,
            "carrier_code": carrier_code!
        ] as [String : Any]
        
        let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        let request = NSMutableURLRequest(url: NSURL(string: "https://order-tracking.p.rapidapi.com/trackings/realtime")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData! as Data

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("error: \(error!)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print("response code: \(httpResponse?.statusCode as Any)")

                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(trackingData.self, from: data!)
                    if (decodedData.data?.items?.first?.originInfo?.trackinfo?.count)! > 0 {
                        for i in 0 ..< (decodedData.data?.items?.first?.originInfo?.trackinfo?.count)!{
                            let trackInfo = decodedData.data?.items?.first?.originInfo?.trackinfo![i]
                            self.date.append((trackInfo?.date)!)
                            self.desc.append((trackInfo?.statusDescription)!)
                            self.location.append((trackInfo?.details)!)
                            self.status.append((trackInfo?.checkpointStatus)!)
                        }
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                            //        self.indicator.startAnimating()
                            //        self.indicator.backgroundColor = UIColor.clear
                        }
                    }

                } catch let err {
                    print("error: \(err)")
                }
            }
            
        })

        dataTask.resume()


    }
    
    private func clearData(array: inout [String]){
        if array != []{
            array = []
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        requestTrackingDetails()
        
        // Dismiss the refresh control.
        DispatchQueue.main.async {
            self.rControl.endRefreshing()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.rControl.isRefreshing {
                strongSelf.rControl.endRefreshing()
            } else if !strongSelf.rControl.isHidden {
                strongSelf.rControl.beginRefreshing()
                strongSelf.rControl.endRefreshing()
            }
        }
    }
    


    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DetailsToMapSegue"){
            let vc = segue.destination as! MapFunctionViewController
            vc.date = selectedDate
            vc.status = selectedStatus
            vc.location = selectedLocation
            vc.event = selectedDesc
        }
        
        if (segue.identifier == "DetailsToEditSegue"){
            let vc = segue.destination as! EditTrackingViewController
            vc.trackingNo = trackingNo
            vc.carrier = carrier_code
            vc.name = name
            vc.ID = ID
        }
    }
    
}


    // MARK: - Table view data source

extension TrackingDetailsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
          case SECTION_INFO:
             return 1
          case SECTION_DETAILS:
            return date.count
          default:
             return 0
        }
    }

        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case SECTION_DETAILS:
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DETAILS, for: indexPath) as! TrackingDetailsTableViewCell
            guard
                !self.date.isEmpty,
                !self.date.isEmpty,
                !self.date.isEmpty,
                !self.date.isEmpty
            else {
                return cell
            }
            cell.dateLabel.text = self.date[indexPath.row]
            cell.desciptionLabel.text = self.desc[indexPath.row]
            cell.locationLabel.text = self.location[indexPath.row]
            cell.statusLabel.text = self.status[indexPath.row]

            return cell
            
        case SECTION_INFO:
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath) as! TrackingDetailsTableViewCell
            
            cell.nameLabel.text = self.name
            cell.trackingNoLabel.text = "Tracking number: \(self.trackingNo ?? "loading...")"
            cell.lastStatusLabel.text = "Status: \(self.status.first ?? "loading...")"
            cell.lastUpdatedDateLabel.text = "Last updated date: \(self.date.first ?? "loading...")"
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        
        if indexPath.section == SECTION_DETAILS {
            selectedDate = date[index]
            selectedDesc = desc[index]
            selectedStatus = status[index]
            selectedLocation = location[index]
            
            performSegue(withIdentifier: "DetailsToMapSegue", sender: self)
        }
//        let trackingStoryboard = UIStoryboard(name: "Tracking", bundle: nil)
//        let vc = trackingStoryboard.instantiateViewController(identifier: "MapDetails") as? MapDetailsViewController
        

    }
}


