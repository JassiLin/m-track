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
    var id: String?
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind {
        if let image = image {
            return .photo(image as! MediaItem)
        } else {
            return .text(content)
        }
    }

    var messageId: String {
      return id ?? UUID().uuidString
    }
    
    var user: MockUser

    var content: String
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    init(user: MockUser, content: String) {
        self.user = user
        id = nil
        sentDate = Date()
        self.content = content
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let sentDate = data["created"] as? Timestamp else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
      
        id = document.documentID
        
        self.sentDate = sentDate.dateValue()
        
        user = MockUser(senderId: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
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

