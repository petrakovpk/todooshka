//
//  KindOfTaskListSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.
//

import RxDataSources

struct KindListSection: AnimatableSectionModelType {
    var header: String
    var items: [KindListItem]

    init(header: String, items: [KindListItem]) {
        self.header = header
        self.items = items
    }

    init(original: KindListSection, items: [KindListItem]) {
        self = original
        self.items = items
    }
}

extension KindListSection: IdentifiableType {
  var identity: String {
    return header
  }
}
