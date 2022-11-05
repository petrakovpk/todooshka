//
//  OnboardingSectionModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.08.2021.
//

import UIKit
import RxDataSources

struct OnboardingSectionItem: IdentifiableType, Equatable {

    // MARK: - Properties
    var header: String
    var description: String
    var image: UIImage

    // MARK: - Identity
    var identity: String { return UUID().uuidString }
}

struct OnboardingSectionModel: AnimatableSectionModelType {

    // MARK: - Identity
    var identity: String { return UUID().uuidString }

    // MARK: - Properties
    var items: [OnboardingSectionItem]

    // MARK: - Init
    init(items: [OnboardingSectionItem]) {
        self.items = items
    }

    init(original: OnboardingSectionModel, items: [OnboardingSectionItem]) {
        self = original
        self.items = items
    }
}
