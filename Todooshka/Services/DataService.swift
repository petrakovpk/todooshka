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
import CoreMedia

protocol HasDataService {
  var dataService: DataService { get }
}

class DataService {
  
  // MARK: - Properties
  // core data
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  // rx
  let disposeBag = DisposeBag()
  // data
  let birds: Driver<[Bird]>
  let colors: Driver<[UIColor]>
  let diamonds: Driver<[Diamond]>
  let icons: Driver<[Icon]>
  let feathers: Driver<[Feather]>
  let firebaseTasks: Driver<[Task]>
  let firebaseKindsOfTask: Driver<[KindOfTask]>
  let kindsOfTask: Driver<[KindOfTask]>
  let kindsOfTaskNotChangeable: Driver<[KindOfTask]>
  let tasks: Driver<[Task]>
  
  // MARK: - Init
  init() {
    
    let user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
      .compactMap{ $0 }
    
    let context = self.appDelegate
      .persistentContainer
      .viewContext
    
    colors = Driver<[UIColor]>.of([
      Palette.SingleColors.Amethyst,
      Palette.SingleColors.BlushPink,
      Palette.SingleColors.BrightSun,
      Palette.SingleColors.BrinkPink,
      Palette.SingleColors.Cerise,
      Palette.SingleColors.Corduroy,
      Palette.SingleColors.Jaffa,
      Palette.SingleColors.Malibu,
      Palette.SingleColors.Portage,
      Palette.SingleColors.PurpleHeart,
      Palette.SingleColors.SeaGreen,
      Palette.SingleColors.Turquoise,
    ])
    
    icons = Driver<[Icon]>.of([
      .Bank,
      .BookSaved,
      .Briefcase,
      .Dumbbell,
      .EmojiHappy,
      .GasStation,
      .House,
      .Lovely,
      .Moon,
      .NotificationBing,
      .Pet,
      .Profile2user,
      .Ship,
      .Shop,
      .Sun,
      .Teacher,
      .Unlimited,
      .VideoVertical,
      .Wallet,
      .Weight
    ])
    
    birds = context
      .rx
      .entities(Bird.self)
      .asDriver(onErrorJustReturn: [])
    
    diamonds = context
      .rx
      .entities(Diamond.self)
      .asDriver(onErrorJustReturn: [])
    
    feathers = context
      .rx
      .entities(Feather.self)
      .asDriver(onErrorJustReturn: [])
      .debug()
    
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

    kindsOfTaskNotChangeable = Driver<[KindOfTask]>.of([
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
    ])
    
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
    
    // create feather
    tasks
      .map { tasks -> [Task] in // получаем все закрытые на сегодня таски
        tasks
          .filter{ $0.status == .Completed }
          .filter{ Calendar.current.isDate(Date(), inSameDayAs: $0.closed ?? Date()) }
      }
      .filter{ $0.count <= 7 } // за день не более 7
      .debug()
      .withLatestFrom(feathers) { (tasks, feathers) -> [Task] in // получаем те, для кого не сделали перышки
        tasks
          .filter{ task -> Bool in
            feathers.map{ $0.taskUID }.contains(task.UID) == false
          }
      }
      .map { tasks -> [Feather] in // делаем перышки
        tasks.map {
          Feather(
            UID: UUID().uuidString,
            created: Date(),
            taskUID: $0.UID,
            isSpent: false)
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    // remove feather
    Driver
      .combineLatest(tasks, feathers) { (tasks, feathers) -> [Feather] in
        feathers
          .filter{ feather -> Bool in
            tasks.filter{ $0.status == .Completed}.map{ $0.UID }.contains(feather.taskUID) == false
          }
      }.debug()
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.delete($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
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
    
    birds
      .filter({ $0.isEmpty })
      .map { _ -> [Bird] in
        [
          // Chiken
          Bird.Chiken.Simple,
          Bird.Chiken.Student,
          Bird.Chiken.Business,
          Bird.Chiken.Cook,
          Bird.Chiken.Kid,
          Bird.Chiken.Sport,
          Bird.Chiken.Fashion,
          
          // Ostrich
          Bird.Ostrich.Simple,
          Bird.Ostrich.Student,
          Bird.Ostrich.Business,
          Bird.Ostrich.Cook,
          Bird.Ostrich.Kid,
          Bird.Ostrich.Sport,
          Bird.Ostrich.Fashion,
          
          // Owl
          Bird.Owl.Simple,
          Bird.Owl.Student,
          Bird.Owl.Business,
          Bird.Owl.Cook,
          Bird.Owl.Kid,
          Bird.Owl.Sport,
          Bird.Owl.Fashion,
          
          // Parrot
          Bird.Parrot.Simple,
          Bird.Parrot.Student,
          Bird.Parrot.Business,
          Bird.Parrot.Cook,
          Bird.Parrot.Kid,
          Bird.Parrot.Sport,
          Bird.Parrot.Fashion,
          
          // Penguin
          Bird.Penguin.Simple,
          Bird.Penguin.Student,
          Bird.Penguin.Business,
          Bird.Penguin.Cook,
          Bird.Penguin.Kid,
          Bird.Penguin.Sport,
          Bird.Penguin.Fashion,
          
          // Eagle
          Bird.Eagle.Simple,
          Bird.Eagle.Student,
          Bird.Eagle.Business,
          Bird.Eagle.Cook,
          Bird.Eagle.Kid,
          Bird.Eagle.Sport,
          Bird.Eagle.Fashion,
          
          // Dragon
          Bird.Dragon.Simple,
          Bird.Dragon.Student,
          Bird.Dragon.Business,
          Bird.Dragon.Cook,
          Bird.Dragon.Kid,
          Bird.Dragon.Sport,
          Bird.Dragon.Fashion
        ]
      }.asObservable()
      .flatMapLatest({  Observable.from($0) })
      .flatMapLatest { bird in
        context.rx.update(bird)
      }.asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
  }
}
