//
//  KindOfTaskIconSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

struct KindOfTaskIconItem: IdentifiableType, Equatable {
  
  var identity: String { icon.rawValue + isSelected.string }
  
  var icon: Icon
  var isSelected: Bool

}

struct KindOfTaskIconSectionModel: AnimatableSectionModelType {
  
  var identity: String {
    return header
  }
  
  var header: String
  var items: [KindOfTaskIconItem]
  
  init(header: String, items: [KindOfTaskIconItem]) {
    self.header = header
    self.items = items
  }
  
  init(original: KindOfTaskIconSectionModel, items: [KindOfTaskIconItem]) {
    self = original
    self.items = items
  }
}
