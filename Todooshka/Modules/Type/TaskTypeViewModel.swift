//
//  TaskTypeViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.09.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import UIKit

struct TypeAttr {
  let text: String
  let iconColor: UIColor?
  let iconName: String?
}

class TaskTypeViewModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let disposeBag = DisposeBag()
  
  let services: AppServices
  var type: TaskType
  
  // dataSource
  let colorDataSource = BehaviorRelay<[TaskTypeColorSectionModel]>(value: [])
  let iconDataSource = BehaviorRelay<[TaskTypeIconSectionModel]>(value: [])
  
  //MARK: - Input
  struct Input {
    
    // buttons
    let backButtonClickTrigger: Driver<Void>
    let saveButtonClickTrigger: Driver<Void>
    
    //text
    let text: Driver<String>
    
    // selection
    let iconSelection: Driver<IndexPath>
    let colorSelection: Driver<IndexPath>
  }
  
  struct Output {
    
    // buttons
    let backButtonClick: Driver<Void>
    let saveButtonClick: Driver<Void>
    
    // text
    let limitedText: Driver<String>
    let limitedTextLength: Driver<String>
    
    // dataSource
    let iconDataSource: Driver<[TaskTypeIconSectionModel]>
    let colorDataSource: Driver<[TaskTypeColorSectionModel]>
    
    // selection
    let imageSelected: Driver<UIImage>
    let colorSelected: Driver<UIColor>
  }
  
  //MARK: - Init
  init(services: AppServices, action: TaskTypeFlowAction) {
    self.services = services
    switch action {
    case .create:
      self.type = .Standart.Empty
    case .show(let type):
      self.type = type
    }
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
    
    let colorDataSource = Driver.just([
      TaskTypeColorSectionModel(
        header: "",
        items: [
          .Amethyst,
          .BlushPink,
          .BrandyPunch,
          .BrightSun,
          .BrinkPink,
          .Cerise,
          .Corduroy,
          .Jaffa,
          .Malibu,
          .Portage,
          .PurpleHeart,
          .SeaGreen,
          .Turquoise
        ]
      )
    ])
    
    let iconDataSource = Driver.just([
      TaskTypeIconSectionModel(
        header: "",
        items: [
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
          .Tree,
          .Unlimited,
          .VideoVertical,
          .Wallet,
          .Weight
        ]
      )
    ])
    
    // backButtonClick
    let backButtonClick = input.backButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.TaskTypeProcessingIsCompleted)
      }
    
    // iconSelected
    let iconSelected = input.iconSelection
      .withLatestFrom(iconDataSource) { indexPath, dataSource -> Icon in
        return dataSource[indexPath.section].items[indexPath.item]
      }
      .startWith(self.type.icon)
      .do { icon in
        self.type.icon = icon
        self.services.typesService.selectedTypeIcon.accept(icon)
      }
    
    // imageSelected
    let imageSelected = iconSelected
      .map { $0.image }
    
    // colorSelected
    let colorSelected = input.colorSelection
      .withLatestFrom(colorDataSource) { indexPath, dataSource -> TypeColor in
        return dataSource[indexPath.section].items[indexPath.item]
      }
      .startWith(self.type.color)
      .do { color in
        self.type.color = color
        self.services.typesService.selectedTypeColor.accept(color)
      }
    
    let uiColorSelected  = colorSelected
      .map { $0.uiColor }
    
    // limitedText
    let limitedText = input.text
      .map { String($0.prefix(18)) }
      .do { text in
        self.type.text = text
      }
    
    // limitedTextLength
    let limitedTextLength = limitedText
      .map { "\($0.count.string)\\18" }
      
    
    let saveButtonClick = input.saveButtonClickTrigger
      .do { _ in
        self.services.typesService.saveTypesToCoreData(types: [self.type])
        self.steps.accept(AppStep.TaskTypeProcessingIsCompleted)
      }
    
    return Output(
      // buttons
      backButtonClick: backButtonClick,
      saveButtonClick: saveButtonClick,
        
        // text
      limitedText: limitedText,
      limitedTextLength: limitedTextLength,
        
        // dataSource
      iconDataSource: iconDataSource,
      colorDataSource: colorDataSource,
        
        // selection
      imageSelected: imageSelected,
      colorSelected: uiColorSelected
    )
  }
  
  
}
