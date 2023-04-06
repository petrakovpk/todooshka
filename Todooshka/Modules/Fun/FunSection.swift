//
//  FunSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 06.03.2023.
//

import RxDataSources

struct FunSection {
    var header: String
    var items: [FunItem]

    init(header: String, items: [FunItem]) {
        self.header = header
        self.items = items
    }

    init(original: FunSection, items: [FunItem]) {
        self = original
        self.items = items
    }
}

extension FunSection: AnimatableSectionModelType {
  var identity: String {
    header
  }
}
