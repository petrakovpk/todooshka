//
//  FunViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 18.11.2022.
//

import CoreData
import Firebase
import RxFlow
import RxSwift
import RxCocoa

class FunViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let task = PublishRelay<Task>()
  //private let loadMoreDataTrigger = BehaviorRelay<Void>(value: ())
  
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private var managedContext: NSManagedObjectContext { appDelegate.persistentContainer.viewContext }

  struct Input {
//    let authorImageClickTrigger: Driver<Void>
//    let authorNameClickTrigger: Driver<Void>
//    let taskTextClickTrigger: Driver<Void>
    let badButtonClickTrigger: Driver<Void>
    let goodButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
//    let openAuthorPage: Driver<Void>
//    let openTaskPage: Driver<Void>
    let nextTask: Driver<Task>
    let nextTaskImage: Driver<UIImage>
    let handleReaction: Driver<Void>
    let dataSource: Driver<[FunSection]>
  }

  // MARK: - Init
  init(services: AppServices) {
    self.services = services
  }

  func transform(input: Input) -> Output {
    let task = task
      .asDriverOnErrorJustComplete()

//    let openAuthorPage = Driver.of(
//      input.authorNameClickTrigger,
//      input.authorImageClickTrigger
//    )
//      .merge()
//
//    let openTaskPage = input.taskTextClickTrigger

    let getNextTaskTrigger = Driver.of(
      input.badButtonClickTrigger,
      input.goodButtonClickTrigger
    )
      .merge()
      .startWith(())
    
    let nextTask = getNextTaskTrigger
      .asObservable()
      .flatMapLatest {
        dbRef.child("PUBLISHED_TASKS").rx.observeSingleEvent(.value)
      }
      .compactMap { snapshot -> Task? in
        snapshot
          .children
          .compactMap { $0 as? DataSnapshot }
          .compactMap { snapshot -> Task? in
            Task(snapshot: snapshot)
          }
          .randomElement()
      }
      .asDriverOnErrorJustComplete()
      .debug()
      .do { task in
        self.task.accept(task)
      }
    
    let nextTaskImage = nextTask
      .debug()
      .compactMap {
        $0.imageUID
      }
      .asObservable()
      .debug()
      .flatMapLatest { imageUID -> Observable<Data> in
        storageRef.child("PUBLISHED_TASKS").child(imageUID).rx.getData(maxSize: 100 * 1024 * 1024)
      }
      .debug()
      .compactMap {
        UIImage(data: $0)
      }
      .debug()
      .asDriver(onErrorJustReturn: UIImage())
    
        
    let badReaction = input.goodButtonClickTrigger
      .withLatestFrom(task)
      .map { task -> Reaction in
        Reaction(
          UID: UUID().uuidString,
          userUID: Auth.auth().currentUser?.uid ?? "",
          taskUID: task.UID,
          type: .dislike)
      }
    
    let goodReaction = input.goodButtonClickTrigger
      .withLatestFrom(task)
      .map { task -> Reaction in
        Reaction(
          UID: UUID().uuidString,
          userUID: Auth.auth().currentUser?.uid ?? "",
          taskUID: task.UID,
          type: .like)
      }
    
    let saveReaction = Driver.of(
      badReaction,
      goodReaction
    )
      .merge()
      .asObservable()
      .flatMapLatest { reaction -> Observable<Result<Void, Error>> in
        self.managedContext.rx.update(reaction)
      }
      .asDriverOnErrorJustComplete()
      .mapToVoid()
    
    let newTasks = dbRef
      .child("PUBLISHED_TASKS")
      .rx
      .observeSingleEvent(.value)
      .map { snapshot -> [Task] in
        snapshot
          .children
          .compactMap { $0 as? DataSnapshot }
          .compactMap { snapshot -> Task? in
            Task(snapshot: snapshot)
          }
      }
    
    
//    let dataSource = Driver<[FunSection]>.of(
//    [
//      FunSection(header: "1", items: [
//        FunSectionItem(authorUID: UUID().uuidString, taskUID: UUID().uuidString, imageUID: UUID().uuidString)
//      ]),
//      FunSection(header: "2", items: [
//        FunSectionItem(authorUID: UUID().uuidString, taskUID: UUID().uuidString, imageUID: UUID().uuidString)
//      ])
//    ]
//    )
    
    return Output(
//      openAuthorPage: openAuthorPage,
//      openTaskPage: openTaskPage,
      nextTask: nextTask,
      nextTaskImage: nextTaskImage,
      handleReaction: saveReaction,
      dataSource: dataSource
    )
  }
}

