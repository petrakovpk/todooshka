//
//  ThemeTypeSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 21.11.2022.
//

import RxDataSources

struct ThemeTypeSection: AnimatableSectionModelType {
    var identity: String { header }
    var header: String
    var items: [ThemeTypeItem]

    init(header: String, items: [ThemeTypeItem]) {
        self.header = header
        self.items = items
    }

    init(original: ThemeTypeSection, items: [ThemeTypeItem]) {
        self = original
        self.items = items
    }
}


