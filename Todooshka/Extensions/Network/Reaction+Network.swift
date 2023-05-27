//
//  Reaction+APIManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import RxCocoa
import RxSwift

extension Reaction {
  func saveToServer() -> Observable<Void> {
    NetworkManager.shared
      .performPutRequest(
        endpoint: APIConfig.Reaction.urlForUserPublicationReaction(reactionUUID: self.uuid),
        codableObject: self
      )
  }
}

