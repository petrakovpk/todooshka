//
//  Observable+User+APIManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 09.04.2023.
//

import FirebaseAuth
import RxCocoa
import RxSwift

extension User {
  func fetchRecommendedTasks() -> Observable<[Task]> {
    return APIManager.shared.performFetchArrayRequest(endpoint: APIConfig.urlForUserRecommendedTasks(userUID: self.uid))
  }
}
