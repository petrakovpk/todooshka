//
//  Firebase.swift
//  Todooshka
//
//  Created by Pavel Petakov on 06.09.2022.
//

import Firebase
import FirebaseStorage

// MARK: Global constants
typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)
typealias FirestoreCompletion = ((Error?) -> Void)?
typealias StorageCompletion = ((StorageMetadata?, Error?) -> Void)
typealias AuthCompletion = ((AuthDataResult?, Error?) -> Void)


// MARK: - Root References
let DB_REF = Database.database().reference()
let FIRESTORE_REF = Firestore.firestore()
let STORAGE_REF = Storage.storage().reference()

// MARK: - DB Childs
let DB_USERS_REF = DB_REF.child("USERS")


