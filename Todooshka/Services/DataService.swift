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
  let branchDataSource: Driver<[BirdActionType]>
  let colors: Driver<[UIColor]>
  let diamonds: Driver<[Diamond]>
  let icons: Driver<[Icon]>
  let feathers: Driver<[Feather]>
  let firebaseTasks: Driver<[Task]>
  let firebaseKindsOfTask: Driver<[KindOfTask]>
  let kindsOfTask: Driver<[KindOfTask]>
  let nestDataSource: Driver<[EggActionType]>
  let selectedDate = BehaviorRelay<Date>(value: Date())
  let tasks: Driver<[Task]>
  
  // MARK: - Init
  init() {
    
    let context = appDelegate.persistentContainer.viewContext

    // MARK: - Const
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
    
    // MARK: - Core Data
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
    
    // add feather
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
   
    
    // MARK: - Nest DataSource
    let completedTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { $0.status == .Completed }
          .filter { Calendar.current.isDate($0.closed ?? Date(), inSameDayAs: Date()) }
          .sorted { $0.closed! < $1.closed! }
      }
    
    let isProgressTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { $0.status == .InProgress }
          .filter { $0.is24hoursPassed == false }
          .sorted { $0.created < $1.created }
      }
    
    let crackActions = completedTasks
      .map { $0.prefix(7) } // берем первые 7 выполненных задач
      .map { Array($0) }
      .withLatestFrom(kindsOfTask) { tasks, kindsOfTask -> [Style] in // получаем для них стили
        tasks.compactMap { task -> Style? in
          kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID })?.style
        }
      }.withLatestFrom(birds) { style, birds -> [Bird] in // получаем птиц
        style.enumerated().compactMap { index, style -> Bird? in
          birds.first(where: { $0.style == style && $0.clade == Clade(level: index + 1) })
        }
      }.map { birds -> [Style] in // если куплена, то оставляем, иначе симл
        birds.map{ bird -> Style in
          bird.isBought ? bird.style : .Simple }
      }
      .map { styles -> [EggActionType] in // получаем действия
        styles.map{ .Crack(style: $0) }
      }
    
    let noCrackActions = isProgressTasks
      .map { $0.prefix(7) } // берем первые 7 выполненных задач
      .map { Array($0) }
      .map { $0.map { _ in EggActionType.NoCracks } }
    
    let hideEggsActions = Driver<[EggActionType]>.of([
      .Hide,
      .Hide,
      .Hide,
      .Hide,
      .Hide,
      .Hide,
      .Hide
    ])
    
    nestDataSource = Driver
      .combineLatest(crackActions, noCrackActions, hideEggsActions) { crackActions, noCrackActions, hideEggsActions -> [EggActionType] in
        crackActions + noCrackActions + hideEggsActions
      }.map { $0.prefix(7) }
      .map{ Array($0) }
      .distinctUntilChanged()
    
    // MARK: - Branch DataSource
    let selectedDate = selectedDate
      .asDriver()
    
   // selectedDate.drive().disposed(by: disposeBag)
    
    let completedTasksForSelectedDate = Driver
      .combineLatest(tasks, selectedDate) { tasks, selectedDate -> [Task] in
        tasks
          .filter { $0.status == .Completed }
          .filter { Calendar.current.isDate($0.closed ?? Date(), inSameDayAs: selectedDate ) }
          .sorted{ $0.closed! < $1.closed! }
      }
    
    let sittingAction = completedTasksForSelectedDate
      .map { $0.prefix(7) } // берем первые 7 выполненных задач
      .map { Array($0) }
      .withLatestFrom(kindsOfTask) { tasks, kindsOfTask -> [Style] in // получаем для них стили
        tasks.compactMap { task -> Style? in
          kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID })?.style
        }
      }.withLatestFrom(birds) { style, birds -> [Bird] in // получаем птиц
        style.enumerated().compactMap { index, style -> Bird? in
          birds.first(where: { $0.style == style && $0.clade == Clade(level: index + 1) })
        }
      }.map { birds -> [Style] in // если куплена, то оставляем, иначе симл
        birds.map{ bird -> Style in
          bird.isBought ? bird.style : .Simple }
      }.withLatestFrom(selectedDate) { styles, closed -> [BirdActionType] in
        styles.map{ .Sitting(style: $0, closed: closed) }
      }

    let hiddenBirdsActions = Driver<[BirdActionType]>.of([
      .Hide,
      .Hide,
      .Hide,
      .Hide,
      .Hide,
      .Hide,
      .Hide
    ])
    
    branchDataSource = Driver
      .combineLatest(sittingAction, hiddenBirdsActions) { sittingAction, hiddenBirdsActions -> [BirdActionType] in
        sittingAction + hiddenBirdsActions
      }.map { $0.prefix(7) }
      .map{ Array($0) }
      .distinctUntilChanged()
      .debug()
    
    // MARK: - Initial loading
    kindsOfTask
      .filter({ $0.isEmpty })
      .map { _ -> [KindOfTask] in
        [
          KindOfTask.Standart.Sport,
          KindOfTask.Standart.Fashion,
          KindOfTask.Standart.Cook,
          KindOfTask.Standart.Business,
          KindOfTask.Standart.Student,
          KindOfTask.Standart.Simple,
          KindOfTask.Standart.Kid,
          KindOfTask.Standart.Home,
          KindOfTask.Standart.Simple,
          KindOfTask.Standart.Pet
        ]
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.update($0)})
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
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
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    // MARK: - Firebase
    let user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
      .compactMap{ $0 }
    
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
    
    
    firebaseTasks.drive().disposed(by: disposeBag)
    firebaseKindsOfTask.drive().disposed(by: disposeBag)
    
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
  }
}
