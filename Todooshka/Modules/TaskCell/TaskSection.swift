//
//  TaskSection.swift
//  DragoDo
//
//  Created by Pavel Petakov on 11.01.2023.
//

import RxDataSources

struct TaskSection: AnimatableSectionModelType {
    var identity: String { header }

    var header: String
    var items: [TaskSectionItem]

    init(header: String, items: [TaskSectionItem]) {
        self.header = header
        self.items = items
    }

    init(original: TaskSection, items: [TaskSectionItem]) {
        self = original
        self.items = items
    }
}

