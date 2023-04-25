//
//  UserAPIService.swift
//  DragoDo
//
//  Created by Pavel Petakov on 05.04.2023.
//
import Foundation
import Alamofire
import RxAlamofire
import FirebaseAuth
import RxCocoa
import RxSwift

protocol HasCurrentUserService {
  var currentUserService: CurrentUserService { get }
}

class CurrentUserService {
  
  let currentUserKinds: Driver<[Kind]>
  let currentUserTasks: Driver<[Task]>
  let currentUserEmptyKind: Driver<Kind>
  let currentUserColors: Driver<[UIColor]>
  let currentUserIcons: Driver<[Icon]>
  
  init() {
    let currentUserPredicate = Auth.auth().rx.stateDidChange
      .map { user -> NSPredicate in
        if let uid = user?.uid {
          return NSPredicate(format: "userUID == %@", uid)
        } else {
          return NSPredicate(format: "userUID == nil")
        }
      }
    
    currentUserKinds = currentUserPredicate
      .flatMapLatest { predicate -> Observable<[Kind]>  in
        StorageManager.shared.managedContext.rx.entities(Kind.self, predicate: predicate)
      }
      .map { kinds -> [Kind] in
        kinds.sorted { $0.index < $1.index }
      }
      .asDriver(onErrorJustReturn: [])
    
    currentUserTasks = currentUserPredicate
      .flatMapLatest { predicate -> Observable<[Task]>  in
        StorageManager.shared.managedContext.rx.entities(Task.self, predicate: predicate)
      }
      .asDriver(onErrorJustReturn: [])
    
    currentUserEmptyKind = currentUserKinds
      .compactMap { kinds -> Kind? in
        kinds.first(where: { $0.isEmptyKind })
      }
    
    currentUserColors = Driver<[UIColor]>.of([
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
    
    currentUserIcons = Driver<[Icon]>.of([
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
