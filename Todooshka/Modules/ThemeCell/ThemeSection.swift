//
//  ThemeSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 31.10.2022.
//

import RxDataSources

struct ThemeSection: AnimatableSectionModelType {

    var identity: String { header }
    var header: String
    var items: [ThemeItem]

    init(header: String, items: [ThemeItem]) {
        self.header = header
        self.items = items
    }

    init(original: ThemeSection, items: [ThemeItem]) {
        self = original
        self.items = items
    }
}
