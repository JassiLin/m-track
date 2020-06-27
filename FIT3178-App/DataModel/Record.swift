//
//  Record.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 9/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import FirebaseFirestore

struct Record {
    
    let id: String?
    let carrier, latestDetails, location, name, trackingNo, date: String
    // use for tracking image download
    var downloadTaskIdentifier: Int?
    var imageView: UIImage?
    let imgUrl: String?
//    init(name:String, trackingNo:String, location:String, latestDetails:String, carrier:String){
//        id = nil
//        self.name = name
//        self.trackingNo = trackingNo
//        self.location = location
//        self.latestDetails = latestDetails
//        self.carrier = carrier
//    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String,
            let trackingNo = data["trackingNo"] as? String,
            let location = data["location"] as? String,
            let latestDetails = data["latestDetails"] as? String,
            let carrier = data["carrier"] as? String,
            let date = data["date"] as? String,
            let imgUrl = data["imgUrl"] as? String
        else {
            return nil
        }
        
        id = document.documentID
        self.name = name
        self.trackingNo = trackingNo
        self.location = location
        self.latestDetails = latestDetails
        self.carrier = carrier
        self.date = date
        self.imgUrl = imgUrl
    }
}

extension Record: Comparable {
  
  static func == (lhs: Record, rhs: Record) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Record, rhs: Record) -> Bool {
    return lhs.name < rhs.name
  }

}

