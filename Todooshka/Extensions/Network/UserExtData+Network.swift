//
//  UserExtData+Network.swift
//  DragoDo
//
//  Created by Pavel Petakov on 26.05.2023.
//

import RxCocoa
import RxSwift

extension UserExtData {
  func putUserToCloud() -> Observable<Void> {
    NetworkManager.shared
      .performPutRequest(
        endpoint: APIConfig.UserExtData.urlForUpdateUser(userUID: self.uid),
        codableObject: self)
  }
}
