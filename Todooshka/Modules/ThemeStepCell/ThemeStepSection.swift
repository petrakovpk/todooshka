//
//  ThemeStepSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.11.2022.
//

import RxDataSources

struct ThemeStepSection: AnimatableSectionModelType {
    var identity: String { header }
    var header: String
    var items: [ThemeStep]

    init(header: String, items: [ThemeStep]) {
        self.header = header
        self.items = items
    }

    init(original: ThemeStepSection, items: [ThemeStep]) {
        self = original
        self.items = items
    }
}

