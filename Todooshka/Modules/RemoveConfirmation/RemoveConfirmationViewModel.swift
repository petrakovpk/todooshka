//
//  RemoveConfirmationViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 12.09.2021.
//

import RxFlow
import RxSwift
import RxCocoa
import Firebase

class RemoveConfirmationViewModel: Stepper {
  
  //MARK: - Properties
  private let services: AppServices
  
  let disposeBag = DisposeBag()
  let steps = PublishRelay<Step>()
  
  //MARK: Init
  init(services: AppServices) {
    self.services = services
    
  }

}

