//
//  KindOfTaskIForBirdSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.05.2022.
//

import RxDataSources

struct KindOfTaskForBirdSection: AnimatableSectionModelType {
    
    var identity: String { header }
    
    var header: String
    var items: [KindOfTaskForBirdItem]
    
    init(header: String, items: [KindOfTaskForBirdItem]) {
        self.header = header
        self.items = items
    }
    
    init(original: KindOfTaskForBirdSection, items: [KindOfTaskForBirdItem]) {
        self = original
        self.items = items
    }
}

