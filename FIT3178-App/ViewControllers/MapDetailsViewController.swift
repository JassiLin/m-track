//
//  MapDetailsViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 11/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class MapDetailsViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    
    var date : String = ""
    var status: String = ""
    var location: String = ""
    var event: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = date
        statusLabel.text = status
        locationLabel.text = location
        eventLabel.text = event
        
        eventLabel.numberOfLines = 0
        eventLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
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
