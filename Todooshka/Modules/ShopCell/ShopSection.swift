//
//  ShopSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 02.02.2022.
//

import RxDataSources

struct ShopSection: AnimatableSectionModelType {

  // MARK: - Properties
  var header: String
  var items: [Bird]
  
  // MARK: - Computed properties
  var identity: String {
    return header
  }
  
  // MARK: - Init
  init(header: String, items: [Bird]) {
      self.header = header
      self.items = items
  }
  
  init(original: ShopSection, items: [Bird]) {
      self = original
      self.items = items
  }
}
