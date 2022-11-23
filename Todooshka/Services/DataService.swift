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

enum SyncData<T: Persistable> {
  case updateCoreData(data: [T])
  case updateFirebase(data: [T])
}

protocol HasDataService {
  var dataService: DataService { get }
}

class DataService {
  // MARK: - Properties
  // core data
  let appDelegate = UIApplication.shared.delegate as? AppDelegate

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
  let firebaseTasks = BehaviorRelay<[Task]?>(value: nil)
  let kindsOfTask: Driver<[KindOfTask]>
  let nestDataSource: Driver<[EggActionType]>
  let selectedDate = BehaviorRelay<Date>(value: Date())
  let tasks: Driver<[Task]>
  let themes: Driver<[Theme]>
  let user: Driver<User?>
  let compactUser: Driver<User>

  // MARK: - Init
  init() {
    let managedContext = appDelegate!.persistentContainer.viewContext

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
      Palette.SingleColors.Turquoise
    ])

    icons = Driver<[Icon]>.of([
      .bank,
      .bookSaved,
      .briefcase,
      .dumbbell,
      .emojiHappy,
      .gasStation,
      .home,
      .lovely,
      .moon,
      .notificationBing,
      .pet,
      .profile2user,
      .ship,
      .shop,
      .sun,
      .teacher,
      .unlimited,
      .videoVertical,
      .wallet,
      .weight
    ])

