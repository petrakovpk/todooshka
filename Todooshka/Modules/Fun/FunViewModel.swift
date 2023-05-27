import FirebaseAuth
import Foundation
import RxFlow
import RxSwift
import RxCocoa

enum FunItemView {
  case device(deviceView: DevicePublicationView)
  case user(userView: UserPublicationView)
}

class FunViewModel: Stepper {
  public let steps = PublishRelay<Step>()
  public let scrolledUpperVisibleIndexPath = BehaviorRelay<IndexPath?>(value: nil)
  public let scrolledVisibleIndexPath = BehaviorRelay<IndexPath?>(value: nil)
  
  private let services: AppServices
  private let disposeBag = DisposeBag()
  private let dataSourceRelay = BehaviorRelay<[FunSection]>(value: [])
  
  private var isLoading: Bool = false
  
  struct Input {
    let downvoteButtonTap: Driver<Void>
    let upvoteButtonTap: Driver<Void>
    let scrollTrigger: Driver<Void>
  }
  
  struct Output {
    let navigateToAuth: Driver<AppStep>
    let reloadData: Driver<[FunSection]>
    let loadMoreData: Driver<[FunSection]>
    let scrollToNextCell: Driver<Void>
    let saveReaction: Driver<Void>
    let saveView: Driver<Void>
    let dataSource: Driver<[FunSection]>
  }
  
  init(services: AppServices) {
    self.services = services
  }
  
