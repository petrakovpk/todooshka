//
//  NetworkService.swift
//  DragoDo
//
//  Created by Pavel Petakov on 16.11.2022.
//

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
    RxAlamofire.requestData(.get, "http://185.182.110.164/task/all")
      .debug()
      .asDriverOnErrorJustComplete()
      .drive()
      .disposed(by: disposeBag)
  }
}
