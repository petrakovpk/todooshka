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
  var sceneModel: NestSceneModel!
  var viewModel: MainTaskListViewModel!
  var listViewModel: TaskListViewModel!
  
  // MARK: - UI Elements
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSection>!
  
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
  
  private let scene: NestScene? = {
    let scene = SKScene(fileNamed: "NestScene") as? NestScene
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
  
  private let overduedTasksButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = Theme.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 15
    button.setTitle("Просрочка", for: .normal)
    button.setTitleColor(Theme.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return button
  }()
  
  private let ideaTasksButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = Theme.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 15
    button.setTitle("Ящик идей", for: .normal)
    button.setTitleColor(Theme.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureScene()
    configureUI()
    configureAlert()
    configureDataSource()
    bindSceneModel()
    bindViewModel()
    bindListViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    scene?.reloadData()
    navigationController?.tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
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
    collectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.layer.masksToBounds = false
    collectionView.backgroundColor = .clear
    collectionView.anchor(top: overduedTasksButton.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
    
  }
  
  private func configureAlert() {
    
    // adding
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
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSection>(
      configureCell: { dataSource, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.reuseID, for: indexPath) as! TaskCell
        cell.configure(with: dataSource[indexPath.section].mode)
        cell.configure(with: item.task)
        cell.configure(with: item.kindOfTask)
        cell.delegate = self
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
  
  // MARK: - Bind Scene Model
  func bindSceneModel() {
    
    let input = NestSceneModel.Input()
    let outputs = sceneModel.transform(input: input)
    
    [
      // scene
      outputs.backgroundImage.drive(backgroundImageBinder),
      // dataSource
      outputs.dataSource.drive(sceneDataSourceBinder),
    ]
      .forEach({ $0.disposed(by: disposeBag) })
    
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    let input = MainTaskListViewModel.Input(
      ideaButtonClickTrigger: ideaTasksButton.rx.tap.asDriver(),
      overduedButtonClickTrigger: overduedTasksButton.rx.tap.asDriver() )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.ideaButtonClick.drive(),
      outputs.overduedButtonClick.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  // MARK: - Bind Task List Model
  func bindListViewModel() {
        
    let input = TaskListViewModel.Input(
      // selection
      selection: collectionView.rx.itemSelected.asDriver(),
      // alert
      alertDeleteButtonClick: alertDeleteButton.rx.tap.asDriver(),
      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver(),
      // back
      backButtonClickTrigger: Driver<Void>.of(),
      // add
      addTaskButtonClickTrigger: Driver<Void>.of(),
      // remove all
      removeAllButtonClickTrigger: Driver<Void>.of()
    )
    
    let outputs = listViewModel.transform(input: input)
    
    [
      outputs.change.drive(changeBinder),
      outputs.hideAlert.drive(hideAlertBinder),
      outputs.hideCell.drive(hideCellBinder),
      outputs.openTask.drive(),
      outputs.removeTask.drive(),
      outputs.reloadData.drive(reloadDataBinder),
      outputs.setAlertText.drive(alertLabel.rx.text),
      outputs.setDataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.setDataSource.drive(dataSourceBinder),
      outputs.showAlert.drive(showAlertBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  // MARK: - Binders
  var changeBinder: Binder<Result<Void, Error>> {
    return Binder(self, binding: { (vc, _) in
      vc.collectionView.reloadData()
    })
  }
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertView.isHidden = true
    })
  }
  
  var hideCellBinder: Binder<IndexPath> {
    return Binder(self, binding: { (vc, indexPath) in
      if let cell = vc.collectionView.cellForItem(at: indexPath) as? TaskCell {
        cell.hideSwipe(animated: true)
      }
    })
  }
  
  var reloadDataBinder: Binder<[IndexPath]> {
    return Binder(self, binding: { (vc, indexPaths) in
      if self.listViewModel.editingIndexPath == nil {
        vc.collectionView.reloadData()
      } else {
        UIView.performWithoutAnimation {
         vc.collectionView.reloadItems(at: indexPaths)
       }
      }
    })
  }
  
  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertView.isHidden = false
    })
  }

  var sceneDataSourceBinder: Binder<[EggActionType]> {
    return Binder(self, binding: { (vc, actions) in
      if let scene = vc.scene {
        scene.setup(with: actions)
        if vc.isVisible {
          scene.reloadData()
        }
      }
    })
  }
  
  var backgroundImageBinder: Binder<UIImage?> {
    return Binder(self, binding: { (vc, image) in
      if let image = image, let scene = vc.scene {
        scene.setup(with: image)
      }
    })
  }
  
  var dataSourceBinder: Binder<[TaskListSection]> {
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


extension MainTaskListViewController: SwipeCollectionViewCellDelegate {
  
  func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {
    listViewModel.editingIndexPath = indexPath
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
    listViewModel.editingIndexPath = nil
  }
  
  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    
    let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.listViewModel.changeStatus(indexPath: indexPath, status: .Deleted, completed: nil)
    }
    
    let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.listViewModel.changeStatus(indexPath: indexPath, status: .Idea, completed: nil)
    }
    
    let completeTaskAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.listViewModel.changeStatus(indexPath: indexPath, status: .Completed, completed: Date())
    }
    
    configure(action: deleteAction, with: .trash)
    configure(action: ideaBoxAction, with: .idea)
    configure(action: completeTaskAction, with: .complete)
    
    deleteAction.backgroundColor = Theme.App.background
    ideaBoxAction.backgroundColor = Theme.App.background
    completeTaskAction.backgroundColor = Theme.App.background
    
    return [completeTaskAction, deleteAction, ideaBoxAction]
  }
  
  func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    var options = SwipeOptions()
    options.expansionStyle = .destructive
    options.transitionStyle = .border
    options.buttonSpacing = 4
    return options
  }
  
  func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
    let buttonDisplayMode: ButtonDisplayMode = .imageOnly
    let buttonStyle: ButtonStyle = .circular
    
    action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
    action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode, size: CGSize(width: 44, height: 44))
    
    switch buttonStyle {
    case .backgroundColor:
      action.backgroundColor = descriptor.color(forStyle: buttonStyle)
    case .circular:
      action.backgroundColor = .clear
      action.textColor = descriptor.color(forStyle: buttonStyle)
      action.font = .systemFont(ofSize: 9)
      action.transitionDelegate = ScaleTransition.default
    }
  }
  
}

