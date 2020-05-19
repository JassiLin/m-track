//
//  orderTrackingApi.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 16/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Foundation

class trackingData: Codable {
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
    let status, lastEvent, lastUpdateTime: String?
    let originInfo: OriginInfo?
    
    enum CodingKeys: String, CodingKey {
        case trackingNumber = "tracking_number"
        case carrierCode = "carrier_code"
        case destinationCountry = "destination_country"
        case originalCountry = "original_country"
        case status = "status"
        case lastEvent = "lastEvent"
        case lastUpdateTime = "lastUpdateTime"
        case originInfo = "origin_info"
    }

    init(trackingNumber: String?, carrierCode: String?, destinationCountry: String?, originalCountry: String?, status: String?, lastEvent: String?, lastUpdateTime: String?, originInfo: OriginInfo?) {
        self.trackingNumber = trackingNumber
        self.carrierCode = carrierCode
        self.destinationCountry = destinationCountry
        self.originalCountry = originalCountry
        self.status = status
        self.lastEvent = lastEvent
        self.lastUpdateTime = lastUpdateTime
        self.originInfo = originInfo
    }
}

// MARK: - OriginInfo
class OriginInfo: Codable {
    let itemReceived: String?
    let weblink: String?
    let trackinfo: [Trackinfo]?

    enum CodingKeys: String, CodingKey {
        case itemReceived = "ItemReceived"
        case weblink, trackinfo
    }

    init(itemReceived: String?, weblink: String?, trackinginfo: [Trackinfo]?) {
        self.itemReceived = itemReceived
        self.weblink = weblink
        self.trackinfo = trackinginfo
    }
}

// MARK: - Trackinginfo
class Trackinfo: Codable {
    let date, statusDescription, details, checkpointStatus: String?

    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case statusDescription = "StatusDescription"
        case details = "Details"
        case checkpointStatus = "checkpoint_status"
    }

    init(date: String?, statusDescription: String?, details: String?, checkpointStatus: String?) {
        self.date = date
        self.statusDescription = statusDescription
        self.details = details
        self.checkpointStatus = checkpointStatus
    }
}


