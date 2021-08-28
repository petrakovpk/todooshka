//
//  OnboardingCollectionViewCellModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.08.2021.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa
import Foundation
import SwipeCellKit

class OnboardingCollectionViewCellModel: Stepper {
    
    //MARK: - Properties
    let disposeBag = DisposeBag()
    let steps = PublishRelay<Step>()
    
    private let services: AppServices
    
    //MARK: - Output
    let imageOutput = BehaviorRelay<UIImage?>(value: nil)
    let headerTextOutput = BehaviorRelay<String?>(value: nil)
    let descriptionTextOutput = BehaviorRelay<String?>(value: nil)
    
    //MARK: - Init
    init(services: AppServices, onboardingSectionItem: OnboardingSectionItem) {
        self.services = services
        
        headerTextOutput.accept(onboardingSectionItem.header)
        imageOutput.accept(onboardingSectionItem.image)
        descriptionTextOutput.accept(onboardingSectionItem.description)
    }
}

