//
//  QuestImage.swift
//  DragoDo
//
//  Created by Pavel Petakov on 12.05.2023.
//

import UIKit

struct QuestImage {
  let uuid: UUID
  let questUUID: UUID
  let image: UIImage
  var rank: Int = 0
}

extension QuestImage: Equatable {

}

