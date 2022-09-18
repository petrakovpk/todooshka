//
//  TaskViewModel.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 22.05.2021.
//

import CoreData
import RxFlow
import RxSwift
import RxCocoa

struct TaskAttr {
  let type: KindOfTask
  let text: String
  let description: String
}

class TaskViewModel: Stepper {
  
  private let disposeBag = DisposeBag()
  
  //MARK: - Properties
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var managedContext: NSManagedObjectContext {
    return self.appDelegate.persistentContainer.viewContext
  }
 
  var task: Task
  var status: TaskStatus = .InProgress
  let taskIsNew: Bool
  let steps = PublishRelay<Step>()
  let services: AppServices
  
  struct Input {
    // nameTextField
    let text: Driver<String>
    let textFieldEditingDidEndOnExit: Driver<Void>
    // descriptionTextField
    let descriptionTextViewText: Driver<String>
    let descriptionTextViewDidBeginEditing: Driver<Void>
    let descriptionTextViewDidEndEditing: Driver<Void>
    // collectionView
    let selection: Driver<IndexPath>
    // buttons
    let backButtonClickTrigger: Driver<Void>
    let configureTaskTypesButtonClickTrigger: Driver<Void>
    let saveTaskButtonClickTrigger: Driver<Void>
    let completeButtonClickTrigger: Driver<Void>
    // alert
    let alertCompleteTaskOkButtonClickTrigger: Driver<Void>
  }
  
  struct Output {
    // text
    let nameTextField: Driver<String>
    // descriptionLabel
    let descriptionTextViewData: Driver<(text: String, isPlaceholder: Bool)>
    // collectionView
    let dataSource: Driver<[TypeLargeCollectionViewCellSectionModel]>
    let selection: Driver<KindOfTask>
    // buttons
    let configureTaskTypesButtonClick: Driver<Void>
    // back
    let navigateBack: Driver<Void>
    // alert
    let showAlert: Driver<Void>
    let hideAlert: Driver<Void>
    // save
    let saveTask: Driver<Result<Void,Error>>
    // point
    let getPoint: Driver<Task>
    // is task is New?
    let taskIsNew: Driver<Bool>
  }
  
  //MARK: - Init
  init(services: AppServices, taskFlowAction: TaskFlowAction) {
    self.services = services
    switch taskFlowAction {
    case .create(let status, let closed):
      self.task = Task(
        UID: UUID().uuidString,
        text: "",
        description: nil,
        kindOfTask: KindOfTask.Standart.Empty,
        status: .Draft,
        created: Date(),
        closed: closed)
      self.taskIsNew = true
      self.status = status
    case .show(let task):
      self.task = task
      self.taskIsNew = false
    }
  }
  
