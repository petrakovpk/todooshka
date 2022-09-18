//
//  TasksService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

import CoreData
import Firebase
import RxSwift
import RxCocoa
import YandexMobileMetrica

protocol HasDataService {
    var dataService: DataService { get }
}

class DataService {

  // MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let disposeBag = DisposeBag()
  let firebaseTasks: Driver<[Task]>
  let firebaseKindsOfTask: Driver<[KindOfTask]>
  let kindsOfTask: Driver<[KindOfTask]>
  let tasks: Driver<[Task]>

  // MARK: - Init
  init() {
    
    let user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
      .compactMap{ $0 }
    
    let context = self.appDelegate
      .persistentContainer
      .viewContext

    firebaseTasks = user
      .asObservable()
      .flatMapLatest({ user -> Observable<DataSnapshot> in
        DB_USERS_REF.child(user.uid).child("TASKS").rx.observeEvent(.value)
      }).compactMap{ $0.children.allObjects as? [DataSnapshot] }
      .map({ $0.compactMap { Task(snapshot: $0) } })
      .asDriver(onErrorJustReturn: [])
    
    firebaseKindsOfTask = user
      .asObservable()
      .flatMapLatest({ user -> Observable<DataSnapshot>  in
        DB_USERS_REF.child(user.uid).child("KINDSOFTASK").rx.observeEvent(.value)
      }).compactMap{ $0.children.allObjects as? [DataSnapshot] }
      .map({ $0.compactMap { KindOfTask(snapshot: $0) } })
      .asDriver(onErrorJustReturn: [])
    
    kindsOfTask = context
      .rx
      .entities(KindOfTask.self)
      .map({ $0.sorted{ $0.index < $1.index } })
      .asDriver(onErrorJustReturn: [])
    
    tasks = context
      .rx
      .entities(Task.self)
      .map({ $0.sorted{ $0.created < $1.created } })
      .asDriver(onErrorJustReturn: [])

    // drive
    tasks.drive().disposed(by: disposeBag)
    firebaseTasks.drive().disposed(by: disposeBag)
    
    // save to firebase
    Observable
      .combineLatest(tasks.asObservable(), firebaseTasks.asObservable()) { phoneTasks, firebaseTasks -> [Task] in
        phoneTasks.filter { phoneTask in firebaseTasks.contains{ $0 == phoneTask } == false }
      }
      .flatMapLatest({  Observable.from($0) })
      .withLatestFrom(user) { task, user in
        DB_USERS_REF.child(user.uid).child("TASKS").child(task.UID).updateChildValues(task.data)
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
    
    Observable
      .combineLatest(kindsOfTask.asObservable(), firebaseKindsOfTask.asObservable()) { phoneKindsOfTask, firebaseKindsOfTask -> [KindOfTask] in
        phoneKindsOfTask.filter { phoneKindOfTask in firebaseKindsOfTask.contains{ $0 == phoneKindOfTask } == false }
      }
      .flatMapLatest({  Observable.from($0) })
      .withLatestFrom(user) { kindOfTask, user in
        DB_USERS_REF.child(user.uid).child("KINDSOFTASK").child(kindOfTask.UID).updateChildValues(kindOfTask.data)
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
    
    // Init
    kindsOfTask
      .filter({ $0.isEmpty })
      .map { _ -> [KindOfTask] in
        [
          KindOfTask.Standart.Sport,
          KindOfTask.Standart.Fashion,
          KindOfTask.Standart.Cook,
          KindOfTask.Standart.Business,
          KindOfTask.Standart.Student,
          KindOfTask.Standart.Empty,
          KindOfTask.Standart.Kid,
          KindOfTask.Standart.Home,
          KindOfTask.Standart.Love,
          KindOfTask.Standart.Pet
        ]
      }
      .asObservable()
      .flatMapLatest({  Observable.from($0) })
      .flatMapLatest { kindOfTask in
        context.rx.update(kindOfTask)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
  }
}
