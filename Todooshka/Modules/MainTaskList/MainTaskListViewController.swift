//
//  MainTaskListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import SpriteKit
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit
import RxGesture
import Lottie

class MainTaskListViewController: UIViewController {
  
  // MARK: - Properties
  let disposeBag = DisposeBag()
  
  // view models
  var mainTaskListSceneModel: MainTaskListSceneModel!
  var mainTaskListViewModel: MainTaskListViewModel!
  var taskListViewModel: TaskListViewModel!
  
  // MARK: - UI Elements
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>!
  
  private let taskCountLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18.adjusted, weight: .semibold)
    return label
  }()
  
  private let animationView = AnimationView(name: "task_animation")
  
  private let expandImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    imageView.image = UIImage(named: "arrow-top")
    return imageView
  }()
  
  private let alertView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let alertSubView: UIView = {
    let view = UIView()
    view.cornerRadius = 27
    view.backgroundColor = Theme.App.background
    return view
  }()
  
  private let alertLabel: UILabel = {
    let label = UILabel(text: "")
    label.textColor = Theme.App.text
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 17.adjusted, weight: .medium)
    return label
  }()
  
  private let alertDeleteButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    let attrString = NSAttributedString(string: "Удалить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.adjusted, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let alertCancelButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.adjusted, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Theme.App.text!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  private let scene: MainTaskListScene? = {
    let scene = SKScene(fileNamed: "MainTaskListScene") as? MainTaskListScene
    scene?.scaleMode = .aspectFill
    return scene
  }()
  
  private let sceneView: SKView = {
    let view = SKView(frame: CGRect(
      center: .zero,
      size: CGSize(
        width: Theme.MainTaskListScene.Scene.width,
        height: Theme.MainTaskListScene.Scene.height)))
    return view
  }()
  
  private let overduedTasksButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("Просрочка", for: .normal)
    button.setTitleColor(Theme.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    button.cornerRadius = 15
    button.backgroundColor = Theme.MainTaskList.buttonBackground
    return button
  }()
  
  private let ideaTasksButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("Ящик идей", for: .normal)
    button.setTitleColor(Theme.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    button.cornerRadius = 15
    button.backgroundColor = Theme.MainTaskList.buttonBackground
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureScene()
    configureUI()
    configureAlert()
    configureDataSource()
    bindSceneModel()
    bindMainViewModel()
    bindTaskListViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.tabBarController?.tabBar.isHidden = false
    taskListViewModel.viewWillAppear()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    mainTaskListSceneModel.services.actionService.tabBarSelectedItem.accept(.TaskList)
    mainTaskListSceneModel.services.actionService.runActionsTrigger.accept(())
  }
  
  // MARK: - Configure Scene
  func configureScene() {
    view.addSubview(sceneView)
    sceneView.presentScene(scene)
    sceneView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor,  heightConstant: sceneView.frame.height)
  }
  
  // MARK: - ConfigureUI
  private func configureUI() {
    // collectionView
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    // add
    view.addSubview(animationView)
    view.addSubview(overduedTasksButton)
    view.addSubview(ideaTasksButton)
    view.addSubview(collectionView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // animationView
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .repeat(3.0)
    animationView.animationSpeed = 1.0
    animationView.anchorCenterXToSuperview()
    animationView.anchorCenterYToSuperview()
    animationView.anchor(heightConstant: 222.0.adjusted)
    
    // expiredTasksButton
    overduedTasksButton.anchor(top: sceneView.bottomAnchor, left: view.leftAnchor, topConstant: 16, leftConstant: 16, widthConstant: UIScreen.main.bounds.width / 2 - 16 - 8, heightConstant: 40)
    
    // ideaTasksButton
    ideaTasksButton.anchor(top: sceneView.bottomAnchor, right: view.rightAnchor, topConstant: 16, rightConstant: 16, widthConstant: UIScreen.main.bounds.width / 2 - 16 - 8, heightConstant: 40)
    
    // collectionView
    collectionView.register(TaskListCell.self, forCellWithReuseIdentifier: TaskListCell.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.layer.masksToBounds = true
    collectionView.backgroundColor = .clear
    collectionView.anchor(top: overduedTasksButton.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
    
  }
  
  private func configureAlert() {
    view.addSubview(alertView)
    alertView.addSubview(alertSubView)
    alertSubView.addSubview(alertLabel)
    alertSubView.addSubview(alertDeleteButton)
    alertSubView.addSubview(alertCancelButton)
    
    // alertView
    alertView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // alertSubView
    alertSubView.anchor(widthConstant: 287.adjusted, heightConstant: 171.adjusted)
    alertSubView.anchorCenterXToSuperview()
    alertSubView.anchorCenterYToSuperview()
    
    // alertLabel
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171.adjusted / 4)
    
    // alertDeleteButton
    alertDeleteButton.anchor(widthConstant: 94.adjusted, heightConstant: 30.adjusted)
    alertDeleteButton.cornerRadius = 15.adjusted
    alertDeleteButton.anchorCenterXToSuperview()
    alertDeleteButton.anchorCenterYToSuperview(constant: 15.adjusted)
    
    // alertCancelButton
    alertCancelButton.anchor(top: alertDeleteButton.bottomAnchor, topConstant: 10.adjusted)
    alertCancelButton.anchorCenterXToSuperview()
  }
  
  //MARK: - Configure Data Source
  private func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>(
      configureCell: { (_, collectionView, indexPath, task) in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCell.reuseID, for: indexPath) as! TaskListCell
        let cellViewModel = TaskListCellModel(services: self.mainTaskListViewModel.services, task: task)
        cell.viewModel = cellViewModel
        cell.delegate = cellViewModel
        cell.disposeBag = DisposeBag()
        cell.bindViewModel()
        return cell
      })
  }
  
  //MARK: - Setup CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(62))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets =  NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0)
    return section
  }
  
  //MARK: - Bind To
  func bindSceneModel() {
    
    let input = MainTaskListSceneModel.Input()
    
    let outputs = mainTaskListSceneModel.transform(input: input)
    
    [
      outputs.background.drive(sceneBackgroundBinder),
      // eggs
//      outputs.createEggs.drive(),
//      outputs.removeEggs.drive(),
//      outputs.changeEggsClade.drive(),
      // actions
      outputs.saveAction.drive(),
      outputs.runActions.drive(runActionsBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
    
  }
  
  func bindMainViewModel() {
    let input = MainTaskListViewModel.Input(
      ideaButtonClickTrigger: ideaTasksButton.rx.tap.asDriver(),
      overduedButtonClickTrigger: overduedTasksButton.rx.tap.asDriver()
    )
    
    let outputs = mainTaskListViewModel.transform(input: input)
    
    [
      outputs.ideaButtonClick.drive(),
      outputs.overduedButtonClick.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  func bindTaskListViewModel() {
    let input = TaskListViewModel.Input(
      // selection
      selection: collectionView.rx.itemSelected.asDriver(),
      // alert
      alertDeleteButtonClick: alertDeleteButton.rx.tap.asDriver(),
      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver(),
      // back
      backButtonClickTrigger: nil,
      // add
      addTaskButtonClickTrigger: nil,
      // remove all
      removeAllDeletedTasksButtonClickTrigger: nil
    )
    
    let outputs = taskListViewModel.transform(input: input)
    
    [
      // dataSource
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.dataSource.drive(dataSourceBinder),
      // selection
      outputs.selection.drive(),
      // alert
      outputs.alertText.drive(alertLabel.rx.text),
      outputs.alertDeleteButtonClick.drive(),
      outputs.alertCancelButtonClick.drive(),
      outputs.alertIsHidden.drive(alertView.rx.isHidden)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  //MARK: - Binders
  var sceneBackgroundBinder: Binder<UIImage?> {
    return Binder(self, binding: { (vc, image) in
      if let image = image {
        vc.scene?.updateBackgroundImage(image: image)
      }
    })
  }
  
  var runActionsBinder: Binder<[MainTaskListSceneAction]> {
    return Binder(self, binding: { (vc, actions) in
      if let scene = vc.scene {
        scene.runActions(actions: actions)
        vc.mainTaskListSceneModel.services.actionService.removeActions(actions: actions)
      }
    })
  }
  
  var dataSourceBinder: Binder<[TaskListSectionModel]> {
    return Binder(self, binding: { (vc, dataSource) in
      if dataSource.count == 0 {
        vc.animationView.play(toProgress: 1.0)
        vc.animationView.isHidden = false
      } else {
        vc.animationView.isHidden = true
      }
    })
  }
}
