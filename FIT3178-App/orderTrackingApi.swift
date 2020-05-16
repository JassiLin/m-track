//
//  orderTrackingApi.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 16/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Foundation

class orderTrackingApi: Codable {
    let data: DataClass?

    init(data: DataClass?) {
        self.data = data
    }
}

// MARK: - DataClass
class DataClass: Codable {
    let items: [Item]?

    init(items: [Item]?) {
        self.items = items
    }
}

// MARK: - Item
class Item: Codable {
    let trackingNumber, carrierCode, destinationCountry, originalCountry: String?
    let lastEvent, lastUpdateTime: String?

    enum CodingKeys: String, CodingKey {
        case trackingNumber = "tracking_number"
        case carrierCode = "carrier_code"
        case destinationCountry = "destination_country"
        case originalCountry = "original_country"
        case lastEvent = "lastEvent"
        case lastUpdateTime = "lastUpdateTime"
    }

    init(trackingNumber: String?, carrierCode: String?, destinationCountry: String?, originalCountry: String?, lastEvent: String?, lastUpdateTime: String?) {
        self.trackingNumber = trackingNumber
        self.carrierCode = carrierCode
        self.destinationCountry = destinationCountry
        self.originalCountry = originalCountry
        self.lastEvent = lastEvent
        self.lastUpdateTime = lastUpdateTime
    }
}


