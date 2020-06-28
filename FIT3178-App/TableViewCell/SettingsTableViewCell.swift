//
//  SettingsTableViewCell.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 21/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewCell: UITableViewCell {


    @IBAction func darkModeSwitch(_ sender: UISwitch) {
        if sender.isOn {
           window!.overrideUserInterfaceStyle = .dark
            AppSettings.darkMode = 1
       }
       else {
           window!.overrideUserInterfaceStyle = .light
            AppSettings.darkMode = 0
       }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
