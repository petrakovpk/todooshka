//
//  UserAPIService.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.04.2023.
//

import Alamofire
import FirebaseAuth
import Foundation
import RxAlamofire
import RxCocoa
import RxSwift

protocol HasCurrentUserService {
  var currentUserService: CurrentUserService { get }
}

class CurrentUserService {
  
  private let disposeBag = DisposeBag()
  
  public let user: Driver<User?>
  public let extUserData: Driver<UserExtData?>
  public let kinds: Driver<[Kind]>
  public let kindColors: Driver<[UIColor]>
  public let kindIcons: Driver<[Icon]>
  public let tasks: Driver<[Task]>
  public let publications: Driver<[Publication]>
  public let quests: Driver<[Quest]>
  public let publicKinds: Driver<[PublicKind]>
  public let questImages: Driver<[QuestImage]>
  public let publicationImages: Driver<[PublicationImage]>
  
  public let dismissTrigger = PublishRelay<Void>()
  
  init() {
    
    user = Auth.auth().rx.stateDidChange
      .asDriver(onErrorJustReturn: nil)
    
    // Анонимный вход
    let currentUserPredicate = user
      .map { user -> NSPredicate in
        if let uid = user?.uid {
          return NSPredicate(format: "userUID == %@", uid)
        } else {
          return NSPredicate(format: "userUID == nil")
        }
      }
    
    extUserData = user
      .compactMap { $0 }
      .flatMapLatest { currentUser -> Driver<UserExtData?> in
        currentUser.fetchUserExtData().asDriverOnErrorJustComplete()
      }
    
    extUserData
      .filter { $0 == nil }
      .withLatestFrom(user)
      .compactMap { $0 }
      .map { user -> UserExtData in
        UserExtData(uid: user.uid)
      }
      .flatMapLatest { userExtData -> Driver<Void> in
        StorageManager.shared.managedContext.rx.update(userExtData)
          .asDriverOnErrorJustComplete()
      }
      .drive()
      .disposed(by: disposeBag)


    
    kinds = currentUserPredicate
      .flatMapLatest { predicate -> Driver<[Kind]>  in
        StorageManager.shared.managedContext.rx
          .entities(Kind.self, predicate: predicate)
          .asDriverOnErrorJustComplete()
      }
      .map { kinds -> [Kind] in
        kinds.sorted { $0.index < $1.index }
      }
    
    tasks = currentUserPredicate
      .flatMapLatest { predicate -> Driver<[Task]> in
        StorageManager.shared.managedContext.rx
          .entities(Task.self, predicate: predicate)
          .asDriverOnErrorJustComplete()
      }
    
    publications = currentUserPredicate
      .flatMapLatest { predicate -> Driver<[Publication]> in
        StorageManager.shared.managedContext.rx
          .entities(Publication.self, predicate: predicate)
          .asDriverOnErrorJustComplete()
      }
      .map { publications -> [Publication] in
        publications.sorted { ($0.published ?? $0.created) > ($1.published ?? $1.created) }
      }
    
    publicKinds = StorageManager.shared.managedContext.rx
      .entities(PublicKind.self)
      .asDriver(onErrorJustReturn: [])
    
    quests = StorageManager.shared.managedContext.rx
      .entities(Quest.self)
      .asDriver(onErrorJustReturn: [])
    
    questImages = StorageManager.shared.managedContext.rx
      .entities(QuestImage.self)
      .asDriver(onErrorJustReturn: [])
    
    publicationImages = StorageManager.shared.managedContext.rx
      .entities(PublicationImage.self)
      .asDriver(onErrorJustReturn: [])
    
    publicKinds
      .asObservable()
      .take(1)
      .filter { $0.isEmpty }
      .map { _ in InitialData.publicKinds }
      .flatMapLatest { publicKinds -> Observable<Void> in
        StorageManager.shared.managedContext.rx.batchUpdate(publicKinds)
      }
      .subscribe()
      .disposed(by: disposeBag)
    
    currentUserPredicate
      .asObservable()
      .take(1)
      .flatMapLatest { predicate -> Observable<[Kind]> in
        StorageManager.shared.managedContext.rx.entities(Kind.self, predicate: predicate)
      }
    // только если у него нет пустых задач
      .filter { $0.isEmpty }
      .map { _ in InitialData.kinds }
      .flatMapLatest { kinds -> Observable<Void> in
        StorageManager.shared.managedContext.rx.batchUpdate(kinds)
      }
      .subscribe()
      .disposed(by: disposeBag)
  
    
    kindColors = Driver<[UIColor]>.of([
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
    
    kindIcons = Driver<[Icon]>.of([
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
  }
}
