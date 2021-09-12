//
//  TaskTypeIconSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

struct TaskTypeIconItem: IdentifiableType, Equatable {
  
  //MARK: - Properties
  var imageName: String
  var image: UIImage? {
    return UIImage(named: imageName)?.template
  }
  
  //MARK: - Identity
  var identity: String { return UUID().uuidString }
}

struct TaskTypeIconSectionModel: AnimatableSectionModelType {
  
  var identity: String {
    return header
  }
  
  var header: String
  var items: [TaskTypeIconItem]
  
  init(header: String, items: [TaskTypeIconItem]) {
    self.header = header
    self.items = items
  }
  
  init(original: TaskTypeIconSectionModel, items: [TaskTypeIconItem]) {
    self = original
    self.items = items
  }
}
