//
//  Firebase.swift
//  Todooshka
//
//  Created by Pavel Petakov on 06.09.2022.
//

import Firebase

// MARK: Global constants
typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)
typealias FirestoreCompletion = ((Error?) -> Void)?
typealias AuthCompletion = ((AuthDataResult?, Error?) -> Void)


// MARK: - Root References
let DB_REF = Database.database().reference()

// MARK: - DB Childs
let DB_USERS_REF = DB_REF.child("USERS")


