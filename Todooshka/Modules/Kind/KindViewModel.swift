//
//  KindOfTaskViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.09.2021.
//

import CoreData
import Firebase
import RxFlow
import RxSwift
import RxCocoa
import UIKit

class KindViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let kind: BehaviorRelay<Kind>
  
  private let disposeBag = DisposeBag()
  private let services: AppServices
  
  struct Input {
    // header
    let backButtonClickTrigger: Driver<Void>
    let saveButtonClickTrigger: Driver<Void>
    // text
    let text: Driver<String>
    // color
    let kindColorSelected: Driver<IndexPath>
    // icon
    let kindIconSelected: Driver<IndexPath>
  }

  struct Output {
    // header
    let navigateBack: Driver<AppStep>
    // text
    let kindText: Driver<String>
    let kindTextLength: Driver<String>
    // color
    let kindColorSections: Driver<[KindColorSection]>
    // item
    let kindIconSections: Driver<[KindIconSection]>
    // save
    let kindChange: Driver<Kind>
    let kindSave: Driver<Void>
  }

  // MARK: - Init
  init(services: AppServices, kind: Kind) {
    self.services = services
    self.kind = BehaviorRelay<Kind>(value: kind)
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let colors = services.currentUserService.kindColors
    let icons = services.currentUserService.kindIcons
    let kind = kind.asDriver()
    
    let selectedColor = kind
      .map { $0.color }
    
    let selectedIcon = kind
      .map { $0.icon }
    
    let kindText = input.text
      .map { text -> String in
        if text.count > 18 {
            return String(text.prefix(18))
        }
        return text
      }
    
    let kindTextLen = kindText
      .map { text in
        "\(text.count)\\18"
      }
    
    let kindColorItems = Driver
      .combineLatest(selectedColor, colors) { selectedColor, colors -> [KindColorItem] in
        colors.map { color -> KindColorItem in
          KindColorItem(color: color, isSelected: color.hexString == selectedColor?.hexString)
        }
      }
    
    let kindColorSections = kindColorItems
      .map { kindColorItems -> KindColorSection in
        KindColorSection(header: "", items: kindColorItems)
      }
      .map { [$0] }
    
    let kindIconItems = Driver
      .combineLatest(selectedIcon, icons) { selectedIcon, icons -> [KindIconItem] in
        icons.map { icon -> KindIconItem in
          KindIconItem(icon: icon, isSelected: icon == selectedIcon)
        }
      }
    
    let kindIconSections = kindIconItems
      .map { kindIconItems -> KindIconSection in
        KindIconSection(header: "", items: kindIconItems)
      }
      .map { [$0] }
      .debug()
    
    let kindColorChange = input.kindColorSelected
      .withLatestFrom(kindColorSections) { indexPath, sections -> KindColorItem in
        sections[indexPath.section].items[indexPath.item]
      }
      .withLatestFrom(kind) { item, kind -> Kind in
        var kind = kind
        kind.color = item.color
        return kind
      }
  
    let kindIconChange = input.kindIconSelected
      .withLatestFrom(kindIconSections) { indexPath, sections -> KindIconItem in
        sections[indexPath.section].items[indexPath.item]
      }
      .withLatestFrom(kind) { item, kind -> Kind in
        var kind = kind
        kind.icon = item.icon
        return kind
      }
    
    let kindTextChange = kindText
      .withLatestFrom(kind) { text, kind -> Kind in
        var kind = kind
        kind.text = text
        return kind
      }
    
    let kindChange = Driver.of(kindColorChange, kindIconChange, kindTextChange)
      .merge()
      .do { kind in
        self.kind.accept(kind)
      }
  
    let kindSave = input.saveButtonClickTrigger
      .withLatestFrom(kind)
      .asObservable()
      .flatMapLatest { kind -> Observable<Void> in
        StorageManager.shared.managedContext.rx.update(kind)
      }
      .asDriver(onErrorJustReturn: ())

    let navigateBack = Driver.of(input.backButtonClickTrigger, input.saveButtonClickTrigger)
      .merge()
      .map { AppStep.navigateBack }
      .do { step in
        self.steps.accept(step)
      }
    
    return Output(
      // header
      navigateBack: navigateBack,
      // text
      kindText: kindText,
      kindTextLength: kindTextLen,
      // color
      kindColorSections: kindColorSections,
      // icon
      kindIconSections: kindIconSections,
      // change and save
      kindChange: kindChange,
      kindSave: kindSave
    )
  }
}
