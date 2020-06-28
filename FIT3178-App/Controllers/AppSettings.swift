//
//  AppSettings.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 29/5/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Foundation

final class AppSettings {
  
    private enum SettingKey: String {
        case displayName
        case imageUrl
        case darkMode
    }
  
    static var displayName: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingKey.displayName.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKey.displayName.rawValue

            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var imageUrl: URL! {
        get {
            return UserDefaults.standard.url(forKey: SettingKey.imageUrl.rawValue)
        }
        set{
            let defaults = UserDefaults.standard
            let key = SettingKey.imageUrl.rawValue

            if let imageUrl = newValue {
                defaults.set(imageUrl, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var darkMode: Int! {
        get {
            return UserDefaults.standard.integer(forKey:"darkMode")
        }
        set {
            let defaults = UserDefaults.standard
            let key = "darkMode"

            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
  
}
