//
//  Firebase.swift
//  Todooshka
//
//  Created by Pavel Petakov on 06.09.2022.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

// MARK: Global constants
typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)
typealias FirestoreCompletion = ((Error?) -> Void)?
typealias AuthCompletion = ((AuthDataResult?, Error?) -> Void)

// MARK: - Root References
let dbRef = Database.database().reference()
let dbUserRef = dbRef.child("USERS")
let storageRef = Storage.storage().reference()
let firestoreRef = Firestore.firestore()

let serverURL = "http://127.0.0.1:5050/"
