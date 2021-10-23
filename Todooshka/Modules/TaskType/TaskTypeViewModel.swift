//
//  TaskTypeViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 06.09.2021.
//


import RxFlow
import RxSwift
import RxCocoa
import Firebase
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
  var taskType: TaskType?
  var taskTypeIconItem: TaskTypeIconItem? {
    guard  let imageName = taskType?.imageName else { return nil }
    return TaskTypeIconItem(imageName: imageName)
  }
  
  let colorDataSource = BehaviorRelay<[TaskTypeColorSectionModel]>(value: [])
  let iconDataSource = BehaviorRelay<[TaskTypeIconSectionModel]>(value: [])
  
  //MARK: - Input
  struct Input {
    let text: Driver<String>
    let colorSelection: Driver<IndexPath>
    let iconSelection: Driver<IndexPath>
    let backButtonClickTrigger: Driver<Void>
    let saveButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    let colorDataSource: Driver<[TaskTypeColorSectionModel]>
    let iconDataSource: Driver<[TaskTypeIconSectionModel]>
    let backButtonClick: Driver<Void>
    let colorSelected: Driver<UIColor?>
    let iconSelected: Driver<UIImage?>
    let limitedTextLength: Driver<String>
    let limitedText: Driver<String>
    let saveType: Driver<Void>
  }
    
  //MARK: - Init
  init(services: AppServices, taskType: TaskType?) {
    self.services = services
    self.taskType = taskType
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {
     
    let colorDataSource = Driver.just(
      [TaskTypeColorSectionModel(
        header: "", items: [
          TaskTypeColorItem(color: UIColor(named: "typeColor1")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor2")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor3")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor4")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor5")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor6")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor7")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor8")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor9")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor10")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor11")!),
          TaskTypeColorItem(color: UIColor(named: "typeColor12")!)
        ])])
    
    let iconDataSource = Driver.just(
      [TaskTypeIconSectionModel(
        header: "", items: [
          TaskTypeIconItem(imageName: "emoji-happy"),
          TaskTypeIconItem(imageName: "ship"),
          TaskTypeIconItem(imageName: "teacher"),
          TaskTypeIconItem(imageName: "briefcase"),
          TaskTypeIconItem(imageName: "book-saved"),
          TaskTypeIconItem(imageName: "moon"),
          TaskTypeIconItem(imageName: "tree"),
          TaskTypeIconItem(imageName: "weight"),
          TaskTypeIconItem(imageName: "bank"),
          TaskTypeIconItem(imageName: "shop"),
          TaskTypeIconItem(imageName: "lovely"),
          TaskTypeIconItem(imageName: "house"),
          TaskTypeIconItem(imageName: "video-vertical"),
          TaskTypeIconItem(imageName: "gas-station"),
          TaskTypeIconItem(imageName: "notification-bing"),
          TaskTypeIconItem(imageName: "sun"),
          TaskTypeIconItem(imageName: "profile-2user"),
          TaskTypeIconItem(imageName: "pet"),
          TaskTypeIconItem(imageName: "dumbbell"),
          TaskTypeIconItem(imageName: "wallet")
        ])])
    
    let backButtonClick = input.backButtonClickTrigger.map {
      self.steps.accept(AppStep.taskTypeIsCompleted)
    }
    
    let colorSelected = input.colorSelection.withLatestFrom(colorDataSource) { indexPath, dataSource -> UIColor in
      let color = dataSource[indexPath.section].items[indexPath.item].color
      return color }
      .startWith(taskType?.imageColor ?? UIColor(named: "appText"))
      .do{ self.services.coreDataService.selectedTaskTypeColor.accept($0) }
    
    let iconItemSelected = input.iconSelection.withLatestFrom(iconDataSource) { indexPath, dataSource -> TaskTypeIconItem in
      let iconName = dataSource[indexPath.section].items[indexPath.item]
      return iconName }
      .startWith(taskTypeIconItem)
      .do{ self.services.coreDataService.selectedTaskTypeIconName.accept($0?.imageName) }
    
    let iconSelected = iconItemSelected.map { return $0?.image }
    
    let limitedText = input.text.map { text -> String in
      return String(text.prefix(18))
    }
    
    let limitedTextLength = limitedText.map { text -> String in
      return "\(text.count.string)\\18"
    }
    
    let typeAttr = Driver<TypeAttr>.combineLatest(
      limitedText,
      colorSelected,
      iconItemSelected
    ) { text, iconColor, iconName -> TypeAttr in
      return TypeAttr(text: text, iconColor: iconColor, iconName: iconName?.imageName )
    }.asDriver()
    
    let saveType = input.saveButtonClickTrigger.withLatestFrom(typeAttr) { _, typeAttr in
      guard let iconName = typeAttr.iconName else { return }
      guard let iconColor = typeAttr.iconColor else { return }
      
      if self.taskType == nil {
        self.taskType = TaskType(UID: UUID().uuidString, imageName: iconName, imageColorHex: iconColor.hexString , text: typeAttr.text, orderNumber: 0)
      }
      
      self.taskType?.imageName = iconName
      self.taskType?.imageColorHex = iconColor.hexString
      self.taskType?.text = typeAttr.text
      self.taskType?.status = .active
      
      self.services.coreDataService.saveTaskTypesToCoreData(types: [self.taskType!]) {[weak self] error in
        guard let self = self else { return }
        if let error = error {
          print(error.localizedDescription)
          return
        }
        self.steps.accept(AppStep.taskTypeIsCompleted)
      }
    }
    
    return Output(
      colorDataSource: colorDataSource,
      iconDataSource: iconDataSource,
      backButtonClick: backButtonClick,
      colorSelected: colorSelected,
      iconSelected: iconSelected,
      limitedTextLength: limitedTextLength,
      limitedText: limitedText,
      saveType: saveType
    )
  }

  
}
