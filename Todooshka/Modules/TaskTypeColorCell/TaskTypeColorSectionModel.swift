//
//  TaskTypeColorSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

struct TaskTypeColorItem: IdentifiableType, Equatable {
    
    //MARK: - Properties
    var color: UIColor
    
    //MARK: - Identity
    var identity: String { return UUID().uuidString }
}

struct TaskTypeColorSectionModel: AnimatableSectionModelType {
    
    var identity: String {
        return header
    }
    
    var header: String
    var items: [TaskTypeColorItem]
    
    init(header: String, items: [TaskTypeColorItem]) {
        self.header = header
        self.items = items
    }
    
    init(original: TaskTypeColorSectionModel, items: [TaskTypeColorItem]) {
        self = original
        self.items = items
    }
}
