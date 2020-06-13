//
//  TrackingDetailsTableViewCell.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class TrackingDetailsTableViewCell: UITableViewCell {

    // Parcel tracking details
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var desciptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // Record info
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var trackingNoLabel: UILabel!
    @IBOutlet weak var lastStatusLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
