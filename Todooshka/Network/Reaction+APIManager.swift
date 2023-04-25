//
//  Reaction+APIManager.swift
//  DragoDo
//
//  Created by Pavel Petakov on 14.04.2023.
//

import RxCocoa
import RxSwift

extension Reaction {
  func putReactionToCloud() -> Observable<Void> {
    return APIManager.shared.performPutRequest(endpoint: APIConfig.urlForReaction(reactionUUID: self.uuid), codableObject: self)
  }
}

