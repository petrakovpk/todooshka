//
//  FunSectionItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import RxDataSources

struct FunItem {
  let author: Author
  let task: Task
  let image: UIImage
}
 
extension FunItem: IdentifiableType {
  var identity: String {
    author.uid + task.uuid.uuidString
  }
}

extension FunItem: Equatable {
  static func == (lhs: FunItem, rhs: FunItem) -> Bool {
    lhs.identity == rhs.identity
  }
}
