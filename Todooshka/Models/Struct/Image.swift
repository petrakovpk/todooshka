//
//  TDImage.swift
//  DragoDo
//
//  Created by Pavel Petakov on 02.03.2023.
//

import UIKit

struct Image {
  let uuid: UUID
  var imageData: Data
  
  var uiImage: UIImage {
    UIImage(data: self.imageData) ?? UIImage()
  }
  
}

extension Image: Equatable {
  static func == (lhs: Image, rhs: Image) -> Bool {
    return lhs.uuid == rhs.uuid
    && lhs.imageData == rhs.imageData
  }
}
