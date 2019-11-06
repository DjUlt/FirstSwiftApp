//
//  Contact.swift
//  FirstApp
//
//  Created by user on 29.10.2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class Contact: Equatable {
    var name: String
    var secondName: String
    var phoneNumber: String
    var email: String
    var image: UIImage = UIImage(systemName: "person")!
    let id = UUID().uuidString

    init(name: String, secondName: String, phoneNumber: String, email: String, image: UIImage) {
        self.name = name
        self.secondName = secondName
        self.phoneNumber = phoneNumber
        self.email = email
        self.image = image
    }
    
    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name == rhs.name &&
                lhs.secondName == rhs.secondName &&
                lhs.phoneNumber == rhs.phoneNumber &&
                lhs.email == rhs.email &&
                lhs.image == rhs.image
    }
    
    static func !=(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name != rhs.name ||
                lhs.secondName != rhs.secondName ||
                lhs.phoneNumber != rhs.phoneNumber ||
                lhs.email != rhs.email ||
                lhs.image != rhs.image
    }
}
