//
//  UserData.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 24/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import FirebaseFirestore

struct UserData {
    
    let id: String?
    let uid,username: String
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let username = data["username"] as? String,
            let uid = data["uid"] as? String
        
        else{
            return nil
        }
        
        id = document.documentID
        self.username = username
        self.uid = uid
    }
}

extension UserData: Comparable {
  
  static func == (lhs: UserData, rhs: UserData) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: UserData, rhs: UserData) -> Bool {
    return lhs.username < rhs.username
  }

}

