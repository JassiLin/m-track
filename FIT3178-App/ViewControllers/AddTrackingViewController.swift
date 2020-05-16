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

class AddTrackingViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var listenerType: ListenerType = .record
    var date: String?
    var location: String?
    var details: String?
    
    @IBOutlet weak var trackingNoTF: UITextField!
    @IBOutlet weak var carrierTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    
    var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addTracking(_ sender: Any) {
        
        if trackingNoTF.text != "" && carrierTF.text != "" {
            requestTrackingDetails()
//            let name = nameTF?.text
//            let trackingNo = trackingNoTF?.text
//            let carrier = carrierTF?.text

//            let _ = databaseController?.addRecord(trackingNo: trackingNo!, carrier: carrier!, name: name!, date: date!, location: location!, details: details!)
//            CoreDataController().cleanup()
//            navigationController?.popViewController(animated: true)
//            return
        }
    }
    
    func saveRecord() {
        let context = appDelegate.persistentContainer.viewContext
        let newRecord = NSEntityDescription.insertNewObject(forEntityName: "TrackingRecord", into: context) as! TrackingRecord
        let name = nameTF?.text
        let trackingNo = trackingNoTF?.text
        let carrier = carrierTF?.text
        
        newRecord.name = name
        newRecord.carrier = carrier
        newRecord.trackingNo = trackingNo
        newRecord.location = location
        newRecord.details = details
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        print(date!)
//        let convertedDate = dateFormatter.date(from: date!)
//        print(convertedDate!)
//        newRecord.date = convertedDate
        
        do {
            try context.save()
            print("Added sucessfully: \(newRecord)")
            navigationController?.popViewController(animated: true)
        }
        catch {
            print("Cannot add record")
        }
    }
    
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
                    let decodedData = try decoder.decode(orderTrackingApi.self, from: data!)
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

