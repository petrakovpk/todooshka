//
//  TaskTypesListSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 30.06.2021.
//


import RxDataSources
import UIKit

struct TaskTypesListSectionModel: AnimatableSectionModelType {
    
    var identity: String {
        return header
    }
    
    var header: String
    var items: [TaskType]
    
    init(header: String, items: [TaskType]) {
        self.header = header
        self.items = items
    }
    
    init(original: TaskTypesListSectionModel, items: [TaskType]) {
        self = original
        self.items = items
    }
}

