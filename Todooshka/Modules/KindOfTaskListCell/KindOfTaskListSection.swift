//
//  KindOfTaskListSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.
//

import RxDataSources

struct KindOfTaskListSection: AnimatableSectionModelType {
    var identity: String { header }

    var header: String
    var items: [KindOfTask]

    init(header: String, items: [KindOfTask]) {
        self.header = header
        self.items = items
    }

    init(original: KindOfTaskListSection, items: [KindOfTask]) {
        self = original
        self.items = items
    }
}
