//
//  floatyButton.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 27/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import Floaty

extension UITableViewController {
    
    func addFloatyBtn(){
        let floatyBtn = Floaty()
        let tracking = UIStoryboard(name: "Tracking", bundle: nil)
        
        floatyBtn.addItem("Add tracking", icon: UIImage(named: "add")!, handler: {
            _ in
            let vc = tracking.instantiateViewController(withIdentifier: "AddTracking")
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            
        })
       
        
        
        floatyBtn.paddingY = 100
        floatyBtn.sticky = true
        floatyBtn.respondsToKeyboard = false
        floatyBtn.friendlyTap = true
        floatyBtn.plusColor = .white
        floatyBtn.buttonColor = .grayishRed

        self.navigationController?.view.addSubview(floatyBtn)
    }
}