  //MARK: - Transform
  func transform(input: Input) -> Output {

    // task in new
    let taskIsNew = Driver<Bool>.just(self.taskIsNew)
    
    // task from CoreData
    let task = services.dataService.tasks
      .map {
        $0.first {
          $0.UID == self.task.UID
        } ?? self.task
      }
      .asDriver(onErrorJustReturn: self.task)
    
    // text
    let text = input.text
      .startWith(self.task.text)
    
    let descriptionTextViewIsPlaceholderWhenBeginEditing = input.descriptionTextViewDidBeginEditing
      .map { false }
    
    let descriptionTextViewIsPlaceholderWhenEndEditing = input.descriptionTextViewDidEndEditing
      .withLatestFrom(input.descriptionTextViewText) { $1.isEmpty }
    
    let descriptionTextViewIsPlaceholder = Driver
      .of(descriptionTextViewIsPlaceholderWhenBeginEditing, descriptionTextViewIsPlaceholderWhenEndEditing)
      .merge()
      .startWith(self.task.description == nil)

    let descriptionTextViewText = input.descriptionTextViewText
      .withLatestFrom(descriptionTextViewIsPlaceholder) { $1 ? "" : $0 }
    
    // descriptionTextView
    let descriptionTextViewData = descriptionTextViewIsPlaceholder
      .withLatestFrom(descriptionTextViewText) { (text: $1, isPlaceholder: $0) }
    
    
    // types
    let kindsOfTask = services.dataService.kindsOfTask
      .map {
        $0.filter {
          $0.status == .active
        }
      }
      .asDriver(onErrorJustReturn: [])
    
    // dataSource
    let dataSource = Driver.combineLatest(task, kindsOfTask) { task, kindsOfTask -> [TypeLargeCollectionViewCellSectionModel] in
      [TypeLargeCollectionViewCellSectionModel(
        header: "",
        items: kindsOfTask.map {
          TypeLargeCollectionViewCellSectionModelItem(
            kindOfTask: $0,
            isSelected: $0.UID == task.kindOfTaskUID
          )
        }
      )]
    }
      .asDriver(onErrorJustReturn: [])
    
    // selection
    let selection = input.selection
      .withLatestFrom(dataSource) { indexPath, dataSource -> KindOfTask in
         dataSource[indexPath.section].items[indexPath.item].kindOfTask }
      .startWith(KindOfTask.Standart.Empty)
     
     // .startWith(self.task.type(withTypeService: services) ?? KindOfTask.Standart.Empty)
    
    let completeTask = input.completeButtonClickTrigger
      .map { true }
      .startWith(false)
    
    // task
    let changedTask = Driver<Task>
      .combineLatest(task, text, descriptionTextViewText, selection, completeTask) { (task, text, description, kindOfTask, completeTask) -> Task in
        Task(
          UID: task.UID,
          text: text,
          description: description.isEmpty ? nil : description,
          kindOfTask: kindOfTask,
          status: completeTask ? .Completed : task.status,
          created: task.created,
          closed: completeTask ? Date() : task.closed
        )
      }
      .startWith(self.task)
      .asObservable()
      .asDriver(onErrorJustReturn: self.task)
    
    // configure task button click
    let configureTaskTypeButtonClick = input.configureTaskTypesButtonClickTrigger
      .do { _ in
        self.steps.accept(AppStep.TaskTypesListIsRequired)
      }

    // save
    let saveTrigger = Driver
      .of(
        input.saveTaskButtonClickTrigger,
        input.textFieldEditingDidEndOnExit,
        input.completeButtonClickTrigger,
        selection.skip(1).map{ _ in () }
      )
      .merge()
          
    let save = saveTrigger
      .withLatestFrom(changedTask) { $1 }
      .distinctUntilChanged()
      .change(with: self.status)
      .asObservable()
      .flatMapLatest({ task -> Observable<Result<Void, Error>> in
        self.managedContext.rx.update(task)
      })
      .asDriver(onErrorJustReturn: .failure(ErrorType.DriverError))
    
    // добавляем пойнт
    let getPoint = input.completeButtonClickTrigger
      .withLatestFrom(changedTask) { $1 }
      .asDriver()
//      .do { task in
//        self.services.gameCurrencyService.createGameCurrency(task: task)
//      }
    
    // navigateBack
    let navigateBack = Driver
      .of(
        input.saveTaskButtonClickTrigger,
        input.textFieldEditingDidEndOnExit,
        input.backButtonClickTrigger,
        input.alertCompleteTaskOkButtonClickTrigger
      )
      .merge()
      .do { _ in
        self.steps.accept(AppStep.TaskProcessingIsCompleted)
      }
    
    // alert
    let showAlert = input.completeButtonClickTrigger
    let hideAlert = input.alertCompleteTaskOkButtonClickTrigger
   
    return Output(
      // text
      nameTextField: text,
      // descriptionTextField
      descriptionTextViewData: descriptionTextViewData,
      // collectionView
      dataSource: dataSource,
      selection: selection,
      // buttons
      configureTaskTypesButtonClick: configureTaskTypeButtonClick,
      // back
      navigateBack: navigateBack,
      // Complete Task Alert
      showAlert: showAlert,
      hideAlert: hideAlert,
      // save
      saveTask: save,
      // point
      getPoint: getPoint,
      // taskIsNew
      taskIsNew: taskIsNew
    )
  }
}
