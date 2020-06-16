//
//  EditTrackingViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 11/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class EditTrackingViewController: UIViewController {

    private let firebaseDB = Firestore.firestore()
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var trackingNoTF: UITextField!
    @IBOutlet weak var carrierTF: UITextField!
    
    var name,trackingNo,carrier,date,details,location,ID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTF.text = name
        trackingNoTF.text = trackingNo
    }
    
    @IBAction func update(_ sender: Any) {
        
        requestTrackingDetails()

    }
    
    private func updateRecord() {
        
        let newName = nameTF?.text
        let newTrackingNo = trackingNoTF?.text
        let newCarrier = carrierTF?.text
        let date = self.date
        
        let tracking = [
            "trackingNo": newTrackingNo,
            "carrier": newCarrier,
            "name": newName,
            "location": location,
            "latestDetails": details,
            "date": date
        ]
        
        let userRef = firebaseDB.collection("users")
        
        userRef.document(Auth.auth().currentUser!.uid).collection("trackingRecord").document(self.ID!).updateData(tracking as [AnyHashable : Any]) { (error) in
            if error != nil {
                print("Error updating record")
            }else{
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    private func requestTrackingDetails() {

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
                            self.updateRecord()
                        }
                    }
                    
                } catch let err {
                    print("error: \(err)")
                }
            }
            
        })

        dataTask.resume()
    }

}
