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

class TaskTypeViewModel: Stepper {
  
  //MARK: - Properties
  let steps = PublishRelay<Step>()
  let disposeBag = DisposeBag()
  let services: AppServices
  
  let colorDataSource = BehaviorRelay<[TaskTypeColorSectionModel]>(value: [])
  let iconDataSource = BehaviorRelay<[TaskTypeIconSectionModel]>(value: [])
  
  //MARK: - Input
  let typeTextInput = BehaviorRelay<String>(value: "")
  let typeImageNameInput = BehaviorRelay<String>(value: "")
  let typeImageHexColorInput = BehaviorRelay<String?>(value: nil)
  
  //MARK: - Output
  let typeTextOutput = BehaviorRelay<String?>(value: nil)
  let typeImageNameOutput = BehaviorRelay<String?>(value: nil)
  let typeImageHexColorOutput = BehaviorRelay<String?>(value: nil)
  
  let titleOutput = BehaviorRelay<String?>(value: nil)
  let taskTypeOutput = BehaviorRelay<TaskType?>(value: nil)
  
  //MARK: - Init
  init(services: AppServices, taskType: TaskType?) {
    self.services = services
    
    typeImageNameInput.bind(to: typeImageNameOutput).disposed(by: disposeBag)
    typeImageHexColorInput.bind(to: typeImageHexColorOutput).disposed(by: disposeBag)
    typeTextInput.bind(to: typeTextOutput).disposed(by: disposeBag)
    
    taskTypeOutput.accept(taskType)
    typeTextOutput.accept(taskType?.text)
    typeImageNameOutput.accept(taskType?.imageName)
    typeImageHexColorOutput.accept(taskType?.imageColorHex)
    
    colorDataSource.accept(
      [TaskTypeColorSectionModel(
        header: "", items: [
          TaskTypeColorItem(color: UIColor(named: "typeColor1")), TaskTypeColorItem(color: UIColor(named: "typeColor2")),
          TaskTypeColorItem(color: UIColor(named: "typeColor3")), TaskTypeColorItem(color: UIColor(named: "typeColor4")),
          TaskTypeColorItem(color: UIColor(named: "typeColor5")), TaskTypeColorItem(color: UIColor(named: "typeColor6")),
          TaskTypeColorItem(color: UIColor(named: "typeColor7")), TaskTypeColorItem(color: UIColor(named: "typeColor8")),
          TaskTypeColorItem(color: UIColor(named: "typeColor9")), TaskTypeColorItem(color: UIColor(named: "typeColor10")),
          TaskTypeColorItem(color: UIColor(named: "typeColor11")), TaskTypeColorItem(color: UIColor(named: "typeColor12")),
          TaskTypeColorItem(color: UIColor(named: "typeColor13")), TaskTypeColorItem(color: UIColor(named: "typeColor14"))])])
    
    iconDataSource.accept([TaskTypeIconSectionModel(header: "", items: [
                                                      TaskTypeIconItem(imageName: "briefcase"),
                                                      TaskTypeIconItem(imageName: "home"),
                                                      TaskTypeIconItem(imageName: "lovely"),
                                                      TaskTypeIconItem(imageName: "monitor"),
                                                      TaskTypeIconItem(imageName: "weight"),
                                                      TaskTypeIconItem(imageName: "profile-2user") ]) ])
    
    
    
  }
  
  //MARK: - Handlers
  func backButtonClicked() {
    steps.accept(AppStep.taskTypeIsCompleted)
  }
  
  func colorSelected(indexPath: IndexPath) {
    let color = colorDataSource.value[indexPath.section].items[indexPath.item].color
    typeImageHexColorInput.accept(color?.hexString)
  }
  
  func imageSelected(indexPath: IndexPath) {
    let imageName = iconDataSource.value[indexPath.section].items[indexPath.item].imageName
    typeImageNameInput.accept(imageName)
  }
  
  func saveButtonClicked() {
    let taskType = taskTypeOutput.value ?? TaskType(UID: UUID().uuidString, imageName: nil, imageColorHex: nil, text: "", orderNumber: 0)
    taskType.imageName = typeImageNameOutput.value
    taskType.imageColorHex = typeImageHexColorOutput.value
    taskType.text = typeTextOutput.value ?? ""
    
    services.coreDataService.saveTaskTypesToCoreData(types: [taskType]) {[weak self] error in
      guard let self = self else { return }
      if let error = error {
        print(error.localizedDescription)
        return
      }
      self.steps.accept(AppStep.taskTypeIsCompleted)
    }
  }
  
}
