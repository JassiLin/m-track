//
//  TrackingDetailsTableViewCell.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class TrackingDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var desciptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
