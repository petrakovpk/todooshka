//
//  StorageManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import CoreData
import FirebaseAuth
import Foundation
import RxCocoa
import RxSwift

class StorageManager {
  static let shared = StorageManager()
  
  private let disposeBag = DisposeBag()
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  public var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }
  
  func performFetchRequest<T: Persistable>(persistableObject: T, predicate: NSPredicate? = nil) -> Observable<[T]> {
    return managedContext.rx.entities(T.self, predicate: predicate)
  }
  
  func performUpdateRequest<T: Persistable>(persistableObject: T, predicate: NSPredicate? = nil) -> Observable<Void> {
    return managedContext.rx.update(persistableObject)
  }
  
  init() {
//    let currentUserPredicate = currentUser
//      .map { user -> NSPredicate in
//        if let uid = user?.uid {
//          return NSPredicate(format: "userUID == %@", uid)
//        } else {
//          return NSPredicate(format: "userUID == nil")
//        }
//      }
//
    
//    Auth.auth().rx.stateDidChange
//    // только при загрузке
//      .take(1)
//    // только если пользователь nil
//      .map { user -> NSPredicate in
//        if user == nil {
//          return NSPredicate(format: "userUID == nil")
//        } else {
//          
//        }
//        
//      }
//      .flatMapLatest { predicate -> Observable<[Kind]> in
//        self.managedContext.rx.entities(Kind.self, predicate: predicate)
//      }
//    // только если у него нет пустых задач
//      .filter { $0.isEmpty }
//      .map { _ in InitialData.kinds }
//      .flatMapLatest { kinds -> Observable<Void> in
//        self.managedContext.rx.batchUpdate(kinds)
//      }
//      .subscribe()
//      .disposed(by: disposeBag)
  }
}
