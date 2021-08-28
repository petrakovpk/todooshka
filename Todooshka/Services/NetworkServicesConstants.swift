//
//  NetworkServicesConstants.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 18.05.2021.
//

import Firebase
import RxSwift
import RxCocoa

// MARK: - Global Enums
enum TodooshkaError: Error {
    case error(String)
}


// MARK: Global constants
typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)
typealias FirestoreCompletion = ((Error?) -> Void)?
typealias StorageCompletion = ((StorageMetadata?, Error?) -> Void)

typealias TodooshkaCompletion = ((Error?) -> Void)

// MARK: - Root References
let DB_REF = Database.database().reference()
let FIRESTORE_REF = Firestore.firestore()
let STORAGE_REF = Storage.storage().reference()

//MARK: - DB Childs
let USER_REF = DB_REF.child("users")
let TASKS_REF = DB_REF.child("tasks")
let TASK_TYPES_REF = DB_REF.child("taskTypes")

