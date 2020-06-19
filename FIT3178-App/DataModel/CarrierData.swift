//
//  Carrier.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 19/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import FirebaseFirestore

class CarrierData: Codable {
    let data: [Carrier]?

    init(data: [Carrier]?) {
        self.data = data
    }
}

// MARK: - Carrier
class Carrier: Codable {
    let name, code, phone: String?
    let homepage: String?
    let type, picture: String?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case code = "code"
        case phone = "phone"
        case homepage = "homepage"
        case type = "type"
        case picture = "picture"
    }
    init(name: String?, code: String?, phone: String?, homepage: String?, type: String?, picture: String?) {
        self.name = name
        self.code = code
        self.phone = phone
        self.homepage = homepage
        self.type = type
        self.picture = picture
    }
}



// MARK: - URLSession response handlers

//extension URLSession {
//    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        return self.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                completionHandler(nil, response, error)
//                return
//            }
//            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
//        }
//    }
//
//    func carrierTask(with url: URL, completionHandler: @escaping (CarrierData?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        return self.codableTask(with: url, completionHandler: completionHandler)
//    }
//}

