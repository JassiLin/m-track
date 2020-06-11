//
//  MapFunctionViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 11/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class MapFunctionViewController: UIViewController {

    @IBOutlet weak var mapSegment: UISegmentedControl!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var mapView: UIView!
    
    var date : String = ""
    var status: String = ""
    var location: String = ""
    var event: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailsView.isHidden = false
        mapView.isHidden = true
    }
    
    @IBAction func mapSegmentTapped(_ sender: Any) {
        switch mapSegment.selectedSegmentIndex
        {
        case 0:
            detailsView.isHidden = false
            mapView.isHidden = true
        case 1:
            detailsView.isHidden = true
            mapView.isHidden = false
        default:
            break;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedToDetails"){
            let vc = segue.destination as! MapDetailsViewController
            vc.date = date
            vc.status = status
            vc.location = location
            vc.event = event
        }
        if (segue.identifier == "embedToMap"){
            let vc = segue.destination as! MapViewController
            vc.location = location
        }
    }
    

}
