//
//  MapDetailsViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 11/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class MapDetailsViewController: UIViewController{

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    
    
//    @IBOutlet var infoTableView: UITableView!
    
    var date : String?
    var status: String?
    var location: String?
    var event: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        infoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        infoTableView.delegate = self
//        infoTableView.dataSource = self
        
        dateLabel.text = date
        statusLabel.text = status
        locationLabel.text = location
        eventLabel.text = event
        
        eventLabel.numberOfLines = 0
        eventLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        4
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = date
//        return cell
//    }



}
