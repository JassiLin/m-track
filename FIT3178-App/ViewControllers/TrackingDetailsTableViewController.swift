//
//  TrackingDetailsTableViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import Floaty

class TrackingDetailsTableViewController: UITableViewController {

    var trackingNo, carrier_code: String?
    var date: [String] = []
    var location: [String] = []
    var status: [String] = []
    var desc: [String] = []
    let CELL_DETAILS = "detailsCell"
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestTrackingDetails()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 151

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
    
    private func requestTrackingDetails(){
//        indicator.style = UIActivityIndicatorView.Style.medium
//        indicator.center = self.tableView.center
//        self.view.addSubview(indicator)
        
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
                print(httpResponse?.statusCode as Any)

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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return date.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DETAILS, for: indexPath) as! TrackingDetailsTableViewCell
        if !self.date.isEmpty{
            
        }
        cell.dateLabel.text = self.date[indexPath.row]
        cell.desciptionLabel.text = self.desc[indexPath.row]
        cell.locationLabel.text = self.location[indexPath.row]
        cell.statusLabel.text = self.status[indexPath.row]

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
