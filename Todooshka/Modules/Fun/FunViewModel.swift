import FirebaseAuth
import Foundation
import RxFlow
import RxSwift
import RxCocoa

class FunViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  
  struct Input {
    let downvoteButtonTap: Driver<Void>
    let upvoteButtonTap: Driver<Void>
    let scrollTrigger: Driver<Void>
  }
  
  struct Output {
    let loadMoreData: Driver<Void>
    let dataSource: Driver<[FunSection]>
    let reaction: Driver<Void>
    let scrollToNextSection: Driver<Void>
    let currentVisibleItem: Driver<FunItemType?>
  }
  
  private let loadMoreDataTrigger = PublishRelay<Void>()
  private let isLoading = BehaviorRelay<Bool>(value: false)
  private let dataSourceRelay = BehaviorRelay<[FunSection]>(value: [])
  public let currentVisibleItemRelay = BehaviorRelay<FunItemType?>(value: nil)
  
  init(services: AppServices) {
    self.services = services
  }
  
  private func fetchRecommendedTasks() -> Observable<[Task]> {
    guard let currentUser = Auth.auth().currentUser else {
      return Observable.just([])
    }
    
    isLoading.accept(true)
    
    return currentUser.fetchRecommendedTasks()
      .observeOn(MainScheduler.instance)
      .do(onNext: { [weak self] _ in self?.isLoading.accept(false) },
          onError: { [weak self] _ in self?.isLoading.accept(false) })
  }
  
  private func filterExistingTasks(tasks: [Task]) -> [Task] {
    var tasksToAdd: [Task] = []
    
    for task in tasks {
      if !dataSourceRelay.value.contains(where: { section in
        section.items.contains(where: { item in
          guard case .task(let funItemTask) = item else { return false }
          return funItemTask.task.uuid == task.uuid
        })
      }) {
        tasksToAdd.append(task)
      }
    }
    
    return tasksToAdd
  }
  
  private func fetchTaskData(for tasks: [Task]) -> Observable<[FunItemType]> {
    let fetchTasksData = tasks.map { task -> Observable<FunItemType> in
      self.isLoading.accept(true)
      let fetchUser = task.fetchTaskUser().asObservable()
      let fetchImage = task.fetchTaskImage().asObservable()
      let fetchReaction = task.fetchTaskReactionForCurrentUser().asObservable().debug()
      
      return Observable.zip(fetchUser, fetchImage, fetchReaction) { (user, image, reaction) -> FunItemType in
        self.isLoading.accept(false)
        return FunItemType.task(FunItemTask(author: user, task: task, image: image, reactionType: reaction?.type, isLoading: false))
      }
    }
    
    return Observable.zip(fetchTasksData)
  }
  
  private func updateDataSource(with funItemTypes: [FunItemType]) {
    let currentSections = dataSourceRelay.value
    var newSections = currentSections
    
    for funItemType in funItemTypes {
      guard case .task(let updatedFunItemTask) = funItemType else { continue }
      for (sectionIndex, section) in newSections.enumerated() {
        if let itemIndex = section.items.firstIndex(where: { item -> Bool in
          guard case .task(let funItemTask) = item else { return false }
          return funItemTask.task.uuid == updatedFunItemTask.task.uuid
        }) {
          var newSection = section
          newSection.items[itemIndex] = .task(updatedFunItemTask)
          newSections[sectionIndex] = newSection
          break
        }
      }
    }
    dataSourceRelay.accept(newSections)
  }
  
  private func shouldAddNoMoreTasks() -> Bool {
    return !dataSourceRelay.value.contains { section in
      section.items.contains { item in
        item == FunItemType.noMoreTasks
      }
    }
  }
  
  func transform(input: Input) -> Output {
    let loadMoreDataTrigger = loadMoreDataTrigger.asDriverOnErrorJustComplete()
    let isLoading = isLoading.asDriver().debug()
    let dataSource = dataSourceRelay.asDriver().debug()
    let currentVisibleItem = currentVisibleItemRelay.asDriverOnErrorJustComplete().debug()
    
    let reactionTriggers = Driver.of(
      input.downvoteButtonTap.map { ReactionType.downvote },
      input.upvoteButtonTap.map { ReactionType.upvote },
      input.scrollTrigger.map { ReactionType.skip }
    )
      .merge()
    
    let scrollToNextSection = Driver
      .of(input.downvoteButtonTap, input.upvoteButtonTap)
      .merge()
    
    let currentTask = currentVisibleItem
      .compactMap { funItemType -> Task? in
        guard case .task(let funItemTask) = funItemType else { return nil }
        return funItemTask.task
      }
    
    let reaction = reactionTriggers
      .withLatestFrom(currentTask) { reactionType, task -> Reaction? in
        guard let currentUser = Auth.auth().currentUser else { return nil }
        return Reaction(uuid: UUID(), userUID: currentUser.uid, taskUUID: task.uuid, type: reactionType)
      }
      .compactMap { $0 }
      .asObservable()
      .flatMapLatest { reaction -> Observable<Void> in
        reaction.putReactionToCloud()
      }
      .compactMap { $0 }
      .asDriver(onErrorJustReturn: ())
    
    
    let loadMoreData = loadMoreDataTrigger
      .withLatestFrom(isLoading)
      .filter { !$0 }
      .asObservable()
      .flatMapLatest { [weak self] _ -> Observable<[FunItemType]> in
        guard let self = self else { return Observable.just([]) }
        
        return self.fetchRecommendedTasks()
          .map { [weak self] tasks -> [FunItemType] in
            guard let self = self else { return [] }
            
            let tasksToAdd = self.filterExistingTasks(tasks: tasks)
            
            if tasksToAdd.isEmpty {
              if self.shouldAddNoMoreTasks() {
                return [FunItemType.noMoreTasks]
              } else {
                return []
              }
            } else {
              return tasksToAdd.map { task in
                FunItemType.task(FunItemTask(author: nil, task: task, image: nil, reactionType: nil, isLoading: true))
              }
            }
          }
          .do(onNext: { [weak self] funItemTypes in
            guard let self = self else { return }
            if !funItemTypes.isEmpty {
              let currentSections = self.dataSourceRelay.value
              let newSections = currentSections + funItemTypes.map { FunSection(items: [$0]) }
              self.dataSourceRelay.accept(newSections)
            }
          })
          .flatMap { [weak self] funItemTypes -> Observable<[FunItemType]> in
            guard let self = self else { return Observable.just(funItemTypes) }
            let tasksToFetchData = funItemTypes.compactMap { funItemType -> Task? in
              guard case .task(let funItemTask) = funItemType else { return nil }
              return funItemTask.task
            }
            
            return self.fetchTaskData(for: tasksToFetchData)
          }
          .do(onNext: { [weak self] funItemTypes in
            self?.updateDataSource(with: funItemTypes)
          }, onError: { [weak self] _ in
            self?.isLoading.accept(false)
          })
            }
      .asDriverOnErrorJustComplete()
      .map { funItemTypes in
        if let funItemType = funItemTypes[safe: 0], self.currentVisibleItemRelay.value == nil {
          self.currentVisibleItemRelay.accept(funItemType)
        }
      }
    
    return Output(
      loadMoreData: loadMoreData,
      dataSource: dataSource,
      reaction: reaction,
      scrollToNextSection: scrollToNextSection,
      currentVisibleItem: currentVisibleItem
    )
    
  }
  
  // Load more data
  func loadMoreItems() {
    self.loadMoreDataTrigger.accept(())
  }
  
  // Update the currently visible item
  func updateCurrentVisibleItem(type: FunItemType) {
    self.currentVisibleItemRelay.accept(type)
  }
}
