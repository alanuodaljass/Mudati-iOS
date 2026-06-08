//
//  LocalUser.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 17/12/1447 AH.
//

import Foundation

enum LocalUser {
    static var id: String {
        let key = "mudati_local_user_id"
        
        if let saved = UserDefaults.standard.string(forKey: key) {
            return saved
        }
        
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
}
