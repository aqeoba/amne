//
//  DATABASEMANAGER.swift
//  amne
//
//  Created by eternal on 07.07.2021.
//

import Foundation
import FirebaseDatabase

final class DataBaseManager {
    
    
    static let shared = DataBaseManager()
    
    private let database = Database.database().reference()
    
    
}

// ACCOUNT MANAGEMENT

extension DataBaseManager{
    
    public func userExistance(with logIn: String, completion: @escaping ((Bool) -> Void)) {
        
        var safeLogin = logIn.replacingOccurrences(of: ".", with: "-")
        safeLogin = safeLogin.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeLogin).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
        
    }
    
    /// new user in db
    public func insertUser(with user: chatAppUser) {
        database.child(user.safeLogin).setValue([
            "nickName" : user.nickName
        ])
    }
}

struct  chatAppUser{
    let nickName: String
    let logIn: String
//    let profilePicURL: String
    
    var safeLogin: String {
        var safeLogin = logIn.replacingOccurrences(of: ".", with: "-")
        safeLogin = safeLogin.replacingOccurrences(of: "@", with: "-")
        return safeLogin
    }
}
