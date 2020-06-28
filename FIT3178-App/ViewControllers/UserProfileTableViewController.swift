//
//  UserProfileTableViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 25/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import Firebase
import Photos

class UserProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!

    var userRef: CollectionReference?
    private let firebaseDB = Firestore.firestore()
    private let storage = Storage.storage().reference()
    var user: UserData?
    var imageUrl: URL?
    var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            userRef = firebaseDB.collection("users")
             userRef!.document(Auth.auth().currentUser!.uid).addSnapshotListener { (snapshot, err) in
                 self.nameTextField.text = snapshot?.get("username") as? String
                 self.imageUrl = URL(string:snapshot?.get("imageUrl") as! String)
                 self.imageName = snapshot?.get("imageName") as? String
                 
                 if let image = self.loadImageData(filename: self.imageName!) {
                     self.imageView.image = image
                 } else{
                     if let url = self.imageUrl {
                         self.downloadImage(at: url) { [weak self] image in
                         guard let `self` = self else {
                           return
                         }
                         guard let image = image else {
                           return
                         }
                         self.imageView.image = image
                       }
                     }
                 }

             }
             
             imageView.isUserInteractionEnabled = true
             let tap = UITapGestureRecognizer(target:self, action: #selector(imagePressed))
             imageView.addGestureRecognizer(tap)
        }
 
    }

    private func loadImageData(filename:String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage (contentsOfFile: imageURL.path)
        return image
    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
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
    
    @objc private func imagePressed() {
      let picker = UIImagePickerController()
      picker.delegate = self
      
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        picker.sourceType = .camera
      } else {
        picker.sourceType = .photoLibrary
      }
      
      present(picker, animated: true, completion: nil)
    }
    
    @IBAction func saveUser(_ sender: Any) {

        if nameTextField.text != AppSettings.displayName{
            AppSettings.displayName = nameTextField.text
        }
        sendPhoto(imageView.image!)
    
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let photo = imageView.image,
//        let name = nameTextField.text
////        let position = positionTextField.text,
////        let email = emailTextField.text,
////        let phone = phoneTextField.text
//        {
////            contact = Contact.init(photo: photo, name: name, position: position, email: email, phone: phone)
//        }
//    }
    
}

extension UserProfileTableViewController {
    
    // select image from picker and display it in imageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      picker.dismiss(animated: true, completion: nil)
      
      if let asset = info[.phAsset] as? PHAsset { // 1
        let size = CGSize(width: 300, height: 300)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
          guard let image = result else {
            return
          }
            self.imageView.image = image
        }
      } else if let image = info[.originalImage] as? UIImage { // 2
        self.imageView.image = image
        imageView?.layer.cornerRadius = (imageView?.frame.size.width ?? 0.0) / 2
        imageView?.clipsToBounds = true
      }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
    }
    
    private func sendPhoto(_ image: UIImage) {
      
        // Check photos are changed or not
        uploadImage(image) { [weak self] url in
        guard let `self` = self else {
          return
        }
        
        guard let url = url else {
          return
        }
        self.userRef!.document(Auth.auth().currentUser!.uid).updateData(["imageUrl":"\(url)"])
            
            
        let newUser = [
            "username": self.nameTextField.text,
            "imageName": self.imageName
            ]
            self.userRef!.document(Auth.auth().currentUser!.uid).updateData(newUser as [AnyHashable : Any])

            self.dismiss(animated: true, completion: nil)
        
      }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        
      guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
        completion(nil)
        return
      }
      
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
      
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(Auth.auth().currentUser!.uid).child(imageName).putData(data, metadata: metadata) { meta, error in
            guard let metadata = meta, let path = metadata.path else {
                   completion(nil)
               return
            }
            // now we get the download url using the path
            // and the basic reference object (without child paths)
            self.imageName = imageName
            self.getDownloadURL(from: path, completion: completion)
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(imageName)
        
        do{
            try data.write(to: fileURL)
        }catch{
            print("error saving to local")
        }
    }
    
    private func getDownloadURL(from path: String, completion:@escaping (URL?) -> Void) {
        let firebaseStorageUrl = "gs://m-track-3d884.appspot.com/"
        let storageReference = Storage.storage().reference(forURL: firebaseStorageUrl)
        storageReference.child(path).downloadURL { (url, error) in
            completion(url)
        }
    }
}
