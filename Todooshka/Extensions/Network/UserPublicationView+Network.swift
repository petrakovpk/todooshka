//
//  UserPublicationView+Network.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.05.2023.
//

import RxCocoa
import RxSwift

extension UserPublicationView {
  func saveToServer() -> Observable<Void> {
    NetworkManager.shared
      .performPutRequest(
        endpoint: APIConfig.UserPublicationView.urlForUserPublicationView(),
        codableObject: self)
  }
}
