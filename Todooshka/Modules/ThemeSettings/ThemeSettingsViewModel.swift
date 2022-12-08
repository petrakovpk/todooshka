//
//  ThemeSettingsViewModel.swift
//  DragoDo
//
//  Created by Pavel Petakov on 03.12.2022.
//

import CoreData
import RxCocoa
import RxFlow
import RxSwift

class ThemeSettingsViewModel: Stepper {
  // MARK: - Properties
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  var managedContext: NSManagedObjectContext { appDelegate!.persistentContainer.viewContext }

  // theme
  let theme: Theme
  
  let deleteThemeIsRequired = SettingsItem(image: Icon.trash.image, text: "Удалить", type: .deleteThemeIsRequired)
  let sendForVerificationIsRequired = SettingsItem(image: Icon.arrowUp.image, text: "Отправить на одобрение", type: .sendForVerificationIsRequired)
  
  struct Input {
    let selection: Driver<IndexPath>
  }

  struct Output {
    let dataSource: Driver<[SettingsCellSectionModel]>
    let delete: Driver<Result<Void, Error>>
  }

  // MARK: - Init
  init(services: AppServices, theme: Theme) {
    self.services = services
    self.theme = theme
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let errorTracker = ErrorTracker()
    
    // dataSource
    let dataSource = Driver.just(
      [
        SettingsCellSectionModel(
          header: "",
          items: [sendForVerificationIsRequired, deleteThemeIsRequired] )
      ]
    )
    
    let selectedSettingsType = input
      .selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> SettingsType in
        dataSource[indexPath.section].items[indexPath.item].type
      }
    
    let delete = selectedSettingsType
      .filter { $0 == .deleteThemeIsRequired }
      .mapToVoid()
      .flatMapLatest { self.managedContext
        .rx
        .delete(self.theme)
        .trackError(errorTracker)
        .asDriverOnErrorJustComplete()
      }
      .do { _ in
        self.steps.accept(AppStep.dismissAndNavigateBack)
      }
      
    return Output(
      dataSource: dataSource,
      delete: delete
    )
  }
}

