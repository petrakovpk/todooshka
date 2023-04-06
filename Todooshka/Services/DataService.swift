//
//  TasksService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.02.2022.
//

import Alamofire
import CoreData
import CoreMedia
import Firebase
import RxSwift
import RxCocoa
import YandexMobileMetrica
import RxAlamofire

enum SyncData<T: Persistable> {
  case updateCoreData(data: [T])
  case updateFirebase(data: [T])
}

protocol HasDataService {
  var dataService: DataService { get }
}

class DataService {
  // context
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


    let managedContext = appDelegate.persistentContainer.viewContext
    
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
    
    
    
    let allBirds = managedContext
      .rx
      .entities(Bird.self)
      .asDriver(onErrorJustReturn: [])
    
    let allTasks = managedContext
      .rx
      .entities(Task.self)
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
      .map { $0.filter { $0.completed != nil } }
      .map { $0.sorted { $0.completed! < $1.completed! } }     // сортируем их по дате закрытия
      .map { Dictionary(grouping: $0) { $0.completed!.startOfDay } } // превращаем в дикт по дате
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
    
    // MARK: - Bird
    let openedBirds = birds
      .map { $0.filter { $0.isBought } }
    
    // закрываем самую дорогую птицу если не хватает перышек (такое бывает при удалении выполненных задач)
    let openedBirdSum = birds
      .map { $0.filter { $0.isBought } }
      .map { $0.map { $0.price }.sum() }
    
    // MARK: - Nest DataSource
    let completedTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { $0.status == .completed }
          .filter { $0.completed != nil }
          .filter { Calendar.current.isDate($0.completed!, inSameDayAs: Date()) }
          .sorted { $0.completed! < $1.completed! }
      }
    
    let inProgressTasks = tasks
      .map { tasks -> [Task] in
        tasks
          .filter { $0.status == .inProgress }
          .filter { $0.planned.startOfDay == Date().startOfDay }
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
          .filter { $0.completed != nil }
          .filter { Calendar.current.isDate($0.completed!, inSameDayAs: selectedDate ) }
          .sorted { $0.completed! < $1.completed! }
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
}
