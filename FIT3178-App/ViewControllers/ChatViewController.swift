//
//  ChatViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 21/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import Photos
import MessageKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    private var isSendingPhoto = false {
      didSet {
        DispatchQueue.main.async {
          self.messageInputBar.leftStackViewItems.forEach { item in
            guard let item = item as? InputBarButtonItem else { return }
            item.isEnabled = !self.isSendingPhoto
          }
        }
      }
    }
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    
    private let user: MockUser
    private let channel: Channel
    
    private var messageList: [Message] = []
    private var messageListener: ListenerRegistration?
    
    var username: String = ""
    
    deinit {
      messageListener?.remove()
    }
    
    init(user: MockUser, channel: Channel) {
        self.user = user
        self.channel = channel
        super.init(nibName: nil, bundle: nil)

        title = channel.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.user = MockUser(senderId: Auth.auth().currentUser!.uid, displayName: AppSettings.displayName)
        self.channel = Channel(name: "error")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = channel.id else {
          navigationController?.popViewController(animated: true)
          return
        }
        
        reference = db.collection(["channels", id, "thread"].joined(separator: "/"))
        
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
          guard let snapshot = querySnapshot else {
            print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
            return
          }
          
          snapshot.documentChanges.forEach { change in
            self.handleDocumentChange(change)
          }
        }
        
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .dark
        messageInputBar.sendButton.setTitleColor(.dark, for: .normal)
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .dark
        cameraItem.image = #imageLiteral(resourceName: "camera")
        cameraItem.addTarget(
          self,
          action: #selector(cameraButtonPressed),
          for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
        
        let userRef = db.collection("users").document(user.senderId)
        userRef.getDocument(source: .cache){(document, error) in
            if let doc = document {
                self.username = doc.get("username") as! String
            } else {
                print("Username not exists")
            }
        }
    }
    
    @objc private func cameraButtonPressed() {
      let picker = UIImagePickerController()
      picker.delegate = self
      
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        picker.sourceType = .camera
      } else {
        picker.sourceType = .photoLibrary
      }
      
      present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Helpers

    private func save(_ message: Message) {
      reference?.addDocument(data: message.representation) { error in
        if let e = error {
          print("Error sending message: \(e.localizedDescription)")
          return
        }
        
        self.messagesCollectionView.scrollToBottom()
      }
    }

    private func insertNewMessage(_ message: Message) {
      guard !messageList.contains(message) else {
        return
      }
      
      messageList.append(message)
      messageList.sort()
      
     // Reload last section to update header/footer labels and insert a new one
//      messagesCollectionView.performBatchUpdates({
//          messagesCollectionView.insertSections([messageList.count - 1])
//          if messageList.count >= 2 {
//              messagesCollectionView.reloadSections([messageList.count - 2])
//          }
//      }, completion: { [weak self] _ in
//          if self?.isLastSectionVisible() == true {
//              self?.messagesCollectionView.scrollToBottom(animated: true)
//          }
//      })
        let isLatestMessage = messageList.firstIndex(of: message) == (messageList.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
          DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
          }
        }
    }
    
    private func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
      guard var message = Message(document: change.document) else {
        return
      }
      
      switch change.type {
      case .added:
        if let url = message.downloadURL {
          downloadImage(at: url) { [weak self] image in
            guard let `self` = self else {
              return
            }
            guard let image = image else {
              return
            }
            
            message.image = image
            self.insertNewMessage(message)
          }
        } else {
          insertNewMessage(message)
        }
        
      default:
        break
      }
    }

    private func uploadImage(_ image: UIImage, to channel: Channel, completion: @escaping (URL?) -> Void) {
      guard let channelID = channel.id else {
        completion(nil)
        return
      }
      
      guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
        completion(nil)
        return
      }
      
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
      
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(channelID).child(imageName).putData(data, metadata: metadata) { meta, error in
            guard let metadata = meta, let path = metadata.path else {
                   completion(nil)
               return
            }
            // now we get the download url using the path
            // and the basic reference object (without child paths)
            self.getDownloadURL(from: path, completion: completion)
        }
      
    }

    private func getDownloadURL(from path: String, completion:@escaping (URL?) -> Void) {
        let firebaseStorageUrl = "gs://m-track-3d884.appspot.com/"
        let storageReference = Storage.storage().reference(forURL: firebaseStorageUrl)
        storageReference.child(path).downloadURL { (url, error) in
            completion(url)
        }
    }
    
    private func sendPhoto(_ image: UIImage) {
      isSendingPhoto = true
      
      uploadImage(image, to: channel) { [weak self] url in
        guard let `self` = self else {
          return
        }
        self.isSendingPhoto = false
        
        guard let url = url else {
          return
        }
        
        var message = Message(user: self.user, image: image)
        message.downloadURL = url
        
        self.save(message)
        self.messagesCollectionView.scrollToBottom()
      }
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

}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    // 1
    func currentSender() -> SenderType {
        return MockUser(senderId: Auth.auth().currentUser!.uid, displayName: AppSettings.displayName)
        
    }
    // 2
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

  // 3
  func messageForItem(at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageType {

    return messageList[indexPath.section]
  }

  // 4
    func cellTopLabelAttributedText(for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        let name = message.sender.displayName
        let paragraphStyle = NSMutableParagraphStyle()
        if isFromCurrentSender(message: message){
            paragraphStyle.alignment = NSTextAlignment.right
        }else{
            paragraphStyle.alignment = NSTextAlignment.left
        }
        
        return NSAttributedString(
          string: name,
          attributes: [
            .font: UIFont.preferredFont(forTextStyle: .caption1),
            .foregroundColor: UIColor.dark,
            NSAttributedString.Key.paragraphStyle:paragraphStyle
          ])
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 35
    }
    
//    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        print(">>>>>>>>>>")
//        return NSAttributedString(string: "asd", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//
//    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {

  func avatarSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    // 1
    return .zero
  }

  func footerViewSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    // 2
    return CGSize(width: 0, height: 8)
  }

  func heightForLocation(message: MessageType, at indexPath: IndexPath,
    with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

    // 3
    return 0
  }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> UIColor {
      
      // 1
      return isFromCurrentSender(message: message) ? .grayishRed : .incomingMessage
    }

    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> Bool {

      // 2
      return false
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

      let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft

      // 3
      return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let user = currentSender()
      // 1
        let message = Message(user: user as! MockUser, content: text)

      // 2
      save(message)

      // 3
      inputBar.inputTextView.text = ""
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      picker.dismiss(animated: true, completion: nil)
      
      if let asset = info[.phAsset] as? PHAsset { // 1
        let size = CGSize(width: 500, height: 500)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
          guard let image = result else {
            return
          }
          
          self.sendPhoto(image)
        }
      } else if let image = info[.originalImage] as? UIImage { // 2
        sendPhoto(image)
      }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
    }
}
