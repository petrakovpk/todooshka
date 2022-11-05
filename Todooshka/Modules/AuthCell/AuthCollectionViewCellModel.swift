//
//  AuthCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 25.08.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class AuthCollectionViewCellModel: Stepper {

    // MARK: - Properties
    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()

    var placeholder = ""
    var imageName = ""

    private let services: AppServices

    // MARK: - Init
    init(services: AppServices, authSectionItem: AuthSectionItem) {
        self.services = services

        placeholder = authSectionItem.placeholder
        imageName = authSectionItem.imageName
    }
}
