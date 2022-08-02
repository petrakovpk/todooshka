//
//  UserProfileViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture
import SpriteKit
import SwiftUI
import SwifterSwift

enum ScrollToIndexPath{
  case Initial
  case Ready
  case Scrolled
}

class UserProfileViewController: UIViewController {
  
  // MARK: - Const
  private let itemSize = CGSize(width: 45.0, height: 45.0)
  private let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
  private var needScrollToToday: Bool = true
  
  // MARK: - Sprite Kit
  private let scene: UserProfileScene? = {
    let scene = SKScene(fileNamed: "UserProfileScene") as? UserProfileScene
    scene?.scaleMode = .aspectFill
    return scene
  }()
  
  private let sceneView: SKView = {
    let view = SKView(frame: CGRect(
      center: .zero,
      size: CGSize(
        width: Theme.Scene.width,
        height: Theme.Scene.height)))
    return view
  }()
  
  // MARK: - UI Elements
  private let settingsButton = TDRoundButton(type: .system)
  private let pointsBackgroundView = UIView()
  
  private let featherBackgroundView = UIView()
  private let diamondBackroundView = UIView()
  
  private let feathersImageView = UIImageView(image: UIImage(named: "feather"))
  private let diamondsImageView = UIImageView(image: UIImage(named: "diamond"))
  
