//
//  Message.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 29/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Firebase
import MessageKit
import FirebaseFirestore

struct MockUser: SenderType {
    
    var senderId: String
    var displayName: String
    
}

struct Message: MessageType {
    var messageId: String
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind

    var user: MockUser

    var content: String
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    private init(kind: MessageKind, user: MockUser, messageId: String, date: Date, content: String) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.content = content
    }
}

extension Message: DatabaseRepresentation {
  
  var representation: [String : Any] {
    var rep: [String : Any] = [
      "created": sentDate,
      "senderID": user.senderId,
      "senderName": user.displayName
    ]
    
    if let url = downloadURL {
      rep["url"] = url.absoluteString
    } else {
      rep["content"] = content
    }
    
    return rep
  }
  
}

extension Message: Comparable {
  
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.messageId == rhs.messageId
  }
  
  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }
  
}

