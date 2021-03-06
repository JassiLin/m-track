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
import Firebase
import iOSDropDown

class AddTrackingViewController: UIViewController {

    private let firebaseDB = Firestore.firestore()
    var listenerType: ListenerType = .record
    
    var date: String?
    var location: String?
    var details: String?
    var status: String?
    
    var imageUrl: String?
    var carrierList: [String:String] = [:]
    var carrierCode: String?
    
    @IBOutlet weak var trackingNoTF: UITextField!
    @IBOutlet weak var carrierTF: DropDown!
    @IBOutlet weak var nameTF: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        requestCarrierName()
        
    }
    
    func textFieldDidBeginEditing(_ textField:UITextField){
        if textField.isEqual(carrierTF){
            carrierTF.showList()
        }
    }
    
    func textFieldDidEndEditing(_ textField:UITextField){
        if textField.isEqual(carrierTF){
            carrierTF.hideList()
            
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addTracking(_ sender: Any) {
        
        if trackingNoTF.text != "" && carrierTF.text != "" {
            carrierCode = carrierList[carrierTF.text!]
            requestTrackingDetails()
        }
    }
    
    func saveRecord() {
        
        let name = (nameTF?.text != "") ? nameTF?.text : trackingNoTF?.text
        let trackingNo = trackingNoTF?.text
        let carrier = carrierList[carrierTF.text!]

        // For not logged-in user
        if Auth.auth().currentUser == nil {
            let addedRecord = databaseController?.addRecord(trackingNo: trackingNo!, carrier: carrier!, name: name!, date: date!, location: location!, details: details!,status:status!)
            if(addedRecord != nil){
                print("Added sucessfully: \(addedRecord!)")
                self.dismiss(animated: true) {
                    let main = UIStoryboard(name: "Main", bundle: nil)
                    let vc = main.instantiateViewController(identifier: "TabBar")
                    self.present(vc, animated: true, completion: nil)
                }
                
            }
        // For logged-in user
        }else{
            let tracking = [
                "trackingNo": trackingNo,
                "carrier": carrier,
                "name": name,
                "location": location!,
                "latestDetails": details!,
                "date": date!,
                "status": status!,
                "imgUrl": (imageUrl != nil) ? "https:\(imageUrl ?? "//image.flaticon.com/icons/svg/1515/1515640.svg")": ""
            ]
            
            let userRef = firebaseDB.collection("users")

            userRef.document(Auth.auth().currentUser!.uid).collection("trackingRecord").addDocument(data: tracking as [String : Any]){(error) in
                
                if error != nil {
                    print("Error saving tracking data")
                }else{
                    self.dismiss(animated: true) {
                        let main = UIStoryboard(name: "Main", bundle: nil)
                        let vc = main.instantiateViewController(identifier: "TabBar")
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
        

    }
    
    // MARK: - process API data requesting
    
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
                        self.status = listTracking.status
                        
                        DispatchQueue.main.async{
                            // Only logged in user will fetch carrier image
                            if Auth.auth().currentUser != nil{
                                self.requestCarrier()
                            }else{
                                self.saveRecord()
                            }
                        }
                    }
                    
                } catch let err {
                    print("error: \(err)")
                }
            }
            
        })

        dataTask.resume()
    }

    // Fetch carrier name
    private func requestCarrierName()  {

        let headers = [
            "x-rapidapi-host": "order-tracking.p.rapidapi.com",
            "x-rapidapi-key": "721ec697admshac6e25b8181ed51p1221c1jsn84964ace47ae",
            "content-type": "application/json"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://order-tracking.p.rapidapi.com/carriers")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                print("data: \(data!)")
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(CarrierData.self, from: data!)
                    if let listCarrier = decodedData.data {
                        for carrier in listCarrier {
                            self.carrierList[carrier.name!] = carrier.code!
                        }
                        DispatchQueue.main.async{
                            self.carrierTF.optionArray = Array(self.carrierList.keys)
                        }
                    }
                    
                } catch let err {
                    print("error: \(err)")
                }
            }
        })

        dataTask.resume()
    }
    
    
    // Fetch carrier image
    private func requestCarrier()  {

        let headers = [
            "x-rapidapi-host": "order-tracking.p.rapidapi.com",
            "x-rapidapi-key": "721ec697admshac6e25b8181ed51p1221c1jsn84964ace47ae",
            "content-type": "application/json"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://order-tracking.p.rapidapi.com/carriers")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                print("data: \(data!)")
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(CarrierData.self, from: data!)
                    if let listCarrier = decodedData.data {
                        print("listCarrier: \(listCarrier.count) >>>")
                        for carrier in listCarrier {
                            if carrier.code == self.carrierCode{
                                self.imageUrl = carrier.picture
                            }
                        }

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

}

