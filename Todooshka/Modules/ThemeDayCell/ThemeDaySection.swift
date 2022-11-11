//
//  ThemeDaySection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import RxDataSources

struct ThemeDaySection: AnimatableSectionModelType {
    var identity: String { header }
    var header: String
    var items: [ThemeDay]

    init(header: String, items: [ThemeDay]) {
        self.header = header
        self.items = items
    }

    init(original: ThemeDaySection, items: [ThemeDay]) {
        self = original
        self.items = items
    }
}

