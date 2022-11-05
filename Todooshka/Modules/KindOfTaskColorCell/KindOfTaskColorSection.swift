//
//  KindOfTaskColorSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

struct KindOfTaskColorSection: AnimatableSectionModelType {

    var identity: String { header }
    var header: String
    var items: [KindOfTaskColorItem]

    init(header: String, items: [KindOfTaskColorItem]) {
        self.header = header
        self.items = items
    }

    init(original: KindOfTaskColorSection, items: [KindOfTaskColorItem]) {
        self = original
        self.items = items
    }
}
