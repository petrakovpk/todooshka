//
//  KindColorSection.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 07.09.2021.
//

import RxDataSources
import UIKit

struct KindColorSection: AnimatableSectionModelType {
    var identity: String { header }
    var header: String
    var items: [KindColorItem]

    init(header: String, items: [KindColorItem]) {
        self.header = header
        self.items = items
    }

    init(original: KindColorSection, items: [KindColorItem]) {
        self = original
        self.items = items
    }
}
