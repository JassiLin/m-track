//
//  Channel.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 21/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import FirebaseFirestore

struct Channel {
    
    let id: String?
    let name: String
    
    init(name: String) {
      id = nil
      self.name = name
    }
}
