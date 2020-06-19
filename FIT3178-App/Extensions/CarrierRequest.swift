//
//  CarrierRequest.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Foundation

func requestCarrierData() -> Data {
    
    var dataReturned: Data?
    
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
            dataReturned = data
        }
    })

    dataTask.resume()
    return dataReturned ?? Data()
}
