//
//  FunSectionItem.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import RxDataSources

struct FunSectionItem {
  let autorUID: String
  let authorName: String
  let authorImage: UIImage
  let taskUID: String
  let text: String
  let image: UIImage
}
 
extension FunSectionItem: IdentifiableType {
  var identity: String {
    autorUID + taskUID
  }
}

extension FunSectionItem: Equatable {
  static func == (lhs: FunSectionItem, rhs: FunSectionItem) -> Bool {
    lhs.identity == rhs.identity
  }
}
