//
//  Reaction+Fetchable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 08.04.2023.
//

import FirebaseAuth
import RxCocoa
import RxSwift

extension Task {
  
  func fetchTaskUser() -> Observable<Author?> {
    return APIManager.shared.performFetchRequest(endpoint: APIConfig.urlForTaskUser(taskID: self.uuid))
  }

  func fetchTaskImage() -> Observable<UIImage?> {
    return APIManager.shared.performFetchImageRequest(endpoint: APIConfig.urlForTaskImage(taskID: self.uuid))
  }
  
  func fetchTaskReactions() -> Observable<[Reaction]> {
    return APIManager.shared.performFetchArrayRequest(endpoint: APIConfig.urlForTaskReactions(taskID: self.uuid))
  }
  
  func fetchTaskReactionForCurrentUser() -> Observable<Reaction?> {
    return APIManager.shared.performFetchRequest(endpoint: APIConfig.urlForTaskReactionForCurrentUser(taskID: self.uuid))
    }
}
