//
//  KindOfTaskListSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.08.2021.
//

import RxDataSources

struct KindOfTaskListSectionModel: AnimatableSectionModelType {
    
    var identity: String {
      return header
    }
    
    var header: String
    var items: [KindOfTask]
    
    init(header: String, items: [KindOfTask]) {
        self.header = header
        self.items = items
    }
    
    init(original: KindOfTaskListSectionModel, items: [KindOfTask]) {
        self = original
        self.items = items
    }
}
