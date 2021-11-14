//
//  ChatAppModel.swift
//  Messenger
//
//  Created by Артем on 12.11.2021.
//

import Foundation

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String {
        let safeEmail = emailAddress.makeFirebaseString()
        return safeEmail
    }
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
