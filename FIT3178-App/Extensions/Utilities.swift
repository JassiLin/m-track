//
//  Utilities.swift
//  FIT3178-App
//
//  Created by Jingmei Lin on 8/6/20.
//  Copyright © 2020 Jingmei Lin. All rights reserved.
//

import Foundation

class Utilities {
    
    static func dateToString(_ date:Date, dateFormat:String = "dd-MM-yyyy HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "en_AU")
        formatter.dateFormat = dateFormat
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    static func stringToDate(_ string: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss")-> Date{
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "en_AU")
        formatter.dateFormat = dateFormat
        let date = formatter.date(from: string)
        return date!
    }
    
    static func validateEmail(_ enteredEmail:String) -> Bool {

        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)

    }
    
    // Password validation:
    // legnth >= 8
    // lowercase, uppercase, decimal digits & characters (optional)
    static func validatePassword(_ password: String) -> Bool {
        var lowerCaseLetter: Bool = false
        var upperCaseLetter: Bool = false
        var digit: Bool = false
        var specialCharacter: Bool = false

        if password.count  >= 8 {
            for char in password.unicodeScalars {
                if !lowerCaseLetter {
                    lowerCaseLetter = CharacterSet.lowercaseLetters.contains(char)
                }
                if !upperCaseLetter {
                    upperCaseLetter = CharacterSet.uppercaseLetters.contains(char)
                }
                if !digit {
                    digit = CharacterSet.decimalDigits.contains(char)
                }
                if !specialCharacter {
                    specialCharacter = CharacterSet.punctuationCharacters.contains(char)
                }
            }
            if specialCharacter || (digit && lowerCaseLetter && upperCaseLetter) {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    // Password should include lowercase letters and special characters
    static func isPasswordValid(_ password: String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
}
