//
//  TaskTypeListSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.
//

import RxDataSources

struct TaskTypeListSectionModel: AnimatableSectionModelType {
    
    var identity: String {
        return header
    }
    
    var header: String
    var items: [TaskType]
    
    init(header: String, items: [TaskType]) {
        self.header = header
        self.items = items
    }
    
    init(original: TaskTypeListSectionModel, items: [TaskType]) {
        self = original
        self.items = items
    }
}
