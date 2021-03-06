//
//  CoreDataController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 12/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    let DEFAULT_RECORD_NAME = "default record"
    let DEFAULT_RECORD_TRACKING_NO = "default tracking no"
    let DEFAULT_RECORD_CARRIER = "default carrier"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    // Fetched results controllers
    var allRecordsFetchedResultsController: NSFetchedResultsController<TrackingRecord>?
    var recordFetchedResultsController: NSFetchedResultsController<TrackingRecord>?
    
    override init(){
        // Load the Core Data Stack
        persistentContainer = NSPersistentContainer(name:"M-Track")
        persistentContainer.loadPersistentStores(){(description, error) in
            if let error = error{
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        super.init()
        // If no records in the database we assume this is the first time the app runs
        // Create a default record in this case
        
        if fetchAllRecords().count == 0 {
        }

    }

    func saveContext(){
        if persistentContainer.viewContext.hasChanges{
            do{
                try persistentContainer.viewContext.save()
            } catch{
                fatalError("Failed to save to CoreData: \(error)")
            }
        }
    }
    
    func cleanup() {
        saveContext()
    }
    
    
    
    func addRecord(trackingNo: String, carrier: String, name: String, date: String, location:String, details:String, status:String) -> TrackingRecord {
        let record = NSEntityDescription.insertNewObject(forEntityName: "TrackingRecord", into: persistentContainer.viewContext) as! TrackingRecord
        
//        let convertedDate = Utilities.stringToDate(date)
        record.trackingNo = trackingNo
        record.carrier = carrier
        record.name = name
        record.location = location
        record.details = details
        record.strDate = date
        
        return record
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .record || listener.listenerType == .all {
            listener.onRecordChange(change: .update, record: fetchAllRecords())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // MARK: - Core data fetch requests
    func fetchAllRecords() -> [TrackingRecord]{
        if allRecordsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<TrackingRecord> = TrackingRecord.fetchRequest()
            // sort by date
            let dateSortDescriptor = NSSortDescriptor(key:"date", ascending: false)
            fetchRequest.sortDescriptors = [dateSortDescriptor]
            // initialize results controller
            allRecordsFetchedResultsController = NSFetchedResultsController<TrackingRecord>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            // set this class to be the results delegate
            allRecordsFetchedResultsController?.delegate = self
        }
        
        do{
            try allRecordsFetchedResultsController?.performFetch()
        } catch {
            print("Fetch records request failed \(error)")
        }
        
        var records = [TrackingRecord]()
        if allRecordsFetchedResultsController?.fetchedObjects != nil {
            records = (allRecordsFetchedResultsController?.fetchedObjects)!
        }
        
        return records
    }
    
    func deleteRecord(record:TrackingRecord){
        persistentContainer.viewContext.delete(record)
    }
  
}
