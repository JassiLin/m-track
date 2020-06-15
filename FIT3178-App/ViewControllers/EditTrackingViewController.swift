//
//  EditTrackingViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 11/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class EditTrackingViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var trackingNoTF: UITextField!
    @IBOutlet weak var carrierTF: UITextField!
    
    var name,trackingNo,carrier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTF.text = name
        trackingNoTF.text = trackingNo
    }
    
    @IBAction func update(_ sender: Any) {
        
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
