//
//  TrackingRecord+CoreDataProperties.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 12/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//
//

import Foundation
import CoreData


extension TrackingRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackingRecord> {
        return NSFetchRequest<TrackingRecord>(entityName: "TrackingRecord")
    }

    @NSManaged public var trackingNo: String?
    @NSManaged public var carrier: String?
    @NSManaged public var name: String?
    @NSManaged public var details: String?
    @NSManaged public var date: Date?
    @NSManaged public var location: String?

}
