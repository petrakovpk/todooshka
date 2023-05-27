//
//  User+Network.swift
//  DragoDo
//
//  Created by Pavel Petakov on 26.05.2023.
//

import FirebaseAuth
import RxCocoa
import RxSwift

extension User {
  func fetchRecommendedPublications() -> Observable<[Publication]> {
    NetworkManager.shared.performFetchRequestArrayOfCodableObjects(
      endpoint: APIConfig.User.urlForRecommendedPublications(userUID: self.uid)
    )
  }
}
