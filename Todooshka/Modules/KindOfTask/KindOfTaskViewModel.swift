//
//  KindOfTaskViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.09.2021.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa
import UIKit

struct TypeAttr {
  let text: String
  let iconColor: UIColor?
  let iconName: String?
}

class KindOfTaskViewModel: Stepper {
  
  //MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let disposeBag = DisposeBag()
  var kindOfTask: KindOfTask
  var managedContext: NSManagedObjectContext {
    return self.appDelegate.persistentContainer.viewContext
  }
  let services: AppServices
  let steps = PublishRelay<Step>()

  //MARK: - Input
  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let saveButtonClickTrigger: Driver<Void>
    let selectionColor: Driver<IndexPath>
    let selectionIcon: Driver<IndexPath>
    let text: Driver<String>
  }
  
  struct Output {
    let dataSourceColor: Driver<[KindOfTaskColorSectionModel]>
    let dataSourceIcon: Driver<[KindOfTaskIconSectionModel]>
    let navigateBack: Driver<Void>
    let save: Driver<Result<Void, Error>> // Driver<Void> // 
    let selectedColor: Driver<UIColor>
    let selectedIcon: Driver<UIImage>
    let text: Driver<String>
    let textLen: Driver<String>
  }
  
  //MARK: - Init
  init(services: AppServices, action: KindOfTaskFlowAction) {
    self.services = services
    switch action {
    case .create:
      self.kindOfTask = KindOfTask.Standart.Empty
      self.kindOfTask.UID = UUID().uuidString
    case .show(let kindOfTask):
      self.kindOfTask = kindOfTask
    }
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    let colors = Driver<[UIColor]>.of([
      Palette.SingleColors.Amethyst,
      Palette.SingleColors.BlushPink,
      Palette.SingleColors.BrightSun,
      Palette.SingleColors.BrinkPink,
      Palette.SingleColors.Cerise,
      Palette.SingleColors.Corduroy,
      Palette.SingleColors.Jaffa,
      Palette.SingleColors.Malibu,
      Palette.SingleColors.Portage,
      Palette.SingleColors.PurpleHeart,
      Palette.SingleColors.SeaGreen,
      Palette.SingleColors.Turquoise,
    ])
    
    let icons = Driver<[Icon]>.of([
      .Bank,
      .BookSaved,
      .Briefcase,
      .Dumbbell,
      .EmojiHappy,
      .GasStation,
      .House,
      .Lovely,
      .Moon,
      .NotificationBing,
      .Pet,
      .Profile2user,
      .Ship,
      .Shop,
      .Sun,
      .Teacher,
      .Unlimited,
      .VideoVertical,
      .Wallet,
      .Weight
    ])
    
    let startColorIndexPath = colors
      .map { $0.firstIndex(where: { $0.hexString == self.kindOfTask.color.hexString }) ?? 0 }
      .map { IndexPath( item: $0, section: 0) }
    
    let startIconIndexPath = icons
      .map { $0.firstIndex(where: { $0.rawValue == self.kindOfTask.icon.rawValue }) ?? 0 }
      .map { IndexPath( item: $0, section: 0) }
       
    let selectedColorIndexPath = Driver
      .of(startColorIndexPath, input.selectionColor)
      .merge()
    
    let selectedIconIndexPath = Driver
      .of(startIconIndexPath, input.selectionIcon)
      .merge()
    
    let selectedColor = Driver
      .combineLatest(selectedColorIndexPath, colors) { indexPath, colors -> UIColor in
        colors[indexPath.item]
      }
    
    let selectedIcon = Driver
      .combineLatest(selectedIconIndexPath, icons) { indexPath, icons -> Icon in
        icons[indexPath.item]
      }
    
    let selectedImage = selectedIcon.map{ $0.image }
    
    let dataSourceColorItems = selectedColorIndexPath
      .withLatestFrom(colors) { indexPath, colors -> [KindOfTaskColorItem] in
        colors.enumerated().map { (index, color) -> KindOfTaskColorItem in
          KindOfTaskColorItem(color: color, isSelected: index == indexPath.item)
        }
      }
    
    let dataSourceIconItems = selectedIconIndexPath
      .withLatestFrom(icons) { indexPath, icons -> [KindOfTaskIconItem] in
        icons.enumerated().map { (index, icon) -> KindOfTaskIconItem in
          KindOfTaskIconItem(icon: icon, isSelected: index == indexPath.item)
        }
      }
    
    let dataSourceColor = dataSourceColorItems
      .map{[ KindOfTaskColorSectionModel(header: "", items: $0) ]}
    
    let dataSourceIcon = dataSourceIconItems
      .map{[ KindOfTaskIconSectionModel(header: "", items: $0) ]}
    
    let text = input.text
      .map{ $0.prefix(18) }
      .map{ String($0) }
      .startWith(self.kindOfTask.text)
     
    let textLen = text
      .map{ $0.count.string + "\\18" }
    
    let kindOfTask = Driver
      .combineLatest(selectedColor, selectedIcon, text) { color, icon, text -> KindOfTask in
        KindOfTask(
          UID: self.kindOfTask.UID,
          icon: icon,
          color: color,
          text: text,
          index: self.kindOfTask.index
        )
      }
    
    let save = input.saveButtonClickTrigger
      .withLatestFrom(kindOfTask) { $1 }
      .asObservable()
     .flatMapLatest({ self.managedContext.rx.update($0) })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    // backButtonClick
    let navigateBack = Driver
      .of(input.backButtonClickTrigger, input.saveButtonClickTrigger)
      .merge()
      .map { self.steps.accept(AppStep.NavigateBack) }
    
    return Output(
      dataSourceColor: dataSourceColor,
      dataSourceIcon: dataSourceIcon,
      navigateBack: navigateBack,
      save: save,
      selectedColor: selectedColor,
      selectedIcon: selectedImage ,
      text: text,
      textLen: textLen
    )
  }
  
  
}
