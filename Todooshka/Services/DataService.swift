//
//  TasksService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

import CoreData
import CoreMedia
import Firebase
import RxSwift
import RxCocoa
import YandexMobileMetrica


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
  let checkPlannedTasksTrigger = BehaviorRelay<Void>(value: ())
  let diamonds: Driver<[Diamond]>
  let goldTasks: Driver<[Task]>
  let icons: Driver<[Icon]>
  let feathersCount: Driver<Int>
  let firebaseBirds = BehaviorRelay<[BirdFirebase]?>(value: nil)
  let firebaseKindsOfTask = BehaviorRelay<[KindOfTask]?>(value: nil)
  let firebaseTasks = BehaviorRelay<[Task]>(value: [])
  let kindsOfTask: Driver<[KindOfTask]>
  let nestDataSource: Driver<[EggActionType]>
  let selectedDate = BehaviorRelay<Date>(value: Date())
  let tasks: Driver<[Task]>
  let user: Driver<User?>
  let compactUser: Driver<User>
  
  // MARK: - Init
  init() {

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
    
    let context = appDelegate.persistentContainer.viewContext
    
    let allBirds = context
      .rx
      .entities(Bird.self)
      .asDriver(onErrorJustReturn: [])
    
    let allTasks = context
      .rx
      .entities(Task.self)
      .map({ $0.sorted{ $0.created < $1.created } })
      .asDriver(onErrorJustReturn: [])
    
    let allKindsOfTask = context
      .rx
      .entities(KindOfTask.self)
      .map({ $0.sorted{ $0.index < $1.index } })
      .asDriver(onErrorJustReturn: [])
    
    let firebaseBirds = firebaseBirds
      .asDriver()
      .debug()
    
    let firebaseKindsOfTask = firebaseKindsOfTask
      .asDriver()
      .debug()
    
    let firebaseTasks = firebaseTasks
      .asDriver()
      .debug()
    
    user = Auth.auth()
      .rx
      .stateDidChange
      .asDriver(onErrorJustReturn: nil)
      .debug()
    
    compactUser = user
      .compactMap{ $0 }
      .debug()
    
    compactUser
      .drive()
      .disposed(by: disposeBag)
    
    // MARK: - Core Data
    diamonds = context
      .rx
      .entities(Diamond.self)
      .asDriver(onErrorJustReturn: [])
    
    birds = Driver.combineLatest(user, allBirds) { user, allBirds -> [Bird] in
      allBirds.filter{ $0.userUID == user?.uid }
    }.asDriver(onErrorJustReturn: [])

    kindsOfTask = Driver.combineLatest(user, allKindsOfTask) { user, kindsOfTask -> [KindOfTask] in
      kindsOfTask.filter{ $0.userUID == user?.uid }
    }.asDriver(onErrorJustReturn: [])
    
    tasks = Driver.combineLatest(user, allTasks) { user, tasks -> [Task] in
      tasks.filter{ $0.userUID == user?.uid }
    }.asDriver(onErrorJustReturn: [])
    
    // получаем количество закрытых задач (максимум 7 в день) и вычитаем общую стоимость купленных птиц
    goldTasks = tasks
      .map { $0.filter{ $0.status == .Completed } }     // отбираем только звкрытые задачи
      .map { $0.filter{ $0.closed != nil } }
      .map { $0.sorted{ $0.closed! < $1.closed! } }     // сортируем их по дате закрытия
      .map { Dictionary(grouping: $0 , by: { $0.closed!.startOfDay } ) } // превращаем в дикт по дате
      .map { $0.values.flatMap{ $0.prefix(7) } } // берем первые 7 задач
      .asDriver()
    
    feathersCount = Driver
      .combineLatest(birds, goldTasks) { birds, goldTasks -> Int in
        goldTasks.count - birds.filter{ $0.isBought }.map{ $0.price }.sum()
      }
    
    // Disposing
    birds.drive().disposed(by: disposeBag)
    diamonds.drive().disposed(by: disposeBag)
    feathersCount.drive().disposed(by: disposeBag)
    firebaseBirds.drive().disposed(by: disposeBag)
    firebaseTasks.drive().disposed(by: disposeBag)
    firebaseKindsOfTask.drive().disposed(by: disposeBag)
    goldTasks.drive().disposed(by: disposeBag)
    kindsOfTask.drive().disposed(by: disposeBag)
    tasks.drive().disposed(by: disposeBag)
   
    let openedBirdsNumber = birds
      .map{ $0.filter{ $0.clade == .Dragon && $0.isBought } }
      .map{ $0.count }
      .map{ $0 == 0 ? 6 : 7 }
    
    // при открытии проверяем и делаем все плановые задачи с плановой датой выполнения == сегодня задачи в работе
    let checkPlannedTasksTrigger = checkPlannedTasksTrigger.asDriver()
    
    Driver
      .combineLatest(tasks, checkPlannedTasksTrigger) { tasks, _ in tasks }
      .map{ $0.filter{ $0.status == .Planned } }
      .map{ $0.filter{ $0.planned != nil } }
      .map{ $0.filter{ $0.planned!.startOfDay <= Date().startOfDay } }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .map { task -> Task in
        var task = task
        task.status = .InProgress
        task.created = Date().startOfDay
        return task
      }.flatMapLatest({ context.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    // MARK: - Bird
    let openedBirds = birds
      .map{ $0.filter{ $0.isBought } }
    
    // закрываем самую дорогую птицу если не хватает перышек (такое бывает при удалении выполненных задач)
    let openedBirdSum = birds
      .map{ $0.filter{ $0.isBought } }
      .map{ $0.map{ $0.price }.sum() }

    Driver
      .combineLatest(goldTasks, openedBirdSum) { goldTasks, openedBirdSum -> Bool in
        openedBirdSum > goldTasks.count
      }
      .filter{ $0 }
      .withLatestFrom(openedBirds) { $1 }
      .compactMap{ $0.max(by: { $0.price < $1.price }) }
      .compactMap{ $0 }
      .map { bird -> Bird in
        var bird = bird
        bird.isBought = false
        return bird
      }.asObservable()
      .flatMapLatest({ context.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
   
    // MARK: - Nest DataSource
    let completedTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { $0.status == .Completed }
          .filter { $0.closed != nil }
          .filter { Calendar.current.isDate($0.closed!, inSameDayAs: Date()) }
          .sorted { $0.closed! < $1.closed! }
      }
    
    let inProgressTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { $0.status == .InProgress }
          .filter { $0.is24hoursPassed == false }
          .sorted { $0.created < $1.created }
      }
    
    let crackActions = Driver
      .combineLatest(completedTasks, openedBirdsNumber) { completedTasks, openedBirdsNumber in
        completedTasks.prefix(openedBirdsNumber)
      }
      .map{ Array($0) }
      .withLatestFrom(kindsOfTask) { tasks, kindsOfTask -> [Style] in // получаем для них стили
        tasks.compactMap { task -> Style? in
          kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID })?.style
        }
      }
      .withLatestFrom(birds) { style, birds -> [Bird] in // получаем птиц
        style.enumerated().compactMap { index, style -> Bird? in
          birds.first(where: { $0.style == style && $0.clade == Clade(level: index + 1) })
        }
      }
      .map { birds -> [Style] in // если куплена, то оставляем, иначе симл
        birds.compactMap { bird -> Style? in
          bird.isBought ? bird.style : .Simple
        }
      }
      .map { styles -> [EggActionType] in // получаем действия
        styles.map{ .Crack(style: $0) }
      }.startWith([])
    
  let noCrackActions = Driver
    .combineLatest(inProgressTasks, openedBirdsNumber) { inProgressTasks, openedBirdsNumber in
      inProgressTasks.prefix(openedBirdsNumber)
    }
    .map { Array($0) }
    .map { $0.map { _ in EggActionType.NoCracks } }
    .startWith([])
  
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
      .combineLatest(crackActions, noCrackActions, hideEggsActions, openedBirdsNumber) { crackActions, noCrackActions, hideEggsActions, openedBirdsNumber in
        (crackActions + noCrackActions + hideEggsActions).prefix(openedBirdsNumber)
      }
      .map{ Array($0) }
      .distinctUntilChanged()
    
    // MARK: - Branch DataSource
    let selectedDate = selectedDate
      .asDriver()

    let completedTasksForSelectedDate = Driver
      .combineLatest(tasks, selectedDate) { tasks, selectedDate -> [Task] in
        tasks
          .filter { $0.status == .Completed }
          .filter { $0.closed != nil }
          .filter { Calendar.current.isDate($0.closed!, inSameDayAs: selectedDate ) }
          .sorted{ $0.closed! < $1.closed! }
      }
    
    let sittingAction = Driver
      .combineLatest(completedTasksForSelectedDate, openedBirdsNumber) { completedTasksForSelectedDate, openedBirdsNumber in
        completedTasksForSelectedDate.prefix(openedBirdsNumber)
      }
      .map { Array($0) }
      .withLatestFrom(kindsOfTask) { tasks, kindsOfTask -> [Style] in // получаем для них стили
        tasks.compactMap { task -> Style? in
          kindsOfTask.first(where: { $0.UID == task.kindOfTaskUID })?.style
        }
      }.withLatestFrom(birds) { style, birds -> [Bird] in // получаем птиц
        style.enumerated().compactMap { index, style -> Bird? in
          birds.first(where: { $0.style == style && $0.clade == Clade(level: index + 1) })
        }
      }
      .map { birds -> [Style] in // если куплена, то оставляем, иначе симл
        birds.compactMap { bird -> Style? in
          switch bird.clade {
          case .Dragon:
            return bird.isBought ? bird.style : nil
          default:
            return bird.isBought ? bird.style : .Simple
          }
        }
      }.withLatestFrom(selectedDate) { styles, closed -> [BirdActionType] in
        styles.map{ .Sitting(style: $0, closed: closed)
        }
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
    
    // MARK: - Firebase
    // скачиваем из облака когда пользователь заходит в аккаунт
    Auth.auth().addStateDidChangeListener() { [weak self] auth, user in
      guard let self = self else  { return }
      if let user = user {
       
        // FIREBASEBIRDS
        DB_USERS_REF.child(user.uid).child("BIRDS").observe(.value) { snapshot in
          self.firebaseBirds.accept(
            snapshot.children.allObjects
              .compactMap { $0 as? DataSnapshot }
              .compactMap { snasphot -> BirdFirebase? in
                BirdFirebase(snapshot: snasphot)
              }
          )
        }
        
        // KINDSOFTASK
        DB_USERS_REF.child(user.uid).child("KINDSOFTASK").observe(.value) { snapshot in
          self.firebaseKindsOfTask.accept(
            snapshot.children.allObjects
              .compactMap { $0 as? DataSnapshot }
              .compactMap { snasphot -> KindOfTask? in
                KindOfTask(snapshot: snasphot)
              }
          )
        }
        
        // TASK
        DB_USERS_REF.child(user.uid).child("TASKS").observe(.value) { snapshot in
          self.firebaseTasks.accept(
            snapshot.children.allObjects
              .compactMap{ $0 as? DataSnapshot }
              .compactMap { snasphot -> Task? in
                Task(snapshot: snasphot)
              }
          )
        }
        
      } else {
        self.firebaseBirds.accept(nil)
        self.firebaseKindsOfTask.accept(nil)
        self.firebaseTasks.accept([])
      }
    }

    // MARK: - Firebse Tasks
    // проставляем userUID при первом входе в аккаунт всем пустым задачам
    let tasksEmptyUser = allTasks
      .map { $0.filter { $0.userUID == nil } }
    
    // загружаем в облако таски
    compactUser
      .withLatestFrom(tasksEmptyUser) { user, tasks -> [Task] in
        tasks.map { task -> Task in
          var task = task
          task.userUID = user.uid
          return task
        }.filter{ $0.status != .Archive }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    tasks
      .withLatestFrom(firebaseTasks) { tasks, firebaseTasks -> [Task] in
        tasks.filter{ task -> Bool in
          task.lastModified > (firebaseTasks.first(where: { $0.UID == task.UID })?.lastModified ?? Date(timeIntervalSince1970: 0))
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .withLatestFrom(compactUser) { task, user in
        DB_USERS_REF.child(user.uid).child("TASKS").child(task.UID).updateChildValues(task.data)
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
    
    // скачиваем из облака таски
    firebaseTasks
      .debug()
      .withLatestFrom(tasks) { firebaseTasks, tasks -> [Task] in
        firebaseTasks.filter{ firebaseTask -> Bool in
          firebaseTask.lastModified > (tasks.first(where: { $0.UID == firebaseTask.UID })?.lastModified ?? Date(timeIntervalSince1970: 0))
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ task -> Observable<Result<Void, Error>> in
        context.rx.update(task)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    // MARK: - Firebse KindsOfTask
    // кайнд оф таски без пользователя
    let kindsOfTaskEmptyUser = allKindsOfTask
      .map{ $0.filter{ $0.userUID == nil } }
    
    // проставляем USER UID когда входим в аккаунт
   compactUser
      .withLatestFrom(kindsOfTaskEmptyUser) { compactUser, kindsOfTaskEmptyUser -> [KindOfTask] in
        kindsOfTaskEmptyUser.map { kindOfTask -> KindOfTask in
          var kindOfTask = kindOfTask
          kindOfTask.userUID = compactUser.uid
          kindOfTask.lastModified = Date(timeIntervalSince1970: 1) // что бы загружать в файрбейс только если их нет
          return kindOfTask
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ kindOfTask -> Observable<Result<Void, Error>> in
        context.rx.update(kindOfTask)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    // удаляем ВСЕ кайнд оф таски когда выходим из аккаунта
    user
      .filter{ $0 == nil }
      .withLatestFrom(allKindsOfTask) { $1 }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ kindOfTask -> Observable<Result<Void, Error>> in
        context.rx.delete(kindOfTask)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .debug()
      .drive()
      .disposed(by: disposeBag)
    
    // загружаем в облако кайнд оф таски
    Driver
      .combineLatest(kindsOfTask, firebaseKindsOfTask) { kindsOfTask, firebaseKindsOfTask -> [KindOfTask] in
        guard let firebaseKindsOfTask = firebaseKindsOfTask else { return [] }
        return kindsOfTask.filter { kindOfTask -> Bool in
          kindOfTask.lastModified > (firebaseKindsOfTask.first(where: { $0.UID == kindOfTask.UID })?.lastModified ?? Date(timeIntervalSince1970: 0))
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .withLatestFrom(compactUser) { kindOfTask, user in
        DB_USERS_REF.child(user.uid).child("KINDSOFTASK").child(kindOfTask.UID).updateChildValues(kindOfTask.data)
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
    
    // скачиваем из облака кайнд оф таски
    firebaseKindsOfTask
      .withLatestFrom(kindsOfTask) { firebaseKindsOfTask, kindsOfTask -> [KindOfTask] in
        guard let firebaseKindsOfTask = firebaseKindsOfTask else { return [] }
        return firebaseKindsOfTask.filter{ firebaseKindOfTask -> Bool in
          firebaseKindOfTask.lastModified > (kindsOfTask.first(where: { $0.UID == firebaseKindOfTask.UID })?.lastModified ?? Date(timeIntervalSince1970: 0))
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ kindOfTask -> Observable<Result<Void, Error>> in
        context.rx.update(kindOfTask)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)

    // MARK: - Firebse Birds
    let birdsEmptyUser = birds
      .map { $0.filter { $0.userUID == nil } }
    
    // проставляем USER UID когда входим в аккаунт
   compactUser
      .withLatestFrom(birdsEmptyUser) { compactUser, birdsEmptyUser -> [Bird] in
        birdsEmptyUser.map { bird -> Bird in
          var bird = bird
          bird.userUID = compactUser.uid
          bird.lastModified = Date(timeIntervalSince1970: 1) // что бы загружать в файрбейс только если их нет
          return bird
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ bird -> Observable<Result<Void, Error>> in
        context.rx.update(bird)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    // удаляем ВСЕ birds когда выходим из аккаунта
    user
      .filter{ $0 == nil }
      .withLatestFrom(allBirds) { $1 }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ bird -> Observable<Result<Void, Error>> in
        context.rx.delete(bird)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    // загружаем в облако birds
    Driver
      .combineLatest(birds, firebaseBirds) { birds, firebaseBirds -> [Bird] in
        guard let firebaseBirds = firebaseBirds else { return [] }
        return birds.filter{ bird -> Bool in
          bird.lastModified > (firebaseBirds.first(where: { $0.UID == bird.UID })?.lastModified.adding(.second, value: 1) ?? Date(timeIntervalSince1970: 0))
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .debug()
      .withLatestFrom(compactUser) { bird, user in
        print("4321 UPDATE BIRDS")
        return DB_USERS_REF.child(user.uid).child("BIRDS").child(bird.UID).updateChildValues(bird.data)
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
    
    // загружаем из облака birds
    firebaseBirds
      .debug()
      .withLatestFrom(birds) { firebaseBirds, birds -> [Bird] in
        guard let firebaseBirds = firebaseBirds else { return [] }
        return firebaseBirds
          .filter { firebaseBird -> Bool in
            firebaseBird.lastModified > (birds.first(where: { $0.UID == firebaseBird.UID })?.lastModified ?? Date(timeIntervalSince1970: 0))
          }
          .compactMap { firebaseBird -> Bird? in
            guard var bird = birds.first(where: { $0.UID == firebaseBird.UID }) else { return nil }
            bird.isBought = firebaseBird.isBought
            bird.lastModified = firebaseBird.lastModified
            return bird
          }
      }
      .debug()
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ bird -> Observable<Result<Void, Error>> in
        context.rx.update(bird)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    
    // MARK: - Initial loading
    allKindsOfTask
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
    
    allBirds
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
      }
      .debug()
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)

  }
}
