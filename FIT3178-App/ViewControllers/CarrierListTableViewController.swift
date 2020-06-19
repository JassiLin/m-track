//
//  CarrierListTableViewController.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import UIKit

class CarrierListTableViewController: UITableViewController {

    var pic: [String] = []
    var name: [String] = []
    var homepage: [String] = []
    var phone: [String] = []
    var type: [String] = []
    var count: Int = 0
//    var counts: [Int] = [0,0]
     
    override func viewDidLoad() {
        super.viewDidLoad()
        requestCarrier()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func requestCarrier()  {

        let headers = [
            "x-rapidapi-host": "order-tracking.p.rapidapi.com",
            "x-rapidapi-key": "721ec697admshac6e25b8181ed51p1221c1jsn84964ace47ae",
            "content-type": "application/json"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://order-tracking.p.rapidapi.com/carriers")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
                print("data: \(data!)")
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(CarrierData.self, from: data!)
                    print("decodeData: \(decodedData)")
                    if let listCarrier = decodedData.data {
                        print("listCarrier: \(listCarrier.count)")
                        self.count = listCarrier.count
                        for carrier in listCarrier {
                            self.pic.append(carrier.picture!)
                            self.name.append(carrier.name!)
                            self.homepage.append(carrier.homepage!)
                            self.phone.append(carrier.phone!)
                            self.type.append(carrier.type!)
                            
                        }
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }
                    }
                    
                } catch let err {
                    print("error: \(err)")
                }
            }
        })

        dataTask.resume()
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

// MARK: - Table view data source

extension CarrierListTableViewController{
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return name[section]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let button = UIButton(type:.system)
        button.setTitle(name[section], for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
//        button.frame = CGRect(x: 160, y: 0, width: 20, height: view.frame.size.height)

//        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        button.tag = section

        return button
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "carrierCell", for: indexPath) as! CarrierListTableViewCell
        cell.phoneLabel.text = phone[indexPath.section]
        cell.homepageLabel.text = homepage[indexPath.section]
        cell.typeLabel.text = type[indexPath.section]

        return cell
    }
    
    @objc func handleExpandClose(button: UIButton) {
        
        let section = 0
        // Close section by deleting rows
        var indexPaths = [IndexPath]()

        let indexPath = IndexPath(row: 0, section: section)
        indexPaths.append(indexPath)
        
        phone.remove(at: section)
        homepage.remove(at: section)
        type.remove(at: section)
        tableView.deleteRows(at: indexPaths, with: .fade)
//        tableView.reloadData()
    }
    
}
