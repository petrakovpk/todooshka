//
//  NetworkDatabaseService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import RxSwift
import RxCocoa
import CoreData
//
// protocol HasDatabaseNetworkServiceProtocol {
//    var networkDatabaseService: NetworkDatabaseService { get }
// }
//
// class NetworkDatabaseService {
//    
//    func removeTaskFromDatabase(task: Task, completion:  @escaping(DatabaseCompletion)) {
//        guard let user = Auth.auth().currentUser else { return }
//        TASKS_REF.child(user.uid).removeValue(completionBlock: completion)
//        
//    }
//    
//    func removeTasksFromFirebase(tasks: [Task], completion:  @escaping(DatabaseCompletion)) {
//        guard let user = Auth.auth().currentUser else { return }
//        let dictionary = Dictionary<String, Any?>(uniqueKeysWithValues: tasks.map{ ($0.UID, nil) })
//        TASKS_REF.child(user.uid).updateChildValues(dictionary, withCompletionBlock: completion)
//    }
//
// }