  func transform(input: Input) -> Output {
    let currentUser = services.currentUserService.user
    let scrolledUpperVisibleIndexPath = scrolledUpperVisibleIndexPath.asDriver()
    let scrolledVisibleIndexPath = scrolledVisibleIndexPath.asDriver()
    let dataSource = dataSourceRelay.asDriver().debug()
    
    let navigateToAuth = Driver
      .of(input.downvoteButtonTap, input.upvoteButtonTap)
      .merge()
      .withLatestFrom(currentUser)
      .filter { $0 == nil }
      .map { _ -> AppStep in
          .authIsRequired
      }
      .do { step in
        self.steps.accept(step)
      }
    
    let reloadData = currentUser
      .filter { _ in self.isLoading == false }
      .flatMapLatest { user -> Driver<[Publication]> in
        self.isLoading = true
        if let user = user {
          return user.fetchRecommendedPublications().debug().asDriver(onErrorJustReturn: [])
        } else {
          return UIDevice.current.fetchRecommendedPublications().debug().asDriver(onErrorJustReturn: [])
        }
      }
      .flatMap { publications -> Driver<[FunSection]> in
        let funItemsObservable = publications.map { publication -> Driver<FunItem> in
          publication.fetchUnsafeImage()
            .map { image -> FunItem in
              var funItem = FunItem(publication: publication, image: image)
              funItem.isLoading = false
              return funItem
            }
            .asDriverOnErrorJustComplete()
        }
        
        return Driver.combineLatest(funItemsObservable)
          .map { funItems -> [FunSection] in
            funItems.map { funItem -> FunSection in
              FunSection(items: [funItem])
            }
          }
      }
      .do { funSections in
        self.dataSourceRelay.accept(funSections)
        self.isLoading = false
      }
      .asDriver(onErrorJustReturn: [])
    
    let loadMoreDataTrigger = Driver
      .combineLatest(scrolledVisibleIndexPath.compactMap { $0 }, dataSource) { indexPath, dataSource -> Bool in
        indexPath.section >= dataSource.count - 2
      }
      .flatMapLatest { trigger -> Driver<Void> in
        trigger ? Driver<Void>.of(()) : Driver<Void>.empty()
      }
    
//    let loadMoreData = loadMoreDataTrigger
//      .filter { _ in self.isLoading == false }
//      .withLatestFrom(currentUser)
//      .flatMapLatest { user -> Driver<[Publication]> in
//        self.isLoading = true
//        if let user = user {
//          return user.fetchRecommendedPublications().asDriver(onErrorJustReturn: [])
//        } else {
//          return UIDevice.current.fetchRecommendedPublications().asDriver(onErrorJustReturn: [])
//        }
//      }
//      .flatMap { publications -> Driver<[FunSection]> in
//        let dataSource = self.dataSourceRelay.value
//        let dataSourcePublications = Set(dataSource.flatMap { $0.items.map { $0.publication.uuid.uuidString } })
//
//        let funItemsObservable = publications
//          .compactMap { publication -> Driver<FunSection>? in
//            if !dataSourcePublications.contains(publication.uuid.uuidString) {
//              publication.fetchUnsafeImage()
//                .map { image -> FunSection in
//                  FunSection(items: [FunItem(publication: publication, image: image, isLoading: false)])
//                }
//                .asDriverOnErrorJustComplete()
//            }
//            return nil
//          }
//
//        return Driver.combineLatest(funItemsObservable)
//      }
//      .do { newSections in
//        var currentSections = self.dataSourceRelay.value
//        let currentUUIDs = Set(currentSections.flatMap { $0.items.map { $0.publication.uuid.uuidString } })
//        let uniqueNewSections = newSections.filter { newSection in
//          let newUUID = newSection.items.first?.publication.uuid.uuidString
//          return newUUID != nil && !currentUUIDs.contains(newUUID!)
//        }
//        currentSections.append(contentsOf: uniqueNewSections)
//        self.dataSourceRelay.accept(currentSections)
//        self.isLoading = false
//      }
//      .asDriver(onErrorJustReturn: [])
    
    
    let upvoteReaction = input.upvoteButtonTap
      .withLatestFrom(scrolledVisibleIndexPath.map { $0 ?? IndexPath(row: 0, section: 0) } )
      .withLatestFrom(dataSource) { indexPath, dataSource -> FunItem in
        dataSource[indexPath.section].items[indexPath.item]
      }
      .withLatestFrom(currentUser.compactMap { $0 }) { item, currentUser -> Reaction in
        Reaction(uuid: UUID(), userUID: currentUser.uid, publicationUUID: item.publication.uuid, reactionType: .upvote)
      }
    
    let downvoteReaction = input.downvoteButtonTap
      .withLatestFrom(scrolledVisibleIndexPath.map { $0 ?? IndexPath(row: 0, section: 0) } )
      .withLatestFrom(dataSource) { indexPath, dataSource -> FunItem in
        dataSource[indexPath.section].items[indexPath.item]
      }
      .withLatestFrom(currentUser.compactMap { $0 }) { item, currentUser -> Reaction in
        Reaction(uuid: UUID(), userUID: currentUser.uid, publicationUUID: item.publication.uuid, reactionType: .downvote)
      }
    
    let saveReaction = Driver
      .of(upvoteReaction, downvoteReaction)
      .merge()
      .flatMapLatest { reaction -> Driver<Void> in
        reaction.saveToServer().debug().asDriver(onErrorJustReturn: ())
      }
    
    let scrollToNextCell = Driver
      .of(input.upvoteButtonTap, input.downvoteButtonTap)
      .merge()
    
    let saveView = scrolledUpperVisibleIndexPath
      .compactMap { $0 }
      .debug()
      .withLatestFrom(dataSource) { indexPath, dataSource -> FunItem in
        dataSource[indexPath.section].items[indexPath.row]
      }
      .debug()
      .withLatestFrom(currentUser) { funItem, currentUser -> FunItemView in
        if let currentUser = currentUser {
          return .user(userView: UserPublicationView(publicationUUID: funItem.publication.uuid, userUID: currentUser.uid))
        } else {
          return .device(deviceView: DevicePublicationView(
            publicationUUID: funItem.publication.uuid,
            deviceUUID: UIDevice.current.identifierForVendor as! UUID
          ))
        }
      }
      .debug()
      .flatMapLatest { funItemView -> Driver<Void> in
        switch funItemView {
        case .device(let deviceView):
          return deviceView.saveToServer().asDriver(onErrorJustReturn: ())
        case .user(let userView):
          return userView.saveToServer().asDriver(onErrorJustReturn: ())
        }
      }
      .debug()

    
    let loadMoreData = Driver<[FunSection]>.empty()
    
    return Output(
      navigateToAuth: navigateToAuth,
      reloadData: reloadData,
      loadMoreData: loadMoreData,
      scrollToNextCell: scrollToNextCell,
      saveReaction: saveReaction,
      saveView: saveView,
      dataSource: dataSource
    )
    
  }
  
}
