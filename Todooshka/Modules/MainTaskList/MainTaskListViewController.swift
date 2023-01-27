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
  public var viewModel: MainTaskListViewModel!
  public var sceneModel: MainTaskListSceneModel!

  private let disposeBag = DisposeBag()

  // MARK: - UI Elements - Scene
  private let scene: MainTaskListScene? = {
    let scene = SKScene(fileNamed: "MainTaskListScene") as? MainTaskListScene
    scene?.scaleMode = .aspectFill
    return scene
  }()

  private let sceneView: SKView = {
    let view = SKView(
      frame: CGRect(
        center: .zero,
        size: CGSize(
          width: Style.Scene.width,
          height: Style.Scene.height)))
    return view
  }()
  
 
  // MARK: - UI Elements - Task List
  private let overduedTasksButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 8
    button.setTitle("Просрочка", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    return button
  }()

  private let ideaTasksButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 8
    button.setTitle("Ящик идей", for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    return button
  }()
  
  private let calendarButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .clear
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 8
    button.setImage(Icon.calendar.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSection>!

  private let dragonContainerView = UIView()

  private let dragonImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "дракон_главный_экран")
    imageView.contentMode = .scaleAspectFit
    imageView.alpha = 0.1
    return imageView
  }()

  // MARK: - UI Elements - Alert
  private let alertContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()

  private let alertView: UIView = {
    let view = UIView()
    view.cornerRadius = 27
    view.backgroundColor = Style.App.background
    return view
  }()

  private let alertLabel: UILabel = {
    let label = UILabel(text: "Удалить задачу?")
    label.textColor = Style.App.text
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    return label
  }()

  private let alertDeleteButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Удалить",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    let button = UIButton(type: .custom)
    button.backgroundColor = Style.Buttons.AlertRoseButton.Background
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()

  private let alertCancelButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Отмена",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    let button = UIButton(type: .custom)
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text!.withAlphaComponent(0.5), for: .normal)
    return button
  }()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    configureDataSource()
    bindSceneModel()
    bindViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    scene?.reloadData()
    navigationController?.tabBarController?.tabBar.isHidden = false
  }

  // MARK: - Configure UI
  private func configureUI() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    view.backgroundColor = Style.App.background
    
    // adding 1 layer
    view.addSubviews([
      sceneView,
      dragonContainerView,
      overduedTasksButton,
      ideaTasksButton,
      calendarButton,
      collectionView,
      alertContainerView
    ])
    
    // adding 2 layer
    alertContainerView.addSubviews([
      alertView
    ])
    
    dragonContainerView.addSubviews([
      dragonImageView
    ])
    
    // adding 3 layer
    alertView.addSubviews([
      alertLabel,
      alertDeleteButton,
      alertCancelButton
    ])

    sceneView.presentScene(scene)
    sceneView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      heightConstant: sceneView.frame.height
    )
    
    overduedTasksButton.anchor(
      top: sceneView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: (UIScreen.main.bounds.width - 2 * 16 - 30) / 2 - 8,
      heightConstant: 30
    )
    
    calendarButton.anchor(
      top: sceneView.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: 30,
      heightConstant: 30
    )

    ideaTasksButton.anchor(
      top: sceneView.bottomAnchor,
      left: overduedTasksButton.rightAnchor,
      right: calendarButton.leftAnchor,
      topConstant: 16,
      leftConstant: 8,
      rightConstant: 8,
      heightConstant: 30
    )

    collectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseID)
    collectionView.register(
      TaskReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TaskReusableView.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.layer.masksToBounds = false
    collectionView.backgroundColor = .clear
    collectionView.anchor(
      top: overduedTasksButton.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )

    dragonContainerView.anchor(
      top: overduedTasksButton.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor
    )

    dragonImageView.anchorCenterXToSuperview()
    dragonImageView.anchorCenterYToSuperview(constant: -20)
    dragonImageView.anchor(heightConstant: Sizes.ImageViews.DragonImageView.height)
    
    alertContainerView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      bottom: view.bottomAnchor,
      right: view.rightAnchor
    )

    alertView.anchorCenterXToSuperview()
    alertView.anchorCenterYToSuperview()
    alertView.anchor(widthConstant: Sizes.Views.AlertDeleteView.width, heightConstant: Sizes.Views.AlertDeleteView.height)

    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * Sizes.Views.AlertDeleteView.height / 4)

    alertDeleteButton.cornerRadius = Sizes.Buttons.AlertOkButton.height / 2
    alertDeleteButton.anchorCenterXToSuperview()
    alertDeleteButton.anchorCenterYToSuperview(constant: Sizes.Buttons.AlertOkButton.height / 2)
    alertDeleteButton.anchor(
      widthConstant: Sizes.Buttons.AlertOkButton.width,
      heightConstant: Sizes.Buttons.AlertOkButton.height)

    alertCancelButton.anchorCenterXToSuperview()
    alertCancelButton.anchor(
      top: alertDeleteButton.bottomAnchor,
      topConstant: 10)
  }
  

  // MARK: - Main Task List Collection View
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 5, trailing: 0)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1.0))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0)
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(20))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
    section.boundarySupplementaryItems = [header]
    return section
  }
  
  private func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSection>(
      configureCell: { dataSource, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: TaskCell.reuseID,
          for: indexPath
        ) as? TaskCell else { return UICollectionViewCell() }
        cell.configure(mode: dataSource[indexPath.section].mode, task: item.task, kindOfTask: item.kindOfTask)
        cell.delegate = self
        return cell
      },
      configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: TaskReusableView.reuseID,
          for: indexPath
        ) as? TaskReusableView else { return UICollectionReusableView() }
        header.configure(text: dataSource[indexPath.section].header)
        return header
      }
    )
  }
  
  // MARK: - Bind
  func bindSceneModel() {
    let input = MainTaskListSceneModel.Input()
    let outputs = sceneModel.transform(input: input)

    [
      outputs.backgroundImage.drive(backgroundImageBinder),
      outputs.dataSource.drive(sceneDataBinder)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  func bindViewModel() {
    let input = MainTaskListViewModel.Input(
      overduedButtonClickTrigger: overduedTasksButton.rx.tap.asDriver(),
      ideaButtonClickTrigger: ideaTasksButton.rx.tap.asDriver(),
      calendarButtonClickTrigger: calendarButton.rx.tap.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver(),
      alertDeleteButtonClick: alertDeleteButton.rx.tap.asDriver(),
      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)
    
    [
      outputs.openOverduedTasklist.drive(),
      outputs.openIdeaTaskList.drive(),
      outputs.openCalendar.drive(),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.dataSource.drive(dataSourceBinder),
      outputs.reloadItems.drive(reloadItemsBinder),
      outputs.hideCellWhenAlertClosed.drive(hideCellBinder),
      outputs.openTask.drive(),
      outputs.changeTaskStatusToIdea.drive(),
      outputs.changeTaskStatusToDeleted.drive(),
      outputs.alertIsHidden.drive(alertContainerView.rx.isHidden)
    ]
      .forEach { $0.disposed(by: disposeBag) }

  }
  
  // MARK: - Scene Binders
  var backgroundImageBinder: Binder<UIImage?> {
    return Binder(self, binding: { vc, image in
      if let image = image, let scene = vc.scene {
        scene.setup(withBackground: image)
      }
    })
  }

  var sceneDataBinder: Binder<[EggActionType]> {
    return Binder(self, binding: { vc, actions in
      if let scene = vc.scene {
        scene.setup(with: actions)
        if vc.isVisible {
          scene.reloadData()
        }
      }
    })
  }
  
  // MARK: - Task List Binders
  var hideCellBinder: Binder<IndexPath> {
    return Binder(self, binding: { vc, indexPath in
      if let cell = vc.collectionView.cellForItem(at: indexPath) as? TaskCell {
        cell.hideSwipe(animated: true)
      }
    })
  }

  var reloadItemsBinder: Binder<[IndexPath]> {
    return Binder(self, binding: { vc, indexPaths in
      if self.viewModel.editingIndexPath == nil {
        vc.collectionView.reloadData()
      } else {
        UIView.performWithoutAnimation {
         vc.collectionView.reloadItems(at: indexPaths)
        }
      }
    })
  }

  var dataSourceBinder: Binder<[TaskListSection]> {
    return Binder(self, binding: { vc, dataSource in
      if dataSource.map { $0.items.count }.sum() == 0 {
        vc.dragonImageView.isHidden = false
      } else {
        vc.dragonImageView.isHidden = true
      }
    })
  }
}

// MARK: - SwipeCollectionViewCellDelegate
extension MainTaskListViewController: SwipeCollectionViewCellDelegate {
  func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {
    viewModel.editingIndexPath = indexPath
  }

  func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
    viewModel.editingIndexPath = nil
  }

  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.viewModel.swipeDeleteButtonClickTrigger.accept(indexPath)
    }

    let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      self.viewModel.swipeIdeaButtonClickTrigger.accept(indexPath)
    }

    configure(action: deleteAction, with: .trash)
    configure(action: ideaBoxAction, with: .idea)

    deleteAction.backgroundColor = Style.App.background
    ideaBoxAction.backgroundColor = Style.App.background

    return [deleteAction, ideaBoxAction]
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
    action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode, size: CGSize(width: 35, height: 35))

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
