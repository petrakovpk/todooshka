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

struct TypeAttr {
  let text: String
  let iconColor: UIColor?
  let iconName: String?
}

class KindOfTaskViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let disposeBag = DisposeBag()
  private let services: AppServices
  private let selectedColor = BehaviorRelay<UIColor?>(value: nil)
  private let selectedIcon = BehaviorRelay<Icon?>(value: nil)
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  private var managedContext: NSManagedObjectContext { self.appDelegate.persistentContainer.viewContext }
  private var kindOfTaskUID: String

  // MARK: - Input
  struct Input {
    let backButtonClickTrigger: Driver<Void>
    let saveButtonClickTrigger: Driver<Void>
    let selectionColor: Driver<IndexPath>
    let selectionIcon: Driver<IndexPath>
    let text: Driver<String>
  }

  struct Output {
    let dataSourceColor: Driver<[KindOfTaskColorSection]>
    let dataSourceIcon: Driver<[KindOfTaskIconSection]>
    let navigateBack: Driver<Void>
    let save: Driver<Result<Void, Error>>
    let selectColor: Driver<UIColor>
    let selectIcon: Driver<UIImage>
    let text: Driver<String>
    let textLen: Driver<String>
  }

  // MARK: - Init
  init(services: AppServices, kindOfTaskUID: String) {
    self.services = services
    self.kindOfTaskUID = kindOfTaskUID
  }

  // MARK: - Transform
  func transform(input: Input) -> Output {
    let colors = services.dataService.colors
    let icons = services.dataService.icons
    let selectedColor = selectedColor.asDriver()
    let selectedIcon = selectedIcon.asDriver()
    let kindsOfTask = services.dataService.kindsOfTask

    let kindOfTask = kindsOfTask
      .compactMap { kindsOfTask -> KindOfTask? in
        kindsOfTask.first { kindOfTask -> Bool in
          kindOfTask.UID == self.kindOfTaskUID
        }
      }

    let isStyleLocked = kindOfTask
      .map { $0.isStyleLocked }
      .startWith(false)

    let kindOfTaskText = kindOfTask
      .map { $0.text }

    let kindOfTaskColor = kindOfTask
      .map { $0.color }

    let kindOfTaskIcon = kindOfTask
      .map { $0.icon }

    let kindOfTaskStartIndex = kindsOfTask
      .map { $0.count + 1 }

    let kindOfTaskExistIndex = kindOfTask
      .map { $0.index }

    let kindOfTaskIndex = Driver
      .of(kindOfTaskStartIndex, kindOfTaskExistIndex)
      .merge()

    let text = Driver
      .of(
        kindOfTaskText,
        input.text
          .map { $0.prefix(18) }
          .map { String($0) })
      .merge()

    let textLen = text
      .map { $0.count.string + "\\18" }

    // COLORS
    let dataSourceColors = Driver
      .combineLatest(colors, selectedColor) { colors, color -> [KindOfTaskColorSection] in
        [
          KindOfTaskColorSection(
            header: "",
            items: colors.map { KindOfTaskColorItem(color: $0, isSelected: $0.hexString == color?.hexString) }
          )
        ]
      }

    let selectColor = Driver.of(
      kindOfTaskColor,
      input.selectionColor.withLatestFrom(dataSourceColors) { indexPath, dataSource -> UIColor in
        dataSource[indexPath.section].items[indexPath.item].color
      })
      .merge()
      .do { self.selectedColor.accept($0) }

    // ICONS
    let dataSourceIcons = Driver
      .combineLatest(icons, selectedIcon) { icons, icon -> [KindOfTaskIconSection] in
        [
          KindOfTaskIconSection(
            header: "",
            items: icons.map { KindOfTaskIconItem(icon: $0, isSelected: $0.rawValue == icon?.rawValue) }
          )
        ]
      }
    
    let selectIcon = Driver
      .of(
        kindOfTaskIcon,
        input.selectionIcon.withLatestFrom(dataSourceIcons) { indexPath, dataSource -> Icon in
          dataSource[indexPath.section].items[indexPath.item].icon
        })
      .merge()
      .do { self.selectedIcon.accept($0) }
    
    let selectImage = selectIcon
      .map { $0.image.template }

    let kindOfTaskAttr = Driver
      .combineLatest(
        selectedColor.compactMap { $0 },
        selectedIcon.compactMap { $0 },
        text,
        kindOfTaskIndex,
        isStyleLocked
      ) { color, icon, text, index, isStyleLocked -> KindOfTask in
        KindOfTask(
          UID: self.kindOfTaskUID,
          icon: icon,
          isStyleLocked: isStyleLocked,
          color: color,
          text: text,
          index: index,
          userUID: Auth.auth().currentUser?.uid
        )
      }

    let save = input.saveButtonClickTrigger
      .withLatestFrom(kindOfTaskAttr) { $1 }
      .asObservable()
      .flatMapLatest { self.managedContext.rx.update($0) }
      .asDriver(onErrorJustReturn: .failure(ErrorType.driverError))

    // backButtonClick
    let navigateBack = Driver
      .of(input.backButtonClickTrigger, input.saveButtonClickTrigger)
      .merge()
      .do { _ in
        self.steps.accept(AppStep.navigateBack)
      }

    return Output(
      dataSourceColor: dataSourceColors,
      dataSourceIcon: dataSourceIcons,
      navigateBack: navigateBack,
      save: save,
      selectColor: selectColor,
      selectIcon: selectImage,
      text: text,
      textLen: textLen
    )
  }
}
