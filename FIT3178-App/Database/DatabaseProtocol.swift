//
//  DatabaseProtocol.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 12/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case record
    case all
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType {get set}
    func onRecordChange(change:DatabaseChange, record:[TrackingRecord])
}

protocol DatabaseProtocol: AnyObject{
//    var defaultRecord: TrackingRecord {get}
    func cleanup()
    func addRecord(trackingNo:String, carrier:String, name:String, date:String, location:String, details:String, status:String)->TrackingRecord
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
