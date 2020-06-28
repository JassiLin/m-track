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
import iOSDropDown
import CoreData

class EditTrackingViewController: UIViewController {

    private let firebaseDB = Firestore.firestore()
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var trackingNoTF: UITextField!
    @IBOutlet weak var carrierTF: DropDown!
    
    var name,trackingNo,carrier,date,details,location,ID,status: String?
    var carrierList: [String:String] = [:]
    var carrierCode, currentCarrierName: String?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTF.text = name
        trackingNoTF.text = trackingNo
        
        requestCarrierName()
        carrierTF.text = currentCarrierName
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
    
    @IBAction func update(_ sender: Any) {

        if trackingNoTF.text != "" && carrierTF.text != "" {
            carrierCode = (carrierList[carrierTF.text!] != nil) ? carrierList[carrierTF.text!] : carrier
            requestTrackingDetails()
        }
        
    }
    
    private func updateRecord() {
        
        carrierCode = (carrierList[carrierTF.text!] != nil) ? carrierList[carrierTF.text!] : carrier
        let newName = (nameTF?.text != "") ? nameTF?.text : trackingNoTF?.text
        let newTrackingNo = trackingNoTF?.text
        let newCarrier = carrierCode
        let date = self.date
        
        let tracking = [
            "trackingNo": newTrackingNo,
            "carrier": newCarrier,
            "name": newName,
            "location": location,
            "latestDetails": details,
            "date": date,
            "status": status
        ]
        if Auth.auth().currentUser != nil{
            let userRef = firebaseDB.collection("users")
            
            userRef.document(Auth.auth().currentUser!.uid).collection("trackingRecord").document(self.ID!).updateData(tracking as [AnyHashable : Any]) { (error) in
                if error != nil {
                    print("Error updating record")
                }else{
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            let app = UIApplication.shared.delegate as! AppDelegate
            let contexts = app.persistentContainer.viewContext
            let entityName = "TrackingRecord"
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: contexts)
            fetchRequest.entity = entity
            let predicate = NSPredicate.init(format: "trackingNo = %@", trackingNo!)
//            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName:"TrackingRecord")
            fetchRequest.predicate = predicate
            do{
                let result = try contexts.fetch(fetchRequest)
                print(result)
                let objectUpdate = result[0] as! NSManagedObject
                objectUpdate.setValue(newTrackingNo, forKey:"trackingNo")
                objectUpdate.setValue(newCarrier, forKey:"carrier")
                objectUpdate.setValue(newName, forKey:"name")
                do{
                    try contexts.save()
                }catch{
                    print(error)
                }
            }catch{
                print(error)
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
            "carrier_code": carrier!
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
                            if self.carrier == carrier.code{
                                self.currentCarrierName = carrier.name
                            }
                            self.carrierList[carrier.name!] = carrier.code!
                        }
                        DispatchQueue.main.async{
                            self.carrierTF.text = self.currentCarrierName
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
    
}
