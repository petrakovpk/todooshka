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
  let goldTasks: Driver<[Task]>
  let icons: Driver<[Icon]>
  let firebaseBirds: Driver<[BirdFirebase]>
  let feathersCount: Driver<Int>
  let firebaseTasks: Driver<[Task]>
  let firebaseKindsOfTask: Driver<[KindOfTask]>
  let kindsOfTask: Driver<[KindOfTask]>
  let nestDataSource: Driver<[EggActionType]>
  let reloadNestScene = BehaviorRelay<Void>(value: ())
  let selectedDate = BehaviorRelay<Date>(value: Date())
  let tasks: Driver<[Task]>
  let user: Driver<User?>
  let compactUser: Driver<User>
  
  // MARK: - Init
  init() {
    
    let context = appDelegate.persistentContainer.viewContext
    
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

    user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
    
    compactUser = user
      .compactMap{ $0 }
    
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

    kindsOfTask = Driver.combineLatest(user, allKindsOfTask) { user, kindsOfTask -> [KindOfTask] in
      kindsOfTask.filter{ $0.userUID == user?.uid }
    }
    
    tasks = Driver.combineLatest(user, allTasks) { user, tasks -> [Task] in
      tasks.filter{ $0.userUID == user?.uid }
    }
    
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
    
    diamonds.drive().disposed(by: disposeBag)
    birds.drive().disposed(by: disposeBag)
    kindsOfTask.drive().disposed(by: disposeBag)
    tasks.drive().disposed(by: disposeBag)
    goldTasks.drive().disposed(by: disposeBag)
    feathersCount.drive().disposed(by: disposeBag)
    
    
    // при открытии проверяем и делаем все плановые задачи с плановой датой выполнения == сегодня задачи в работе
    tasks
      .map{ $0.filter{ $0.status == .Planned } }
      .map{ $0.filter{ $0.planned != nil } }
      .map{ $0.filter{ Calendar.current.isDate($0.planned!, inSameDayAs: Date()) } }
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

    // MARK: - Clear
    allTasks
      .map { $0.filter { $0.status == .Archive } }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.delete($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    allKindsOfTask
      .map { $0.filter { $0.status == .Archive } }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.delete($0) })
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
    
    let crackActions = completedTasks
      .map { $0.prefix(7) } // берем первые 7 выполненных задач
      .map { Array($0) }
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
          switch bird.clade {
          case .Dragon:
            return bird.isBought ? bird.style : nil
          default:
            return bird.isBought ? bird.style : .Simple
          }
        }
      }
      .map { styles -> [EggActionType] in // получаем действия
        styles.map{ .Crack(style: $0) }
      }.startWith([])
    
    let noCrackActions = inProgressTasks
      .map { $0.prefix(7) } // берем первые 7 выполненных задач
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
      .combineLatest(crackActions, noCrackActions, hideEggsActions) { crackActions, noCrackActions, hideEggsActions -> [EggActionType] in
        crackActions + noCrackActions + hideEggsActions
      }.map { $0.prefix(7) }
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
    // присваиваем userUID при первом входе в аккаунт всем пустым задачам
    let tasksWithoutUser = allTasks
      .map { $0.filter { $0.userUID == nil } }
    
    let kindsOfTaskWithoutUser = allKindsOfTask
      .map { $0.filter { $0.userUID == nil } }
    
    let birdsWithoutUser = birds
      .map { $0.filter { $0.userUID == nil } }

    compactUser
      .withLatestFrom(tasksWithoutUser) { user, tasks -> [Task] in
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

    compactUser
      .withLatestFrom(kindsOfTaskWithoutUser) { user, kindsOfTask -> [KindOfTask] in
        kindsOfTask.map { kindOfTask -> KindOfTask in
          var kindOfTask = kindOfTask
          kindOfTask.userUID = user.uid
          return kindOfTask
        }
      }.asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    compactUser
      .withLatestFrom(birdsWithoutUser) { user, birds -> [Bird] in
        birds.map { bird -> Bird in
          var bird = bird
          bird.userUID = user.uid
          return bird
        }
      }.asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ context.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    // скачиваем из облака когда пользователь заходит в аккаунт
    firebaseTasks = compactUser
      .asObservable()
      .flatMapLatest({ user -> Observable<DataSnapshot> in
        DB_USERS_REF.child(user.uid).child("TASKS").rx.observeEvent(.value)
      })
      .compactMap{ $0.children.allObjects as? [DataSnapshot] }
      .map({ $0.compactMap { Task(snapshot: $0) } })
      .asDriver(onErrorJustReturn: [])
    
    firebaseKindsOfTask = compactUser
      .asObservable()
      .flatMapLatest({ user -> Observable<DataSnapshot>  in
        DB_USERS_REF.child(user.uid).child("KINDSOFTASK").rx.observeEvent(.value)
      })
      .compactMap{ $0.children.allObjects as? [DataSnapshot] }
      .map({ $0.compactMap { KindOfTask(snapshot: $0) } })
      .asDriver(onErrorJustReturn: [])
    
    firebaseBirds = compactUser
      .asObservable()
      .flatMapLatest({ user -> Observable<DataSnapshot>  in
        DB_USERS_REF.child(user.uid).child("BIRDS").rx.observeEvent(.value)
      })
      .compactMap{ $0.children.allObjects as? [DataSnapshot] }
      .map({ $0.compactMap { BirdFirebase(snapshot: $0) } })
      .asDriver(onErrorJustReturn: [])

    firebaseBirds.drive().disposed(by: disposeBag)
    firebaseTasks.drive().disposed(by: disposeBag)
    firebaseKindsOfTask.drive().disposed(by: disposeBag)
    
    firebaseTasks
      .withLatestFrom(tasks) { firebaseTasks, tasks -> [Task] in
        firebaseTasks
          .filter{ $0.status != .Archive }
          .filter{ firebaseTask in
            // или нет воообще на устройстве такого таска
            tasks.contains{ $0.UID == firebaseTask.UID } == false
            // или таск на устройстве более старый
            || tasks.contains{ $0.UID == firebaseTask.UID && $0.lastModified < firebaseTask.lastModified }
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
    
    firebaseTasks
      .withLatestFrom(tasks) { firebaseTasks, tasks -> [Task] in
        firebaseTasks
          .filter{ $0.status == .Archive }
          .filter{ firebaseTask in
            // если на устройстве еще не удалено
            tasks.contains{ $0.UID == firebaseTask.UID && $0.lastModified < firebaseTask.lastModified }
          }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ task -> Observable<Result<Void, Error>> in
        context.rx.delete(task)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    firebaseKindsOfTask
      .withLatestFrom(kindsOfTask) { firebaseKindsOfTask, kindsOfTask -> [KindOfTask] in
        firebaseKindsOfTask
          .filter{ $0.status != .Archive }
          .filter{ firebaseKindOfTask in
            // или нет воообще на устройстве такого таска
            kindsOfTask.contains{ $0.UID == firebaseKindOfTask.UID } == false
            // или таск на устройстве более старый
            || kindsOfTask.contains{ $0.UID == firebaseKindOfTask.UID && $0.lastModified < firebaseKindOfTask.lastModified }
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
    
    firebaseKindsOfTask
      .withLatestFrom(kindsOfTask) { firebaseKindsOfTask, kindsOfTask -> [KindOfTask] in
        firebaseKindsOfTask
          .filter{ $0.status == .Archive }
          .filter{ firebaseKindOfTask in
            kindsOfTask.contains{ $0.UID == firebaseKindOfTask.UID && $0.lastModified < firebaseKindOfTask.lastModified }
          }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .flatMapLatest({ kindOfTask -> Observable<Result<Void, Error>> in
        context.rx.delete(kindOfTask)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
      .drive()
      .disposed(by: disposeBag)
    
    firebaseBirds
      .withLatestFrom(birds) { firebaseBirds, birds -> [BirdFirebase] in
        firebaseBirds
          .filter{ firebaseBird in
            // или нет воообще на устройстве такого таска
            birds.contains{ $0.UID == firebaseBird.UID } == false
            // или таск на устройстве более старый
            || birds.contains{ $0.UID == firebaseBird.UID && $0.lastModified < firebaseBird.lastModified }
          }
      }
      .withLatestFrom(birds) { firebaseBirds, birds -> [Bird] in
        firebaseBirds.compactMap { firebaseBird -> Bird? in
          guard var bird = birds.first(where: { $0.UID == firebaseBird.UID }) else { return nil }
          bird.isBought = firebaseBird.isBought
          bird.lastModified = firebaseBird.lastModified
          return bird
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
    
    // загружаем в облако
    Driver
      .combineLatest(tasks, firebaseTasks) { tasks, firebaseTasks -> [Task] in
        tasks.filter { task in
          // или нет воообще в файрбейзе нет такого таска
          firebaseTasks.contains{ $0.UID == task.UID } == false
          // или таск на файрьейзе более старый
          || firebaseTasks.contains{ $0.UID == task.UID && $0.lastModified < task.lastModified }
        }
      }
      .asObservable()
      .flatMapLatest({  Observable.from($0) })
      .withLatestFrom(compactUser) { task, user in
        DB_USERS_REF.child(user.uid).child("TASKS").child(task.UID).updateChildValues(task.data)
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
    
    Driver
      .combineLatest(kindsOfTask, firebaseKindsOfTask) { kindsOfTask, firebaseKindsOfTask -> [KindOfTask] in
        kindsOfTask.filter { kindOfTask in
          // или нет воообще в файрбейзе нет такого таска
          firebaseKindsOfTask.contains{ $0.UID == kindOfTask.UID } == false
          // или таск на файрьейзе более старый
          || firebaseKindsOfTask.contains{ $0.UID == kindOfTask.UID && $0.lastModified < kindOfTask.lastModified }
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .withLatestFrom(compactUser) { task, user in
        DB_USERS_REF.child(user.uid).child("KINDSOFTASK").child(task.UID).updateChildValues(task.data)
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
    
    Driver
      .combineLatest(birds, firebaseBirds) { birds, firebaseBirds -> [Bird] in
        birds.filter { bird in
          // или нет воообще в файрбейзе нет такого таска
          firebaseBirds.contains{ $0.UID == bird.UID } == false
          // или таск на файрьейзе более старый
          || firebaseBirds.contains{ $0.UID == bird.UID && $0.lastModified < bird.lastModified }
        }
      }
      .asObservable()
      .flatMapLatest({ Observable.from($0) })
      .withLatestFrom(compactUser) { bird, user in
        DB_USERS_REF.child(user.uid).child("BIRDS").child(bird.UID).updateChildValues(bird.data)
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
  }
}
