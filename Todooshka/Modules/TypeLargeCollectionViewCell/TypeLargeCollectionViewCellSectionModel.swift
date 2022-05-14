//
//  TypeLargeCollectionViewCellSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.05.2022.
//

import RxDataSources

struct TypeLargeCollectionViewCellSectionModel: AnimatableSectionModelType {
    
    var identity: String {
      return header
    }
    
    var header: String
    var items: [TypeLargeCollectionViewCellSectionModelItem]
    
    init(header: String, items: [TypeLargeCollectionViewCellSectionModelItem]) {
        self.header = header
        self.items = items
    }
    
    init(original: TypeLargeCollectionViewCellSectionModel, items: [TypeLargeCollectionViewCellSectionModelItem]) {
        self = original
        self.items = items
    }
}
