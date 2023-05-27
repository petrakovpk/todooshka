//
//  FunItemTask.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import RxDataSources

struct FunItem {
  var publication: Publication
  var image: UIImage?
  var isLoading: Bool = false
}

extension FunItem: IdentifiableType {
  var identity: String {
    publication.uuid.uuidString
  }
}

extension FunItem: Equatable {

}


