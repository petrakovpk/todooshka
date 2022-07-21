//
//  TypeSmallCollectionViewCellSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 04.05.2022.
//

import RxDataSources

struct TypeSmallCollectionViewCellSectionModel: AnimatableSectionModelType {
    
    var identity: String {
      return header
    }
    
    var header: String
    var items: [TypeSmallCollectionViewCellSectionModelItem]
    
    init(header: String, items: [TypeSmallCollectionViewCellSectionModelItem]) {
        self.header = header
        self.items = items
    }
    
    init(original: TypeSmallCollectionViewCellSectionModel, items: [TypeSmallCollectionViewCellSectionModelItem]) {
        self = original
        self.items = items
    }
}

