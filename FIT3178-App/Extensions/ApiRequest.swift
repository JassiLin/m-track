//
//  ApiRequest.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 16/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Foundation

//func requestTrackingDetails() {
//
//    let headers = [
//        "x-rapidapi-host": "order-tracking.p.rapidapi.com",
//        "x-rapidapi-key": "721ec697admshac6e25b8181ed51p1221c1jsn84964ace47ae",
//        "content-type": "application/json",
//        "accept": "application/json"
//    ]
//    let parameters = [
//        "tracking_number": trackingNo,
//        "carrier_code": carrierCode
//    ] as [String : Any]
//
//    let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//
//    let request = NSMutableURLRequest(url: NSURL(string: "https://order-tracking.p.rapidapi.com/trackings/realtime")! as URL,
//                                            cachePolicy: .useProtocolCachePolicy,
//                                        timeoutInterval: 10.0)
//    request.httpMethod = "POST"
//    request.allHTTPHeaderFields = headers
//    request.httpBody = postData! as Data
//
//    let session = URLSession.shared
//    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//        if (error != nil) {
//            print("error: \(error!)")
//        } else {
//            let httpResponse = response as? HTTPURLResponse
//            print(httpResponse!)
//            print("data: \(data!)")
//            do {
//                let decoder = JSONDecoder()
//                let decodedData = try decoder.decode(trackingData.self, from: data!)
//                print("decodeData: \(decodedData)")
//                if let listTracking = decodedData.data?.items?.first {
//                    print("listTracking: \(listTracking)")
//
//                    DispatchQueue.main.async{
//                        return
//                    }
//                }
//
//            } catch let err {
//                print("error: \(err)")
//            }
//        }
//
//    })
//
//    dataTask.resume()
//}
