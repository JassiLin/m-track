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

    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    
    private let user: User
    private let channel: Channel
    
    private var messageList: [Message] = []
    private var messageListener: ListenerRegistration?
    
    var username: String = ""
    
    deinit {
      messageListener?.remove()
    }
    
    init(user: User, channel: Channel) {
        self.user = user
        self.channel = channel
        super.init(nibName: nil, bundle: nil)

        title = channel.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.user = Auth.auth().currentUser!
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
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument(source: .cache){(document, error) in
            if let doc = document {
                self.username = doc.get("username") as! String
            } else {
                print("Username not exists")
            }
        }
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
      messagesCollectionView.performBatchUpdates({
          messagesCollectionView.insertSections([messageList.count - 1])
          if messageList.count >= 2 {
              messagesCollectionView.reloadSections([messageList.count - 2])
          }
      }, completion: { [weak self] _ in
          if self?.isLastSectionVisible() == true {
              self?.messagesCollectionView.scrollToBottom(animated: true)
          }
      })
    }
    
    private func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
      guard let message = Message(document: change.document) else {
        return
      }
      
      switch change.type {
      case .added:
        insertNewMessage(message)
        
      default:
        break
      }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    // 1
    func currentSender() -> SenderType {
        return MockUser(senderId: user.uid, displayName: AppSettings.displayName)
        
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
    print(message.sender.displayName)
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont(name: "Chalkduster", size: 18.0)!,
        .foregroundColor: UIColor.dark,
        
      ]
    )
  }
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
      return isFromCurrentSender(message: message) ? .grayishViolet : .grayishRed
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
  
}
