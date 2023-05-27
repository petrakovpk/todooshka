//
//  NetworkService.swift
//  DragoDo
//
//  Created by Pavel Petakov on 16.11.2022.
//

import FirebaseAuth
import Foundation
import RxAlamofire
import RxCocoa
import RxSwift

protocol HasNetworkService {
  var networkService: NetworkService { get }
}

class NetworkService {
  let disposeBag = DisposeBag()
  
  init() {
    Auth.auth().rx.stateDidChange
      .compactMap { $0 }
      .map { user -> UserExtData in
        UserExtData(uid: user.uid, nickname: user.displayName)
      }
      .flatMapLatest { userExtData -> Observable<Void> in
        userExtData.putUserToCloud()
      }
      .asDriver(onErrorJustReturn: ())
      .drive()
      .disposed(by: disposeBag)
  }
}
