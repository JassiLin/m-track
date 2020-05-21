//
//  HomeViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 12/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet weak var tryWithoutLoginBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // If user is already logged in, change buttons
        if Auth.auth().currentUser != nil {
            tryWithoutLoginBtn.setTitle("Access your parcel tracking list", for: .normal)
            loginBtn.isHidden = true
        }
    }
    
    func addNavBarImage(){

//        let navController = navigationController!
//
//        let image = UIImage(named: "headerImage")
//        let imageView = UIImageView(image:image)
//
//        let bannerWidth = navController.navigationBar.frame.size.width
//        let bannerHeight = navController.navigationBar.frame.size.height
//
//        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
//        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
//
//        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
//        imageView.contentMode = .scaleAspectFit
//
//        navigationItem.titleView = imageView
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
