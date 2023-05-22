//
//  FunItemTask.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import RxDataSources

struct FunItem {
  var userExtData: UserExtData?
  var task: Task
  var image: UIImage?
  var reactionType: ReactionType?
  var isLoading: Bool
}

extension FunItem: IdentifiableType {
  var identity: String {
    task.uuid.uuidString
  }
}

extension FunItem: Equatable {
  static func ==(lhs: FunItem, rhs: FunItem) -> Bool {
    return lhs.userExtData == rhs.userExtData &&
    lhs.task == rhs.task &&
    lhs.image == rhs.image &&
    lhs.reactionType == rhs.reactionType &&
    lhs.isLoading == rhs.isLoading
  }
}


