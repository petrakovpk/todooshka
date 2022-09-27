//
//  KindOfTaskSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.05.2022.
//

import RxDataSources

struct KindOfTaskSection: AnimatableSectionModelType {
    
    var identity: String {
      header
    }
    
    var header: String
    var items: [KindOfTaskItem]
    
    init(header: String, items: [KindOfTaskItem]) {
        self.header = header
        self.items = items
    }
    
    init(original: KindOfTaskSection, items: [KindOfTaskItem]) {
        self = original
        self.items = items
    }
}
