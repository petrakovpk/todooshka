//
//  KindOfTaskColorSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

struct KindOfTaskColorItem: IdentifiableType, Equatable {
  
  var identity: String { color.hexString + isSelected.string }
  
  var color: UIColor
  var isSelected: Bool

}

struct KindOfTaskColorSectionModel: AnimatableSectionModelType {
    
    var identity: String {
        return header
    }
    
    var header: String
    var items: [KindOfTaskColorItem]
    
    init(header: String, items: [KindOfTaskColorItem]) {
        self.header = header
        self.items = items
    }
    
    init(original: KindOfTaskColorSectionModel, items: [KindOfTaskColorItem]) {
        self = original
        self.items = items
    }
}
