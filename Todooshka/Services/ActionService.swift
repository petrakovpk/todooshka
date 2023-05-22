//
//  ActionService.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 08.05.2022.
//

import CoreData
import RxSwift
import RxCocoa

protocol HasTemporaryDataService {
  var temporaryDataService: TemporaryDataService { get }
}

class TemporaryDataService {
  public var temporaryPublicationImage = BehaviorRelay<PublicationImage?>(value: nil)
  public var temporaryPublication = BehaviorRelay<Publication?>(value: nil)
  public var temporaryPublicKind = BehaviorRelay<PublicKind?>(value: nil)
  
  init() {
    
  }
}
