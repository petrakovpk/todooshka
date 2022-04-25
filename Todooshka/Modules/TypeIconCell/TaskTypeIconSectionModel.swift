//
//  TaskTypeIconSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

//struct TaskTypeIconItem: IdentifiableType, Equatable {
//
//  //MARK: - Properties
//  var icon: Icon
//
//  //MARK: - Identity
//  var identity: String { return UUID().uuidString }
//}

struct TaskTypeIconSectionModel: AnimatableSectionModelType {
  
  var identity: String {
    return header
  }
  
  var header: String
  var items: [Icon]
  
  init(header: String, items: [Icon]) {
    self.header = header
    self.items = items
  }
  
  init(original: TaskTypeIconSectionModel, items: [Icon]) {
    self = original
    self.items = items
  }
}
