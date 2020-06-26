//
//  FirebaseController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 13/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Foundation
import Firebase

class FirebaseController {
    
    private let storage = Storage.storage().reference()

    
    static func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
      let ref = Storage.storage().reference(forURL: url.absoluteString)
      let megaByte = Int64(1 * 1024 * 1024)
      
      ref.getData(maxSize: megaByte) { data, error in
        guard let imageData = data else {
          completion(nil)
          return
        }
        
        completion(UIImage(data: imageData))
      }
    }
    
    
    
    
    func getDownloadURL(from path: String, completion:@escaping (URL?) -> Void) {
        let firebaseStorageUrl = "gs://m-track-3d884.appspot.com/"
        let storageReference = Storage.storage().reference(forURL: firebaseStorageUrl)
        storageReference.child(path).downloadURL { (url, error) in
            completion(url)
        }
    }
    
    
}
