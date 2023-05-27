//
//  Reaction+Fetchable.swift
//  DragoDo
//
//  Created by Pavel Petakov on 08.04.2023.
//

import FirebaseAuth
import RxCocoa
import RxSwift

extension Publication {
  func fetchUnsafeImage() -> Observable<UIImage?> {
    NetworkManager.shared
      .performUnsafeFetchRequestSingleImage(endpoint: APIConfig.Publication.urlForUnsafeImage(publicationUUID: self.uuid.uuidString))
  }
}