  private let featherLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let diamondLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let shopButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Фабрика птиц", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.Cerise
    button.cornerRadius = 15
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return button
  }()
  
  private let calendarHeaderView: UILabel = {
    let label = UILabel()
    label.text = "Ваши результаты"
    label.textAlignment = .center
    return label
  }()
  
  private let calendarBackgroundView = UIView()
  private let calendarDividerView = UIView()
  private var calendarView = CalendarView(frame: .zero, collectionViewLayout: CalendarViewLayout())
  
  // MARK: - MVVM
  var userProfileViewModel: UserProfileViewModel!
  var userProfileSceneModel: UserProfileSceneModel!
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - Rx DataSources
  public var dataSource: [CalendarSectionModel] = []
  
  fileprivate var needsDelayedScrolling: ScrollToIndexPath = .Initial
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureScene()
    configureUI()
    bindUserProfileViewModel()
    bindUserProfileSceneModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    userProfileSceneModel.services.actionService.tabBarSelectedItem.accept(.TaskList)
    userProfileSceneModel.services.actionService.runUserProfileActionsTrigger.accept(())
  }
  

  
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      switch self.dataSource[sectionIndex].type {
      case .Month:
        return self.monthSection()
      case .Year:
        return self.yearSection()
      }
    }
  }
  
  
  
  private func monthSection() -> NSCollectionLayoutSection{
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(45.adjusted), heightDimension: .absolute(45.adjusted))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45.adjusted))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(5.adjusted)
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(25.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.boundarySupplementaryItems = [header]
    return section
  }
  
  private func yearSection() -> NSCollectionLayoutSection{
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(45.adjusted))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45.adjusted))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    return section
  }
  
  
  //MARK: - Configure UI
  func configureScene() {
    // adding
    view.addSubview(sceneView)
    
    // sceneView
    sceneView.presentScene(scene)
    sceneView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor,  heightConstant: sceneView.frame.height)
  }
  
  func configureUI() {
    
    // adding
    view.addSubview(settingsButton)
    view.addSubview(pointsBackgroundView)
    view.addSubview(shopButton)
    view.addSubview(calendarBackgroundView)
    
    // adding pointsBackgroundView
    pointsBackgroundView.addSubview(featherBackgroundView)
    pointsBackgroundView.addSubview(diamondBackroundView)
    
    // featherBackgroundView
    featherBackgroundView.addSubview(featherLabel)
    featherBackgroundView.addSubview(feathersImageView)
    
    // diamondBackroundView
    diamondBackroundView.addSubview(diamondLabel)
    diamondBackroundView.addSubview(diamondsImageView)
    
    // calendarBackgroundView
    calendarBackgroundView.addSubview(calendarHeaderView)
    calendarBackgroundView.addSubview(calendarDividerView)
    calendarBackgroundView.addSubview(calendarView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // settingsButton
    settingsButton.configure(image: UIImage(named: "setting")?.template, blurEffect: false)
    settingsButton.anchor(top: sceneView.bottomAnchor, right: view.rightAnchor, topConstant: 16, rightConstant: 16, widthConstant: 40.adjusted, heightConstant: 40.adjusted)
    
    // shopButton
    shopButton.anchor(top: sceneView.bottomAnchor, right: settingsButton.leftAnchor, topConstant: 16.superAdjusted, rightConstant: 16, widthConstant: (UIScreen.main.bounds.width - 32) / 2 - 56 - 8 , heightConstant: 40.superAdjusted)
    
    // pointsBackgroundView
    pointsBackgroundView.backgroundColor = .clear
    pointsBackgroundView.anchor(top: sceneView.bottomAnchor, left: view.leftAnchor, right: shopButton.leftAnchor, topConstant: 16, leftConstant: 16, rightConstant: 16, heightConstant: 40)
    
    // featherBackgroundView
    featherBackgroundView.borderColor = UIColor(hexString: "ec55d4")
    featherBackgroundView.borderWidth = 0.5
    featherBackgroundView.layer.cornerRadius = 15
    featherBackgroundView.anchor(top: pointsBackgroundView.topAnchor, left: pointsBackgroundView.leftAnchor, bottom: pointsBackgroundView.bottomAnchor, widthConstant: (UIScreen.main.bounds.width - 32) / 2 / 2 - 8 )
    
    // diamondBackroundView
    diamondBackroundView.borderColor = UIColor(hexString: "499cee")
    diamondBackroundView.borderWidth = 0.5
    diamondBackroundView.layer.cornerRadius = 15
    diamondBackroundView.anchor(top: pointsBackgroundView.topAnchor, bottom: pointsBackgroundView.bottomAnchor, right: pointsBackgroundView.rightAnchor, widthConstant: (UIScreen.main.bounds.width - 32) / 2 / 2 - 8 )
    
    // feathersImageView
    feathersImageView.anchor(top: featherBackgroundView.topAnchor, bottom: featherBackgroundView.bottomAnchor, right: featherBackgroundView.rightAnchor, topConstant: 4, bottomConstant: 4, rightConstant: 8, widthConstant: 20, heightConstant: 40)
    
    // featherLabel
    featherLabel.textAlignment = .center
    featherLabel.anchor(top: featherBackgroundView.topAnchor, left: featherBackgroundView.leftAnchor, bottom: featherBackgroundView.bottomAnchor, right: feathersImageView.leftAnchor, topConstant: 4, leftConstant: 8, bottomConstant: 4, rightConstant: 8)
    
    // diamondsImageView
    diamondsImageView.anchor(top: diamondBackroundView.topAnchor, bottom: diamondBackroundView.bottomAnchor, right: diamondBackroundView.rightAnchor, topConstant: 4, bottomConstant: 4, rightConstant: 8, widthConstant: 20, heightConstant: 40)
    
    // diamondLabel
    diamondLabel.textAlignment = .center
    diamondLabel.anchor(top: diamondBackroundView.topAnchor, left: diamondBackroundView.leftAnchor, bottom: diamondBackroundView.bottomAnchor, right: diamondsImageView.leftAnchor, topConstant: 4, leftConstant: 8, bottomConstant: 4, rightConstant: 8)
    
    // calendarBackgroundView
    calendarBackgroundView.backgroundColor = Theme.UserProfile.Calendar.background
    calendarBackgroundView.cornerRadius = 11
    calendarBackgroundView.anchor(top: shopButton.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 30.superAdjusted, leftConstant: 16, bottomConstant: 32.superAdjusted, rightConstant: 16)
    
    // calendarHeaderView
    calendarHeaderView.anchor(top: calendarBackgroundView.topAnchor, left: calendarBackgroundView.leftAnchor, right: calendarBackgroundView.rightAnchor, topConstant: 8.superAdjusted, leftConstant: 16.adjusted, bottomConstant: 16.superAdjusted, rightConstant: 16.adjusted, heightConstant: 30)
    
    //calendarDividerView
    calendarDividerView.backgroundColor = Theme.UserProfile.Calendar.divider
    calendarDividerView.anchor(top: calendarHeaderView.bottomAnchor, left: calendarBackgroundView.leftAnchor, right: calendarBackgroundView.rightAnchor, topConstant: 8.superAdjusted, leftConstant: 16.adjusted, bottomConstant: 16.superAdjusted, rightConstant: 16.adjusted, heightConstant: 1)
    
    // calendarView
    calendarView.delegate = self
    calendarView.dataSource = self
    calendarView.calendarViewDelegate = self
    calendarView.anchor(top: calendarDividerView.bottomAnchor, left: calendarBackgroundView.leftAnchor, bottom: calendarBackgroundView.bottomAnchor, right: calendarBackgroundView.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8)
  }
  
  
  
  //MARK: - Bind To
  func bindUserProfileViewModel() {
    
    let input = UserProfileViewModel.Input(
      settingsButtonClickTrigger: settingsButton.rx.tap.asDriver() ,
      shopButtonClickTrigger: shopButton.rx.tap.asDriver(),
      featherBackgroundViewClickTrigger: featherBackgroundView.rx.tapGesture().when(.recognized).map{ _ in return () }.asDriver(onErrorJustReturn: ()),
      diamondBackgroundViewClickTrigger: diamondBackroundView.rx.tapGesture().when(.recognized).map{ _ in return () }.asDriver(onErrorJustReturn: ()),
      selection: calendarView.rx.itemSelected.asDriver(),
      willDisplayCell: calendarView.rx.willDisplayCell.asDriver()
    )
    
    let outputs = userProfileViewModel.transform(input: input)
    
    [
      outputs.dataSource.drive(dataSourceBinder),
      outputs.settingsButtonClickHandler.drive(),
      outputs.shopButtonClickHandler.drive(),
      outputs.selectionHandler.drive(),
      outputs.featherScoreLabel.drive(featherLabel.rx.text),
      outputs.diamondScoreLabel.drive(diamondLabel.rx.text),
      outputs.featherBackgroundViewClickHandler.drive(),
      outputs.diamondBackgroundViewClickHandler.drive(),
      outputs.willDisplayCell.drive(),
      outputs.scrollToCurrentMonth.drive(scrollToCurrentMonthBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
    
    
  }
  
  func bindUserProfileSceneModel() {
    let input = UserProfileSceneModel.Input()
    let outputs = userProfileSceneModel.transform(input: input)
    
    [
      // scene
      outputs.background.drive(sceneBackgroundBinder),
      // actions
      outputs.runActions.drive(runActionsBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  // MARK: - Binder
  var sceneBackgroundBinder: Binder<UIImage?> {
    return Binder(self, binding: { (vc, image) in
      if let image = image {
        vc.scene?.setupBackgroundNode(image: image)
      }
    })
  }
  
  var scrollToCurrentMonthBinder: Binder<(trigger: Bool, withAnimation: Bool)> {
    return Binder(self, binding: { vc, scrollEvent in
      
      if scrollEvent.trigger {
        // иначе не получим лейаут
        vc.calendarView.layoutIfNeeded()
        
        // получаем секцию куда будем скролить
        guard let sectionIndex = self.dataSource.firstIndex(where: { $0.month == Date().month }) else { return }
        guard let layoutAttributesForSupplementaryElement = vc.calendarView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: sectionIndex)) else { return }

        // Скроллим
        vc.calendarView.collectionViewLayout.invalidateLayout()
        vc.calendarView.collectionViewLayout.prepare()
        vc.calendarView.setContentOffset(CGPoint(x: 0, y: layoutAttributesForSupplementaryElement.frame.origin.y), animated: scrollEvent.withAnimation)
      }
      
      
    })
  }
  
  var dataSourceBinder: Binder<[CalendarSectionModel]> {
    return Binder(self, binding: { vc, newDataSource in
      let oldDataSource = self.dataSource
      self.dataSource = newDataSource
      
      // Добавляем предыдущий месяц - если в новом dataSource первый месяц меньше, чем в старом dataSource
      if let firstSectionOldDataSource = oldDataSource.first,
         let firstSectionNewDataSource  = newDataSource.first,
         firstSectionNewDataSource.year * 12 + firstSectionNewDataSource.month < firstSectionOldDataSource.year * 12 + firstSectionOldDataSource.month {
        
        // получаем лейауты
        guard let firstSectionHeaderLayout = vc.calendarView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) else { return }
        guard let firstItemFirstSectionLayout = vc.calendarView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) else { return }
        
        // получаем количество строк в первой секции
        let firstSectionRowCount = ceilf(firstSectionNewDataSource.items.count.float / 7).cgFloat
        
        UIView.performWithoutAnimation {
          vc.calendarView.insertSections(IndexSet(integer: 0))
          vc.calendarView.contentOffset.y = vc.calendarView.contentOffset.y + firstSectionHeaderLayout.bounds.height + firstSectionRowCount * (firstItemFirstSectionLayout.bounds.height + vc.calendarView.layoutMargins.top) + self.sectionInset.bottom
        }
      }
      
      
      // Добавляем будущий месяц - если в новом dataSource последний месяц больше, чем в старом dataSource
      if let lastSectionOldDataSource = oldDataSource.last,
         let lastSectionNewDataSource = newDataSource.last,
         lastSectionNewDataSource.year * 12 + lastSectionNewDataSource.month > lastSectionOldDataSource.year * 12 + lastSectionOldDataSource.month {
        UIView.performWithoutAnimation {
          vc.calendarView.insertSections(IndexSet(integer: newDataSource.count - 1))
        }
      }
      
      // Перегружаем выбранный месяц
      var previousSelectedDate: Date?
      
      for model in oldDataSource {
        for day in model.items {
          if day.isSelected {
            previousSelectedDate = day.date
          }
        }
      }
      
      for (section, model) in newDataSource.enumerated() {
        for (item, day) in model.items.enumerated() {
          if day.date == previousSelectedDate || day.isSelected {
            UIView.performWithoutAnimation {
              vc.calendarView.reloadItems(at: [IndexPath(item: item, section: section)])
            }
          }
        }
      }
    })
  }
  
  var runActionsBinder: Binder<[SceneAction]> {
    return Binder(self, binding: { (vc, actions) in
      if let scene = vc.scene {
        scene.runActions(actions: actions)
        vc.userProfileSceneModel.services.actionService.removeActions(actions: actions)
      }
    })
  }
}


extension UserProfileViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    dataSource.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    dataSource[section].items.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch dataSource[indexPath.section].type {
    case .Month:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseID, for: indexPath) as! CalendarCell
      if indexPath.section < dataSource.count && indexPath.item < dataSource[indexPath.section].items.count {
        cell.configure(calendarDay: dataSource[indexPath.section].items[indexPath.item])
      }
      return cell
    case .Year:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarYearCell.reuseID, for: indexPath) as! CalendarYearCell
      cell.configure(year: dataSource[indexPath.section].year)
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalendarReusableView.reuseID, for: indexPath) as! CalendarReusableView
    header.label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    header.label.textAlignment = .left
    header.label.text = dataSource[indexPath.section].monthName
    header.label.text?.firstCharacterUppercased()
    return header
  }
}

extension UserProfileViewController: CalendarViewDelegate {
  
  func appendPastData() {
    userProfileViewModel.appendPastData()
  }
  
  func appendFutureData() {
    userProfileViewModel.appendFutureData()
  }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    itemSize
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    sectionInset
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    CGSize(width: collectionView.bounds.width, height: 30)
  }
}

