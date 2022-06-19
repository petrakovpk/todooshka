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

class UserProfileViewController: UIViewController {
  
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
  
  var collectionView: UICollectionView!
  
  // MARK: - MVVM
  var userProfileViewModel: UserProfileViewModel!
  var userProfileSceneModel: UserProfileSceneModel!
  
  // MARK: - Rx
  private let disposeBag = DisposeBag()
  
  // MARK: - Rx DataSources
  var dataSource: RxCollectionViewSectionedReloadDataSource<CalendarSectionModel>!
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureScene()
    configureUI()
    configureDataSource()
    bindUserProfileViewModel()
    bindUserProfileSceneModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    userProfileSceneModel.services.actionService.tabBarSelectedItem.accept(.TaskList)
    userProfileSceneModel.services.actionService.runUserProfileActionsTrigger.accept(())
    if let attributes =
        collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 1)) {
      collectionView.setContentOffset(CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top), animated: false)
    }
  }
  
  //MARK: - Configure UI
  func configureScene() {
    view.addSubview(sceneView)
    sceneView.presentScene(scene)
    sceneView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor,  heightConstant: sceneView.frame.height)
  }
  
  func configureUI() {
    
    // collection view
    collectionView = UICollectionView(frame: .zero , collectionViewLayout: createCompositionalLayout())
    
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
    calendarBackgroundView.addSubview(collectionView)
    
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
    
    // collectionView
    collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseID )
    collectionView.register(CalendarReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalendarReusableView.reuseID)
    collectionView.backgroundColor = UIColor.clear
    collectionView.showsVerticalScrollIndicator = false
    collectionView.anchor(top: calendarDividerView.bottomAnchor, left: calendarBackgroundView.leftAnchor, bottom: calendarBackgroundView.bottomAnchor, right: calendarBackgroundView.rightAnchor, topConstant: 8.superAdjusted, leftConstant: 16.adjusted, bottomConstant: 16.superAdjusted, rightConstant: 16.adjusted)
    
  }
  
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection{
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(45.adjusted), heightDimension: .absolute(45.adjusted))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(45.adjusted))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(5.adjusted)
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(25.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.boundarySupplementaryItems = [header]
    return section
  }
  
  //MARK: - Bind To
  func bindUserProfileViewModel() {
    
    let input = UserProfileViewModel.Input(
      settingsButtonClickTrigger: settingsButton.rx.tap.asDriver() ,
      shopButtonClickTrigger: shopButton.rx.tap.asDriver(),
      scoreBackgroundClickTrigger: pointsBackgroundView.rx
        .tapGesture()
        .when(.recognized)
        .map{ _ in return () }
        .asDriver(onErrorJustReturn: ()),
      selection: collectionView.rx.itemSelected.asDriver()
    )
    
    let outputs = userProfileViewModel.transform(input: input)
    
    [
      outputs.settingsButtonClickHandler.drive(),
      outputs.shopButtonClickHandler.drive(),
      outputs.selectionHandler.drive(),
      outputs.featherScoreLabel.drive(featherLabel.rx.text),
      outputs.diamondScoreLabel.drive(diamondLabel.rx.text),
      outputs.scoreBackgroundClickHandler.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
    
    [
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource))
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
  
  var runActionsBinder: Binder<[SceneAction]> {
    return Binder(self, binding: { (vc, actions) in
      if let scene = vc.scene {
        scene.runActions(actions: actions)
        vc.userProfileSceneModel.services.actionService.removeActions(actions: actions)
      }
    })
  }
  
  //MARK: - Configure Data Source
  func configureDataSource() {
    dataSource = RxCollectionViewSectionedReloadDataSource<CalendarSectionModel>(configureCell: {(dataSource, collectionView, indexPath, calendarDay) in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.reuseID, for: indexPath) as! CalendarCell
      cell.configure(calendarDay: calendarDay)
      return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalendarReusableView.reuseID, for: indexPath) as! CalendarReusableView
      section.label.text = dataSource[indexPath.section].header
      return section
    })
  }
}


