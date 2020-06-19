//
//  CarrierListTableViewCell.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class CarrierListTableViewCell: UITableViewCell {

    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var homepageLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
