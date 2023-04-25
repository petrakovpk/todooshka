//
//  FunItemTask.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import RxDataSources

struct FunItemTask {
  var author: Author?
  var task: Task
  var image: UIImage?
  var reactionType: ReactionType?
  var isLoading: Bool
}

extension FunItemTask: IdentifiableType {
  var identity: String {
    task.uuid.uuidString
  }
}

extension FunItemTask: Equatable {
  static func ==(lhs: FunItemTask, rhs: FunItemTask) -> Bool {
    return lhs.author == rhs.author &&
    lhs.task == rhs.task &&
    lhs.image == rhs.image &&
    lhs.reactionType == rhs.reactionType &&
    lhs.isLoading == rhs.isLoading
  }
}


