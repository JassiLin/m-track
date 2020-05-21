//
//  AddTrackingViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 15/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import FirebaseAuth

class AddTrackingViewController: UIViewController {

    var listenerType: ListenerType = .record
    
    var date: String?
    var location: String?
    var details: String?
    
    @IBOutlet weak var trackingNoTF: UITextField!
    @IBOutlet weak var carrierTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        
        if Auth.auth().currentUser != nil {
            self.navigationItem.rightBarButtonItem?.title = "You're logged in"
        }
    }
    
    @IBAction func addTracking(_ sender: Any) {
        
        if trackingNoTF.text != "" && carrierTF.text != "" {
            requestTrackingDetails()
        }
    }
    
    func saveRecord() {
        
        let name = nameTF?.text
        let trackingNo = trackingNoTF?.text
        let carrier = carrierTF?.text

        let addedRecord = databaseController?.addRecord(trackingNo: trackingNo!, carrier: carrier!, name: name!, date: date!, location: location!, details: details!)
        if(addedRecord != nil){
            print("Added sucessfully: \(addedRecord!)")
            navigationController?.popViewController(animated: true)
        }

    }
    
    // MARK: - process API data requesting
    func requestTrackingDetails() {

        let headers = [
            "x-rapidapi-host": "order-tracking.p.rapidapi.com",
            "x-rapidapi-key": "721ec697admshac6e25b8181ed51p1221c1jsn84964ace47ae",
            "content-type": "application/json",
            "accept": "application/json"
        ]
        let parameters = [
            "tracking_number": trackingNoTF.text!,
            "carrier_code": carrierTF.text!
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
                print(httpResponse!)
                print("data: \(data!)")
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(trackingData.self, from: data!)
                    print("decodeData: \(decodedData)")
                    if let listTracking = decodedData.data?.items?.first {
                        print("listTracking: \(listTracking)")
                        self.date = listTracking.lastUpdateTime
                        self.details = listTracking.lastEvent
                        self.location = listTracking.destinationCountry
                        DispatchQueue.main.async{
                            self.saveRecord()
                        }
                    }
                    
                } catch let err {
                    print("error: \(err)")
                }
            }
            
        })

        dataTask.resume()
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