//    themes = Driver<[Theme]>.of([
//      Theme(uid: UUID().uuidString, description: "", name: "Как я победил страх", status: .notStarted),
//      Theme(uid: UUID().uuidString, description: "", name: "Отказываемся от сахара", status: .notStarted),
//      Theme(uid: UUID().uuidString, description: "", name: "Рано ложимся спать", status: .notStarted),
//      Theme(uid: UUID().uuidString, description: "", name: "Начинаем программировать", status: .notStarted),
//      Theme(uid: UUID().uuidString, description: "", name: "Бросаем курить", status: .notStarted),
//      Theme(uid: UUID().uuidString, description: "", name: "Начинаем отжиматься", status: .notStarted),
//      Theme(uid: UUID().uuidString, description: "", name: "Читаем по одной книге в неделю", status: .notStarted)
//    ])

    let allBirds = managedContext
      .rx
      .entities(Bird.self)
      .asDriver(onErrorJustReturn: [])

    let allTasks = managedContext
      .rx
      .entities(Task.self)
      .map { $0.sorted { $0.created < $1.created }}
      .asDriver(onErrorJustReturn: [])

    let allKindsOfTask = managedContext
      .rx
      .entities(KindOfTask.self)
      .map { $0.sorted { $0.index < $1.index }}
      .asDriver(onErrorJustReturn: [])

    let firebaseBirds = firebaseBirds
      .asDriver()

    let firebaseKindsOfTask = firebaseKindsOfTask
      .asDriver()

    let firebaseTasks = firebaseTasks
      .asDriver()
    
    user = Auth.auth()
      .rx
      .stateDidChange
      .asDriver(onErrorJustReturn: nil)
      .startWith(Auth.auth().currentUser)

    compactUser = user
      .compactMap { $0 }

    compactUser
      .drive()
      .disposed(by: disposeBag)

    // MARK: - Core Data
    diamonds = managedContext
      .rx
      .entities(Diamond.self)
      .asDriver(onErrorJustReturn: [])

    birds = Driver.combineLatest(user, allBirds) { user, allBirds -> [Bird] in
      allBirds.filter { $0.userUID == user?.uid }
    }
    .asDriver(onErrorJustReturn: [])

    kindsOfTask = Driver.combineLatest(user, allKindsOfTask) { user, kindsOfTask -> [KindOfTask] in
      kindsOfTask.filter { $0.userUID == user?.uid }
    }
    .asDriver(onErrorJustReturn: [])

    tasks = Driver.combineLatest(user, allTasks) { user, tasks -> [Task] in
      tasks.filter { $0.userUID == user?.uid }
    }
    .asDriver(onErrorJustReturn: [])
    
    themes = managedContext
      .rx
      .entities(Theme.self)
      .asDriver(onErrorJustReturn: [])

    // получаем количество закрытых задач (максимум 7 в день) и вычитаем общую стоимость купленных птиц
    goldTasks = tasks
      .map { $0.filter { $0.status == .completed } }     // отбираем только звкрытые задачи
      .map { $0.filter { $0.closed != nil } }
      .map { $0.sorted { $0.closed! < $1.closed! }}     // сортируем их по дате закрытия
      .map { Dictionary(grouping: $0) { $0.closed!.startOfDay } } // превращаем в дикт по дате
      .map { $0.values.flatMap { $0.prefix(7) } } // берем первые 7 задач
      .asDriver()

    feathersCount = Driver
      .combineLatest(birds, goldTasks) { birds, goldTasks -> Int in
        goldTasks.count - birds.filter { $0.isBought }.map { $0.price }.sum()
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
      .map { $0.filter { $0.clade == .dragon && $0.isBought } }
      .map { $0.count }
      .map { $0 == 0 ? 6 : 7 }

    // при открытии проверяем и делаем все плановые задачи с плановой датой выполнения == сегодня задачи в работе
    let checkPlannedTasksTrigger = checkPlannedTasksTrigger.asDriver()

    Driver
      .combineLatest(tasks, checkPlannedTasksTrigger) { tasks, _ in tasks }
      .map { $0.filter { $0.status == .planned } }
      .map { $0.filter { $0.planned != nil } }
      .map { $0.filter { $0.planned!.startOfDay <= Date().startOfDay } }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .map { task -> Task in
        var task = task
        task.status = .inProgress
        task.created = Date().startOfDay
        return task
      }
      .flatMapLatest({ managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .drive()
      .disposed(by: disposeBag)

    // MARK: - Bird
    let openedBirds = birds
      .map { $0.filter { $0.isBought } }

    // закрываем самую дорогую птицу если не хватает перышек (такое бывает при удалении выполненных задач)
    let openedBirdSum = birds
      .map { $0.filter { $0.isBought } }
      .map { $0.map { $0.price }.sum() }

    Driver
      .combineLatest(goldTasks, openedBirdSum) { goldTasks, openedBirdSum -> Bool in
        openedBirdSum > goldTasks.count
      }
      .filter { $0 }
      .withLatestFrom(openedBirds) { $1 }
      .compactMap { $0.max { $0.price < $1.price }}
      .compactMap { $0 }
      .map { bird -> Bird in
        var bird = bird
        bird.isBought = false
        return bird
      }
      .asObservable()
      .flatMapLatest({ managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .drive()
      .disposed(by: disposeBag)

    // MARK: - Nest DataSource
    let completedTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { $0.status == .completed }
          .filter { $0.closed != nil }
          .filter { Calendar.current.isDate($0.closed!, inSameDayAs: Date()) }
          .sorted { $0.closed! < $1.closed! }
      }

    let inProgressTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { $0.status == .inProgress }
          .filter { $0.is24hoursPassed == false }
          .sorted { $0.created < $1.created }
      }

    let crackActions = Driver
      .combineLatest(completedTasks, openedBirdsNumber) { completedTasks, openedBirdsNumber in
        completedTasks.prefix(openedBirdsNumber)
      }
      .map { Array($0) }
      .withLatestFrom(kindsOfTask) { tasks, kindsOfTask -> [BirdStyle] in // получаем для них стили
        tasks.compactMap { task -> BirdStyle? in
          kindsOfTask.first { $0.UID == task.kindOfTaskUID }?.style
        }
      }
      .withLatestFrom(birds) { style, birds -> [Bird] in // получаем птиц
        style.enumerated().compactMap { index, style -> Bird? in
          birds.first { $0.style == style && $0.clade == Clade(level: index + 1) }
        }
      }
      .map { birds -> [BirdStyle] in // если куплена, то оставляем, иначе симл
        birds.compactMap { bird -> BirdStyle? in
          bird.isBought ? bird.style : .simple
        }
      }
      .map { styles -> [EggActionType] in // получаем действия
        styles.map { .crack(style: $0) }
      }
      .startWith([])

    let noCrackActions = Driver
      .combineLatest(inProgressTasks, openedBirdsNumber) { inProgressTasks, openedBirdsNumber in
        inProgressTasks.prefix(openedBirdsNumber)
      }
      .map { Array($0) }
      .map { $0.map { _ in EggActionType.noCracks } }
      .startWith([])

    let hideEggsActions = Driver<[EggActionType]>.of([
      .hide,
      .hide,
      .hide,
      .hide,
      .hide,
      .hide,
      .hide
    ])

    nestDataSource = Driver
      .combineLatest(
        crackActions,
        noCrackActions,
        hideEggsActions,
        openedBirdsNumber
      ) { crackActions, noCrackActions, hideEggsActions, openedBirdsNumber in
        (crackActions + noCrackActions + hideEggsActions).prefix(openedBirdsNumber)
      }
      .map { Array($0) }
      .distinctUntilChanged()

    // MARK: - Branch DataSource
    let selectedDate = selectedDate
      .asDriver()

    let completedTasksForSelectedDate = Driver
      .combineLatest(tasks, selectedDate) { tasks, selectedDate -> [Task] in
        tasks
          .filter { $0.status == .completed }
          .filter { $0.closed != nil }
          .filter { Calendar.current.isDate($0.closed!, inSameDayAs: selectedDate ) }
          .sorted { $0.closed! < $1.closed! }
      }

    let sittingAction = Driver
      .combineLatest(completedTasksForSelectedDate, openedBirdsNumber) { completedTasksForSelectedDate, openedBirdsNumber in
        completedTasksForSelectedDate.prefix(openedBirdsNumber)
      }
      .map { Array($0) }
      .withLatestFrom(kindsOfTask) { tasks, kindsOfTask -> [BirdStyle] in // получаем для них стили
        tasks.compactMap { task -> BirdStyle? in
          kindsOfTask.first { $0.UID == task.kindOfTaskUID }?.style
        }
      }
      .withLatestFrom(birds) { style, birds -> [Bird] in // получаем птиц
        style.enumerated().compactMap { index, style -> Bird? in
          birds.first { $0.style == style && $0.clade == Clade(level: index + 1) }
        }
      }
      .map { birds -> [BirdStyle] in // если куплена, то оставляем, иначе симл
        birds.compactMap { bird -> BirdStyle? in
          switch bird.clade {
          case .dragon:
            return bird.isBought ? bird.style : nil
          default:
            return bird.isBought ? bird.style : .simple
          }
        }
      }
      .withLatestFrom(selectedDate) { styles, closed -> [BirdActionType] in
        styles.map { .sitting(style: $0, closed: closed)
        }
      }

    let hiddenBirdsActions = Driver<[BirdActionType]>.of([
      .hide,
      .hide,
      .hide,
      .hide,
      .hide,
      .hide,
      .hide
    ])

    branchDataSource = Driver
      .combineLatest(sittingAction, hiddenBirdsActions) { sittingAction, hiddenBirdsActions -> [BirdActionType] in
        sittingAction + hiddenBirdsActions
      }
      .map { $0.prefix(7) }
      .map { Array($0) }
      .distinctUntilChanged()

    // MARK: - Firebase
    // скачиваем из облака когда пользователь заходит в аккаунт
    Auth.auth().addStateDidChangeListener { [weak self] _, user in
      guard let self = self else { return }
      if let user = user {
        // FIREBASEBIRDS
        dbUserRef.child(user.uid).child("BIRDS").observe(.value) { snapshot in
          self.firebaseBirds.accept(
            snapshot.children.allObjects
              .compactMap { $0 as? DataSnapshot }
              .compactMap { snasphot -> BirdFirebase? in
                BirdFirebase(snapshot: snasphot)
              }
          )
        }

        // KINDSOFTASK
        dbUserRef.child(user.uid).child("KINDSOFTASK").observe(.value) { snapshot in
          self.firebaseKindsOfTask.accept(
            snapshot.children.allObjects
              .compactMap { $0 as? DataSnapshot }
              .compactMap { snasphot -> KindOfTask? in
                KindOfTask(snapshot: snasphot)
              }
          )
        }

        // TASK
        dbUserRef.child(user.uid).child("TASKS").observe(.value) { snapshot in
          self.firebaseTasks.accept(
            snapshot.children.allObjects
              .compactMap { $0 as? DataSnapshot }
              .compactMap { snasphot -> Task? in
                Task(snapshot: snasphot)
              }
          )
        }
      } else {
        self.firebaseBirds.accept(nil)
        self.firebaseKindsOfTask.accept(nil)
        self.firebaseTasks.accept(nil)
      }
    }

    // MARK: - Sync Tasks
    // проставляем userUID при первом входе в аккаунт всем пустым задачам
    let tasksEmptyUser = allTasks
      .map { $0.filter { $0.userUID == nil } }

    // Проставляем User UID
    compactUser
      .withLatestFrom(tasksEmptyUser) { user, tasks -> [Task] in
        tasks.map { task -> Task in
          var task = task
          task.userUID = user.uid
          return task
        }
        .filter { $0.status != .archive }
      }
      .asObservable()
      .flatMapLatest { managedContext.rx.batchUpdate($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .drive()
      .disposed(by: disposeBag)

    // Tasks: Core Data -> Firebase
    Driver
      .combineLatest(tasks, firebaseTasks) { tasks, firebaseTasks -> [Task] in
        tasks.filter { task -> Bool in
          // Если пусто, то ничего не передаем
          guard let firebaseTasks = firebaseTasks else { return false }
          // если задачи нет в Firebase, то загружаем в Firebase
          guard let firebaseTask = firebaseTasks.first(where: { $0.UID == task.UID }) else { return true }
          // если дата обновления задачи больше чем в Firebase, то обновляем Firebase
          return task.lastModified > firebaseTask.lastModified
        }
      }
      .filter { !$0.isEmpty }
      .withLatestFrom(compactUser) { tasks, user in
        dbUserRef.child(user.uid).child("TASKS").runTransactionBlock { currentData in
          var dict: [String: AnyObject] = currentData.value as? [String: AnyObject] ?? [:]

          tasks.forEach { task in
            dict[task.UID] = task.data as AnyObject
          }

          currentData.value = dict
          return TransactionResult.success(withValue: currentData)
        }
      }
      .drive()
      .disposed(by: disposeBag)

    // Tasks: Firebase -> Core Data
    Driver
      .combineLatest(firebaseTasks, tasks) { firebaseTasks, tasks -> [Task] in
        firebaseTasks?.filter { firebaseTask -> Bool in
          // если задачи нет в Firebase, то загружаем в Firebase
          guard let task = tasks.first(where: { $0.UID == firebaseTask.UID }) else { return true }
          // если дата обновления задачи больше чем в Firebase, то обновляем Firebase
          return firebaseTask.lastModified > task.lastModified
        } ?? []
      }
      .filter { !$0.isEmpty }
      .asObservable()
      .flatMapLatest { tasks -> Observable<Result<Void, Error>> in
        managedContext.rx.batchUpdate(tasks)
      }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .drive()
      .disposed(by: disposeBag)

    // MARK: - Sync KindsOfTask
    let kindsOfTaskUpdateFirebase = Driver
      .combineLatest(kindsOfTask, firebaseKindsOfTask) { kindsOfTask, firebaseKindsOfTask -> [KindOfTask] in
        kindsOfTask.filter { kindOfTask -> Bool in
          // Если нет пользователя, то выходим
          guard Auth.auth().currentUser != nil else { return false }
          // Если не прогрузились задачи, то выходим
          guard let firebaseKindsOfTask = firebaseKindsOfTask else { return false }
          // если задачи нет в Firebase, то загружаем в Firebase
          guard let firebaseKindOfTask = firebaseKindsOfTask.first(where: { $0.UID == kindOfTask.UID }) else { return true }
          // если дата обновления задачи больше чем в Firebase, то обновляем Firebase
          return kindOfTask.lastModified.timeIntervalSince1970.rounded() > firebaseKindOfTask.lastModified.timeIntervalSince1970.rounded()
        }
      }
      .filter { !$0.isEmpty }
      .map { SyncData.updateFirebase(data: $0) }

    let kindsOfTaskUpdateCoreData = Driver
      .combineLatest(kindsOfTask, firebaseKindsOfTask) { kindsOfTask, firebaseKindsOfTask -> [KindOfTask] in
        firebaseKindsOfTask?.filter { firebaseKindOfTask -> Bool in
          // Если нет пользователя, то выходим
          guard Auth.auth().currentUser != nil else { return false }
          // если задачи нет в Core Data, то загружаем в Core Data
          guard let kindOfTask = kindsOfTask.first(where: { $0.UID == firebaseKindOfTask.UID }) else { return true }
          // если дата обновления задачи больше чем в Firebase, то обновляем Firebase
          return firebaseKindOfTask.lastModified.timeIntervalSince1970.rounded() > kindOfTask.lastModified.timeIntervalSince1970.rounded()
        } ?? []
      }
      .filter { !$0.isEmpty }
      .map { SyncData.updateCoreData(data: $0) }

    let kindsOfTaskSyncWhenLogIn = compactUser
      .withLatestFrom(allKindsOfTask) { user, allKindsOfTask -> [KindOfTask] in
        allKindsOfTask
        .filter { $0.userUID == nil }
        .map { kindOsTask -> KindOfTask in
          var kindOsTask = kindOsTask
          kindOsTask.userUID = user.uid
          return kindOsTask
        }
      }
      .filter { !$0.isEmpty }
      .map { SyncData.updateCoreData(data: $0) }

    let kindsOfTaskSyncWhenLogOut = Driver
      .combineLatest(user, allKindsOfTask) { user, allKindsOfTask -> Bool in
        user == nil && allKindsOfTask.filter { $0.userUID == nil }.isEmpty
      }
      .filter { $0 }
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
      .map { SyncData.updateCoreData(data: $0) }

    let syncDataKindsOfTask = Driver
      .of(
        kindsOfTaskSyncWhenLogIn,
        kindsOfTaskSyncWhenLogOut,
        kindsOfTaskUpdateFirebase,
        kindsOfTaskUpdateCoreData
      )
      .merge()

    syncDataKindsOfTask
      .drive()
      .disposed(by: disposeBag)

    // Update Firebase
    syncDataKindsOfTask
      .compactMap { syncData -> [KindOfTask] in
        guard case .updateFirebase(let kindsOfTask) = syncData else { return [] }
        return kindsOfTask
      }
      .filter { !$0.isEmpty }
      .withLatestFrom(compactUser) { kindsOfTask, user in
        dbUserRef.child(user.uid).child("KINDSOFTASK").runTransactionBlock { currentData in
          var dict: [String: AnyObject] = currentData.value as? [String: AnyObject] ?? [:]

          kindsOfTask.forEach { kindOfTask in
            dict[kindOfTask.UID] = kindOfTask.data as AnyObject
          }

          currentData.value = dict
          return TransactionResult.success(withValue: currentData)
        }
      }
      .drive()
      .disposed(by: disposeBag)

    // Update CoreData
    syncDataKindsOfTask
      .compactMap { syncData -> [KindOfTask] in
        guard case .updateCoreData(let kindsOfTask) = syncData else { return [] }
        return kindsOfTask
      }
      .filter { !$0.isEmpty }
      .asObservable()
      .flatMapLatest { managedContext.rx.batchUpdate($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .drive()
      .disposed(by: disposeBag)

    // MARK: - Sync Birds
    let birdsUpdateFirebase = Driver
      .combineLatest(birds, firebaseBirds) { birds, firebaseBirds -> [Bird] in
        birds.filter { bird -> Bool in
          // Если нет пользователя, то выходим
          guard Auth.auth().currentUser != nil else { return false }
          // Если не прогрузились задачи, то выходим
          guard let firebaseBirds = firebaseBirds else { return false }
          // если задачи нет в Firebase, то загружаем в Firebase
          guard let firebaseBird = firebaseBirds.first(where: { $0.UID == bird.UID }) else { return true }
          // если дата обновления задачи больше чем в Firebase, то обновляем Firebase
          return bird.lastModified.timeIntervalSince1970.rounded() > firebaseBird.lastModified.timeIntervalSince1970.rounded()
        }
      }
      .filter { !$0.isEmpty }
      .map { SyncData.updateFirebase(data: $0) }

    let birdsUpdateCoreData = Driver
      .combineLatest(birds, firebaseBirds) { birds, firebaseBirds -> [Bird] in
        firebaseBirds?
          .filter { firebaseBird -> Bool in
            // Если нет пользователя, то выходим
            guard Auth.auth().currentUser != nil else { return false }
            // если задачи нет в Core Data, то загружаем в Core Data
            guard let bird = birds.first(where: { $0.UID == firebaseBird.UID }) else { return true }
            // если дата обновления задачи больше чем в Firebase, то обновляем Firebase
            return firebaseBird.lastModified.timeIntervalSince1970.rounded() > bird.lastModified.timeIntervalSince1970.rounded()
          }
          .compactMap { firebaseBird -> Bird? in
            guard var bird = birds.first(where: { $0.UID == firebaseBird.UID }) else { return nil }
            bird.isBought = firebaseBird.isBought
            bird.lastModified = firebaseBird.lastModified
            return bird
          } ?? []
      }
      .filter { !$0.isEmpty }
      .map { SyncData.updateCoreData(data: $0) }

    let birdsSyncWhenLogIn = compactUser
      .withLatestFrom(allBirds) { user, allBirds -> [Bird] in
        allBirds
          .filter { $0.userUID == nil }
          .map { bird -> Bird in
            var bird = bird
            bird.userUID = user.uid
            return bird
          }
      }
      .filter { !$0.isEmpty }
      .map { SyncData.updateCoreData(data: $0) }

    let birdsSyncWhenLogOut = Driver
      .combineLatest(user, allBirds) { user, allBirds -> Bool in
        user == nil && allBirds.filter { $0.userUID == nil }.isEmpty
      }
      .filter { $0 }
      .map { _ -> [Bird] in
        self.initialBirds()
      }
      .map { SyncData.updateCoreData(data: $0) }

    let syncDataBirds = Driver
      .of(
        birdsSyncWhenLogIn,
        birdsSyncWhenLogOut,
        birdsUpdateFirebase,
        birdsUpdateCoreData
      )
      .merge()

    syncDataBirds
      .drive()
      .disposed(by: disposeBag)

    // Update Firebase
    syncDataBirds
      .compactMap { syncData -> [Bird] in
        guard case .updateFirebase(let birds) = syncData else { return [] }
        return birds
      }
      .filter { !$0.isEmpty }
      .withLatestFrom(compactUser) { birds, user in
        dbUserRef.child(user.uid).child("BIRDS").runTransactionBlock { currentData in
          var dict: [String: AnyObject] = currentData.value as? [String: AnyObject] ?? [:]

          birds.forEach { bird in
            dict[bird.UID] = bird.data as AnyObject
          }

          currentData.value = dict
          return TransactionResult.success(withValue: currentData)
        }
      }
      .drive()
      .disposed(by: disposeBag)

    // Update CoreData
    syncDataBirds
      .compactMap { syncData -> [Bird] in
        guard case .updateCoreData(let birds) = syncData else { return [] }
        return birds
      }
      .filter { !$0.isEmpty }
      .asObservable()
      .flatMapLatest { managedContext.rx.batchUpdate($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .drive()
      .disposed(by: disposeBag)
  }

  func initialBirds() -> [Bird] {
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
}
