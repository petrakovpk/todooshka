//
//  ThemeViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift

enum OpenViewControllerMode {
  case edit
  case view
}

class ThemeViewModel: Stepper {
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  var managedContext: NSManagedObjectContext { appDelegate!.persistentContainer.viewContext }

  // theme
  let theme: Theme

  struct Input {
    let addImageButtonClickTrigger: Driver<Void>
    let backButtonClickTrigger: Driver<Void>
    let daySelection: Driver<IndexPath>
    let description: Driver<String>
    let name: Driver<String>
    let saveButtonClickTrigger: Driver<Void>
  }

  struct Output {
    let mode: Driver<OpenViewControllerMode>
    let navigateBack: Driver<Void>
    let openThemeStep: Driver<Void>
    let save: Driver<Result<Void, Error>>
    let theme: Driver<Theme>
    let title: Driver<String>
    let themeStepDataSource: Driver<[ThemeStepSection]>
    let typeDataSource: Driver<[ThemeTypeSection]>
  }

  // MARK: - Init
  init(services: AppServices, theme: Theme) {
    self.services = services
    self.theme = theme
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let name = input.name
    let description = input.description
    
    let mode = Driver<OpenViewControllerMode>
      .just(self.theme.status == .draft ? .edit : .view)
    
    let theme = Driver
      .combineLatest(name, description) { name, description -> Theme in
        Theme(
          description: description,
          name: name,
          status: self.theme.status,
          type: self.theme.type,
          uid: self.theme.uid
        )
      }
    
    let saveTrigger = input.saveButtonClickTrigger
    
    let save = saveTrigger
      .withLatestFrom(theme) { $1 }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))
      .debug()
    
    let title = services
      .dataService
      .themes
      .asDriver()
      .compactMap { $0.first { $0.uid == self.theme.uid } }
      .map { $0.name }
      .map { $0.isEmpty ? "Новая тема" : $0 }
      .startWith("Новая тема")
    
    
    // dayDataSource
    let themeStepDataSource = Driver<[ThemeStepSection]>.just(
      [
        ThemeStepSection(header: "", items: [
          ThemeStep(UID: UUID().uuidString, goal: "Шаг 1"),
          ThemeStep(UID: UUID().uuidString, goal: "Шаг 2"),
          ThemeStep(UID: UUID().uuidString, goal: "Шаг 3"),
          ThemeStep(UID: UUID().uuidString, goal: "Шаг 4"),
          ThemeStep(UID: UUID().uuidString, goal: "Шаг 5")
        ])
      ]
    )
    
    let themeStepSelected = input
      .daySelection
      .withLatestFrom(themeStepDataSource) { indexPath, dataSource -> ThemeStep in
        dataSource[indexPath.section].items[indexPath.item]
      }

    let openThemeStep = themeStepSelected
      .withLatestFrom(mode) { step, mode in
        self.steps.accept(
          AppStep.themeStepIsRequired(
            themeStep: step,
            openViewControllerMode: mode))
      }
    
    // dayDataSource
    let typeDataSource = Driver<[ThemeTypeSection]>.just(
      [
        ThemeTypeSection(
          header: "",
          items: [
            ThemeTypeItem(type: .empty, isSelected: false),
            ThemeTypeItem(type: .cooking, isSelected: false),
            ThemeTypeItem(type: .health, isSelected: false),
            ThemeTypeItem(type: .sport, isSelected: false)
          ])
      ]
    )

    // buttons
    let navigateBack = input
      .backButtonClickTrigger
      .map { self.steps.accept( AppStep.themeProcessingIsCompleted ) }

    return Output(
      mode: mode,
      navigateBack: navigateBack,
      openThemeStep: openThemeStep,
      save: save,
      theme: theme,
      title: title,
      themeStepDataSource: themeStepDataSource,
      typeDataSource: typeDataSource
    )
  }
}
