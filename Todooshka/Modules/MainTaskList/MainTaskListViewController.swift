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
import JTAppleCalendar

class MainTaskListViewController: UIViewController {
  public var mainSceneModel: MainSceneModel!
  public var mainViewModel: MainTaskListViewModel!
  public var taskListViewModel: TaskListViewModel!
  public var calendarViewModel: CalendarViewModel!
  
  private let disposeBag = DisposeBag()
  
  private var isCalendarAnimationRunning: Bool = false
  private var isCalendarInShortMode: Bool = false
  private var selectedDate: Date = Date()
  private var displayDate: Date = Date()
  private var calendarDataSource: [CalendarSection] = []
  
  // MARK: - UI Elements - Scene
  private let mainSceneleft: MainScene? = {
    let scene = SKScene(fileNamed: "MainScene") as? MainScene
    scene?.scaleMode = .aspectFill
    return scene
  }()
  
  private let mainSceneRight: MainScene? = {
    let scene = SKScene(fileNamed: "MainScene") as? MainScene
    scene?.scaleMode = .aspectFill
    return scene
  }()

  private let mainSceneLeftView: SKView = {
    let view = SKView(
      frame: CGRect(
        center: .zero,
        size: CGSize(
          width: Style.Scene.width,
          height: Style.Scene.height)))
    return view
  }()
  
  private let mainSceneRightView: SKView = {
    let view = SKView(
      frame: CGRect(
        center: .zero,
        size: CGSize(
          width: Style.Scene.width,
          height: Style.Scene.height)))
    return view
  }()
  
  // MARK: - UI Elements - Main Task List
  private let taskListContainerView: UIView = {
    let view = UIView()
    return view
  }()
  
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
  
  private var mainTaskListCollectionView: UICollectionView!
  private var mainTaskListDataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSection>!

  private let dragonBackgroundView = UIView()

  private let dragonImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "дракон_главный_экран")
    imageView.contentMode = .scaleAspectFit
    imageView.alpha = 0.1
    return imageView
  }()

  // MARK: - UI Elements - Calendar
  private let calendarContainerView: UIView = {
    let view = UIView()
    return view
  }()
  
  private let taskListButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .clear
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 8
    button.setImage(Icon.taskListSquare.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()
  
  private var calendarNavigateButtonsStackView: UIStackView!
  private var calendarDayNamesStackView: UIStackView!
  
  private let monthLabelSpacerLeftView: UIView = {
    let view = UIView()
    view.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    view.cornerRadius = 8
    view.layer.maskedCorners = [.layerMinXMinYCorner]
    return view
  }()
  
  private let monthLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    label.tintColor = Style.App.text
    return label
  }()
  
  private let changeCalendarModeButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.tintColor = Style.App.text
    button.setImage(Icon.arrowTop.image.template, for: .normal)
    button.cornerRadius = 8
    button.layer.maskedCorners = [.layerMaxXMinYCorner]
    return button
  }()
  
  private let shopButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 8
    button.imageView?.contentMode = .scaleAspectFit
    button.tintColor = Style.App.text
    button.setTitle("7", for: .normal)
    return button
  }()

  private let scrollToPreviousPeriodButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 8
    button.tintColor = Style.App.text
    button.setImage(Icon.arrowCircleLeft.image.template, for: .normal)
    button.imageView?.layer.masksToBounds = false
    return button
  }()
  
  private let scrollToNextPeriodButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.cornerRadius = 8
    button.tintColor = Style.App.text
    button.setImage(Icon.arrowCircleRight.image.template, for: .normal)
    return button
  }()
  
  public let mondayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ПН"
    return label
  }()
  
  public let tuesdayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ВТ"
    return label
  }()
  
  public let wednesdayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "СР"
    return label
  }()
  
  public let thursdayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ЧТ"
    return label
  }()
  
  public let fridayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ПТ"
    return label
  }()
  
  public let saturdayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "СБ"
    return label
  }()
  
  public let sundayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
    label.text = "ВС"
    return label
  }()
  
  
  private let calendarView: JTACMonthView = {
    let calendarView = JTACMonthView()
    calendarView.layer.cornerRadius = 8
    calendarView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    calendarView.backgroundColor = Style.Views.Calendar.Background
    calendarView.register(
      CalendarReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CalendarReusableView.reuseID)
    calendarView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseID)
    calendarView.scrollingMode = .stopAtEachSection
    calendarView.scrollDirection = .horizontal
    calendarView.showsHorizontalScrollIndicator = false
    calendarView.minimumLineSpacing = 1
    calendarView.minimumInteritemSpacing = 1
    calendarView.cellSize = Sizes.Cells.CalendarCell.size
    calendarView.selectDates([Date()])
    return calendarView
  }()
  
  private let dayTasksLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    return label
  }()
  
  private let addTaskButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .clear
    button.cornerRadius = 8
    button.setImage(Icon.addSquare.image.template, for: .normal)
    button.tintColor = Style.App.text
    return button
  }()
  
  private var calendarTaskListCollectionView: UICollectionView!
  private var calendarTaskListDataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSection>!
  
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
    let label = UILabel(text: "")
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
    configureMainTaskListDataSource()
    configureCalendarTaskListDataSource()
    bindMainSceneModel()
    bindViewModel()
    bindMainTaskListViewModel()
    bindCalendarViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    taskListScene?.reloadData()
//    viewModel.services.dataService.checkPlannedTasksTrigger.accept(())
    navigationController?.tabBarController?.tabBar.isHidden = false
  }

  // MARK: - Configure UI
  private func configureUI() {
    view.backgroundColor = Style.App.background
    
    // adding 1 layer
    view.addSubviews([
      taskListContainerView,
      calendarContainerView,
      alertContainerView
    ])
    
    // adding 2 layer
    alertContainerView.addSubviews([
      alertView
    ])
    
    // adding 3 layer
    alertView.addSubviews([
      alertLabel,
      alertDeleteButton,
      alertCancelButton
    ])

    taskListContainerView.frame = CGRect(
      x: 0,
      y: 0,
      width: view.frame.width,
      height: self.view.bounds.height - (self.tabBarController?.tabBar.bounds.height ?? 0)
    )
    
    calendarContainerView.frame = CGRect(
        x: self.view.frame.width,
        y: 0,
        width: view.frame.width,
        height: self.view.bounds.height - (self.tabBarController?.tabBar.bounds.height ?? 0)
    )

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
    
    configureTaskListUI()
    configureCalendarUIFirstStep()
  }
  
  private func configureTaskListUI() {
    mainTaskListCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createMainTaskListCompositionalLayout())
    
    // adding 2 layer
    taskListContainerView.addSubviews([
      mainSceneLeftView,
      dragonBackgroundView,
      overduedTasksButton,
      ideaTasksButton,
      calendarButton,
      mainTaskListCollectionView
    ])
    
    // adding 3 layer
    dragonBackgroundView.addSubviews([
      dragonImageView
    ])
    
    mainSceneLeftView.presentScene(mainSceneleft)
    mainSceneLeftView.anchor(
      top: taskListContainerView.topAnchor,
      left: taskListContainerView.leftAnchor,
      right: taskListContainerView.rightAnchor,
      heightConstant: mainSceneLeftView.frame.height
    )
    
    overduedTasksButton.anchor(
      top: mainSceneLeftView.bottomAnchor,
      left: taskListContainerView.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: (UIScreen.main.bounds.width - 2 * 16 - 30) / 2 - 8,
      heightConstant: 30
    )
    
    calendarButton.anchor(
      top: mainSceneLeftView.bottomAnchor,
      right: taskListContainerView.rightAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: 30,
      heightConstant: 30
    )

    ideaTasksButton.anchor(
      top: mainSceneLeftView.bottomAnchor,
      left: overduedTasksButton.rightAnchor,
      right: calendarButton.leftAnchor,
      topConstant: 16,
      leftConstant: 8,
      rightConstant: 8,
      heightConstant: 30
    )

    mainTaskListCollectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseID)
    mainTaskListCollectionView.register(
      TaskReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TaskReusableView.reuseID)
    mainTaskListCollectionView.alwaysBounceVertical = true
    mainTaskListCollectionView.layer.masksToBounds = false
    mainTaskListCollectionView.backgroundColor = .clear
    mainTaskListCollectionView.anchor(
      top: overduedTasksButton.bottomAnchor,
      left: taskListContainerView.leftAnchor,
      bottom: taskListContainerView.safeAreaLayoutGuide.bottomAnchor,
      right: taskListContainerView.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )

    dragonBackgroundView.anchor(
      top: overduedTasksButton.bottomAnchor,
      left: taskListContainerView.leftAnchor,
      bottom: taskListContainerView.safeAreaLayoutGuide.bottomAnchor,
      right: taskListContainerView.rightAnchor
    )

    dragonImageView.anchorCenterXToSuperview()
    dragonImageView.anchorCenterYToSuperview(constant: -20)
    dragonImageView.anchor(heightConstant: Sizes.ImageViews.DragonImageView.height)
  }
  
  private func configureCalendarUIFirstStep() {
    calendarNavigateButtonsStackView = UIStackView(arrangedSubviews: [monthLabelSpacerLeftView, monthLabel, changeCalendarModeButton])
    calendarNavigateButtonsStackView.axis = .horizontal
    calendarNavigateButtonsStackView.distribution = .fillProportionally
    calendarNavigateButtonsStackView.spacing = 0
    
    calendarDayNamesStackView = UIStackView(arrangedSubviews: [mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel, sundayLabel])
    calendarDayNamesStackView.axis = .horizontal
    calendarDayNamesStackView.distribution = .fillEqually
    calendarDayNamesStackView.spacing = 0
    calendarDayNamesStackView.backgroundColor = Style.Views.Calendar.Background
    
    calendarTaskListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createCalendarTaskListCompositionalLayout())
    
    calendarContainerView.addSubviews([
      mainSceneRightView,
      taskListButton,
      shopButton,
      calendarNavigateButtonsStackView,
      calendarDayNamesStackView,
      calendarView,
      scrollToPreviousPeriodButton,
      scrollToNextPeriodButton,
      dayTasksLabel,
      addTaskButton,
      calendarTaskListCollectionView
    ])
    
    mainSceneRightView.presentScene(mainSceneRight)
    mainSceneRightView.anchor(
      top: calendarContainerView.topAnchor,
      left: calendarContainerView.leftAnchor,
      widthConstant: mainSceneRightView.frame.width,
      heightConstant: mainSceneRightView.frame.height
    )
    
    taskListButton.anchor(
      top: mainSceneRightView.bottomAnchor,
      left: calendarContainerView.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 30,
      heightConstant: 30
    )
    
    monthLabelSpacerLeftView.anchor(
      widthConstant: 10
    )
    
    monthLabel.anchor(
      heightConstant: 30
    )
    
    changeCalendarModeButton.anchor(
      widthConstant: 30,
      heightConstant: 30
    )

    calendarNavigateButtonsStackView.anchorCenterXToSuperview()
    calendarNavigateButtonsStackView.anchor(
      top: mainSceneRightView.bottomAnchor,
      topConstant: 16,
      widthConstant: 7 * Sizes.Cells.CalendarCell.size,
      heightConstant: Sizes.Cells.CalendarCell.size
    )
    
    shopButton.anchor(
      top: mainSceneRightView.bottomAnchor,
      right: calendarContainerView.rightAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: 30,
      heightConstant: 30
    )
    
    calendarDayNamesStackView.anchorCenterXToSuperview()
    calendarDayNamesStackView.anchor(
      top: calendarNavigateButtonsStackView.bottomAnchor,
      widthConstant: 7 * Sizes.Cells.CalendarCell.size,
      heightConstant: Sizes.Cells.CalendarCell.header
    )

    calendarView.calendarDataSource = self
    calendarView.calendarDelegate = self
    configureCalendarUISecondStep(isShortMode: self.isCalendarInShortMode)
  }
  
  private func configureCalendarUISecondStep(isShortMode: Bool) {
    calendarView.removeAllConstraints()
    calendarView.anchorCenterXToSuperview()
    calendarView.anchor(
      top: calendarDayNamesStackView.bottomAnchor,
      widthConstant: 7 * Sizes.Cells.CalendarCell.size,
      heightConstant: (isShortMode ? 1 : 6 ) * Sizes.Cells.CalendarCell.size
    )
    
    scrollToPreviousPeriodButton.anchor(
      top: calendarDayNamesStackView.topAnchor,
      left: calendarContainerView.leftAnchor,
      bottom: calendarView.bottomAnchor,
      right: calendarView.leftAnchor,
      leftConstant: 16,
      rightConstant: 16
    )
    
    scrollToNextPeriodButton.anchor(
      top: calendarDayNamesStackView.topAnchor,
      left: calendarView.rightAnchor,
      bottom: calendarView.bottomAnchor,
      right: calendarContainerView.rightAnchor,
      leftConstant: 16,
      rightConstant: 16
    )
    
    dayTasksLabel.anchor(
      top: calendarView.bottomAnchor,
      left: calendarContainerView.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    addTaskButton.centerYAnchor.constraint(equalTo: dayTasksLabel.centerYAnchor).isActive = true
    addTaskButton.anchor(
      right: calendarContainerView.rightAnchor,
      rightConstant: 16
    )
    
    calendarTaskListCollectionView.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.reuseID)
    calendarTaskListCollectionView.register(
      TaskReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TaskReusableView.reuseID)
    calendarTaskListCollectionView.alwaysBounceVertical = true
    calendarTaskListCollectionView.layer.masksToBounds = false
    calendarTaskListCollectionView.backgroundColor = .clear
    calendarTaskListCollectionView.anchor(
      top: dayTasksLabel.bottomAnchor,
      left: calendarContainerView.leftAnchor,
      bottom: calendarContainerView.bottomAnchor,
      right: calendarContainerView.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
  }

  // MARK: - Main Task List Collection View
  private func createMainTaskListCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.mainTaskListSection()
    }
  }
  
  private func mainTaskListSection() -> NSCollectionLayoutSection {
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
  
  private func configureMainTaskListDataSource() {
    mainTaskListCollectionView.dataSource = nil
    mainTaskListDataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSection>(
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
  
  private func createCalendarTaskListCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.calendarTaskListSection()
    }
  }
  
  private func calendarTaskListSection() -> NSCollectionLayoutSection {
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
  
  // MARK: - Calendar Task List Collection View
  private func configureCalendarTaskListDataSource() {
    calendarTaskListCollectionView.dataSource = nil
    calendarTaskListDataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSection>(
      configureCell: { dataSource, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: TaskCell.reuseID,
          for: indexPath
        ) as? TaskCell else { return UICollectionViewCell() }
        cell.configure(mode: dataSource[indexPath.section].mode, task: item.task, kindOfTask: item.kindOfTask)
        cell.delegate = self
        return cell
      }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
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
  func bindMainSceneModel() {
//    let input = NestSceneModel.Input()
//    let outputs = nestSceneModel.transform(input: input)
//
//    [
//      outputs.backgroundImage.drive(nestSceneBackgroundImageBinder),
//      outputs.dataSource.drive(nestSceneDataSourceBinder)
//    ]
//      .forEach { $0.disposed(by: disposeBag) }
  }
  
  func bindBranchSceneModel() {
//    let input = BranchSceneModel.Input()
//    let outputs = branchSceneModel.transform(input: input)
//
//    [
//      outputs.backgroundImage.drive(branchSceneBackgroundImageBinder),
//      outputs.dataSource.drive(branchSceneDataSourceBinder)
//    ]
//      .forEach({ $0.disposed(by: disposeBag) })
  }

  func bindViewModel() {
    let input = MainTaskListViewModel.Input(
      overduedButtonClickTrigger: overduedTasksButton.rx.tap.asDriver(),
      ideaButtonClickTrigger: ideaTasksButton.rx.tap.asDriver(),
      calendarButtonClickTrigger: calendarButton.rx.tap.asDriver(),
      taskListButtonClickTrigger: taskListButton.rx.tap.asDriver(),
      shopButtoClickTrigger: shopButton.rx.tap.asDriver()
    )

    let outputs = mainViewModel.transform(input: input)

    [
      outputs.openOverduedTasklist.drive(),
      outputs.openIdeaTaskList.drive(),
      outputs.openCalendar.drive(openCalendarViewBinder),
      outputs.openTaskList.drive(openTaskListViewBinder),
      outputs.openShop.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }

  func bindMainTaskListViewModel() {
    let input = TaskListViewModel.Input(
      // BACK
      backButtonClickTrigger: Driver<Void>.of(),
      // ADD
      addTaskButtonClickTrigger: Driver<Void>.of(),
      // REMOVE ALL
      removeAllButtonClickTrigger: Driver<Void>.of(),
      // SELECT TASK
      selection: mainTaskListCollectionView.rx.itemSelected.asDriver(),
      // ALERT
      alertDeleteButtonClick: alertDeleteButton.rx.tap.asDriver(),
      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver()
    )

    let outputs = taskListViewModel.transform(input: input)

    [
      // DATASOURCE
      outputs.dataSource.drive(mainTaskListCollectionView.rx.items(dataSource: mainTaskListDataSource)),
      outputs.dataSource.drive(dataSourceBinder),
      outputs.reloadItems.drive(reloadItemsBinder),
      outputs.hideCellWhenAlertClosed.drive(hideCellBinder),
      // TASK
      outputs.openTask.drive(),
      outputs.changeTaskStatus.drive(changeBinder),
      outputs.removeTask.drive(),
      // ALERT
      outputs.alertText.drive(alertLabel.rx.text),
      outputs.showAlert.drive(showAlertBinder),
      outputs.hideAlert.drive(hideAlertBinder)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  func bindCalendarViewModel() {
    let input = CalendarViewModel.Input(
      monthLabelClickTrigger: monthLabel.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      changeCalendarModeButtonClickTrigger: changeCalendarModeButton.rx.tap
        .filter { _ in !self.isCalendarAnimationRunning }.mapToVoid().asDriverOnErrorJustComplete(),
      scrollToPreviousPeriodButtonClickTrigger: scrollToPreviousPeriodButton.rx.tap.asDriver(),
      scrollToNextPeriodButtonClickTrigger: scrollToNextPeriodButton.rx.tap.asDriver(),
      addTaskButtonClickTrigger: addTaskButton.rx.tap.asDriver(),
      calendarTaskListSelection: calendarTaskListCollectionView.rx.itemSelected.asDriver()
    )

    let outputs = calendarViewModel.transform(input: input)

    [
      outputs.isCalendarInShortMode.drive(isCalendarInShortModeBinder),
      outputs.calendarAddMonths.drive(),
      outputs.calendarDataSource.drive(calendarDataSourceBinder),
      outputs.scrollToDate.drive(scrollToDateBinder),
      outputs.monthButtonTitle.drive(monthLabel.rx.text),
      outputs.addTask.drive(),
      outputs.calendarTaskListLabel.drive(dayTasksLabel.rx.text),
      outputs.calendarTaskListDataSource.drive(calendarTaskListCollectionView.rx.items(dataSource: calendarTaskListDataSource)),
      outputs.openCalendarTask.drive(),
      outputs.changeCalendarTaskStatus.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }

  // MARK: - Task List Binders
  var changeBinder: Binder<Result<Void, Error>> {
    return Binder(self, binding: { vc, _ in
      vc.mainTaskListCollectionView.reloadData()
    })
  }
  
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertContainerView.isHidden = true
    })
  }

  var hideCellBinder: Binder<IndexPath> {
    return Binder(self, binding: { vc, indexPath in
      if let cell = vc.mainTaskListCollectionView.cellForItem(at: indexPath) as? TaskCell {
        cell.hideSwipe(animated: true)
      }
    })
  }

  var reloadItemsBinder: Binder<[IndexPath]> {
    return Binder(self, binding: { vc, indexPaths in
      if self.taskListViewModel.editingIndexPath == nil {
        vc.mainTaskListCollectionView.reloadData()
      } else {
        UIView.performWithoutAnimation {
         vc.mainTaskListCollectionView.reloadItems(at: indexPaths)
        }
      }
    })
  }

  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      vc.alertContainerView.isHidden = false
    })
  }

//  // MARK: - Scene Binders
//  var nestSceneBackgroundImageBinder: Binder<UIImage?> {
//    return Binder(self, binding: { vc, image in
//      if let image = image, let scene = vc.taskListScene {
//        scene.setup(withBackground: image)
//      }
//    })
//  }
//
//  var nestSceneDataSourceBinder: Binder<[EggActionType]> {
//    return Binder(self, binding: { vc, actions in
//      if let scene = vc.taskListScene {
//        scene.setup(with: actions)
//        if vc.isVisible {
//          scene.reloadData()
//        }
//      }
//    })
//  }
//
//  var branchSceneBackgroundImageBinder: Binder<UIImage?> {
//    return Binder(self, binding: { vc, image in
//      if let image = image, let scene = vc.taskListScene {
//        scene.setup(withBackground: image)
//      }
//    })
//  }
//
//  var branchSceneDataSourceBinder: Binder<[BirdActionType]> {
//    return Binder(self, binding: { vc, actions in
//      if let scene = vc.calendarScene {
//        scene.setup(with: actions)
//        if vc.isVisible {
//          scene.reloadData()
//        }
//      }
//    })
//  }

  var dataSourceBinder: Binder<[TaskListSection]> {
    return Binder(self, binding: { vc, dataSource in
      if dataSource.map { $0.items.count }.sum() == 0 {
        vc.dragonImageView.isHidden = false
      } else {
        vc.dragonImageView.isHidden = true
      }
    })
  }
  
  var openCalendarViewBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      UIView.animate(withDuration: 0.5) {
        self.taskListContainerView.frame = CGRect(
          x: -self.view.frame.width,
          y: 0,
          width: self.view.frame.width,
          height: self.view.bounds.height - (self.tabBarController?.tabBar.bounds.height ?? 0) )

        self.calendarContainerView.frame = CGRect(
          x: 0,
          y: 0,
          width: self.view.frame.width,
          height: self.view.bounds.height - (self.tabBarController?.tabBar.bounds.height ?? 0))
      }
    })
  }
  
  // MARK: - Calendar Binders
  var openTaskListViewBinder: Binder<Void> {
    return Binder(self, binding: { vc, _ in
      UIView.animate(withDuration: 0.5) {
        vc.taskListContainerView.frame = CGRect(
          x: 0,
          y: 0,
          width: vc.view.frame.width,
          height: vc.view.bounds.height - (vc.tabBarController?.tabBar.bounds.height ?? 0))

        vc.calendarContainerView.frame = CGRect(
          x: vc.view.frame.width,
          y: 0,
          width: vc.view.frame.width,
          height: vc.view.bounds.height - (vc.tabBarController?.tabBar.bounds.height ?? 0))
      }
    })
  }
  
  var isCalendarInShortModeBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isCalendarInShortMode in
      UIView.animate(withDuration: 0.5) {
        self.isCalendarAnimationRunning = true
        vc.isCalendarInShortMode = isCalendarInShortMode
        vc.configureCalendarUISecondStep(isShortMode: isCalendarInShortMode)
        vc.changeCalendarModeButton.setImage(
          isCalendarInShortMode ? Icon.arrowBottom.image.template : Icon.arrowTop.image.template,
          for: .normal)
      } completion: { _ in
        self.isCalendarAnimationRunning = false
        vc.calendarView.reloadData()
        vc.calendarView.scrollToDate(self.selectedDate ?? Date(), animateScroll: false)
      }
    })
  }
  
  
  var calendarDataSourceBinder: Binder<[CalendarSection]> {
    return Binder(self, binding: { vc, dataSource in
      vc.calendarDataSource = dataSource
      vc.calendarView.reloadData()
      vc.calendarView.scrollToDate(self.displayDate, animateScroll: false)
    })
  }
  
  
  var scrollToDateBinder: Binder<Date> {
    return Binder(self, binding: { vc, date in
      vc.calendarView.scrollToDate(date)
    })
  }
}

extension MainTaskListViewController: SwipeCollectionViewCellDelegate {
  func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {
    if collectionView == self.mainTaskListCollectionView {
      taskListViewModel.editingIndexPath = indexPath
    }
  }

  func collectionView(_ collectionView: UICollectionView, didEndEditingItemAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
    if collectionView == self.mainTaskListCollectionView {
      taskListViewModel.editingIndexPath = nil
    }
  }

  func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      if  collectionView == self.mainTaskListCollectionView {
        self.taskListViewModel.changeStatus(indexPath: indexPath, status: .deleted, completed: nil)
      } else {
        self.calendarViewModel.changeStatusTrigger.accept(ChangeStatus(completed: nil, indexPath: indexPath, status: .deleted))
      }
    }

    let ideaBoxAction = SwipeAction(style: .default, title: nil) { [weak self] action, indexPath in
      guard let self = self else { return }
      action.fulfill(with: .reset)
      if  collectionView == self.mainTaskListCollectionView {
        self.taskListViewModel.changeStatus(indexPath: indexPath, status: .idea, completed: nil)
      } else {
        self.calendarViewModel.changeStatusTrigger.accept(ChangeStatus(completed: nil, indexPath: indexPath, status: .idea))
      }
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

// MARK: - JTAppleCalendarViewDataSource
extension MainTaskListViewController: JTACMonthViewDataSource {
  func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
    let startDate = calendarDataSource.first?.startDate ?? Date().startOfMonth
    let endDate = calendarDataSource.last?.endDate ?? Date().endOfMonth
    return ConfigurationParameters(
      startDate: startDate,
      endDate: endDate,
      numberOfRows: self.isCalendarInShortMode ? 1 : 6
    )
  }
}

extension MainTaskListViewController: JTACMonthViewDelegate {

  func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarCell.reuseID, for: indexPath) as! CalendarCell
    guard let section = calendarDataSource[safe: indexPath.section],
          let item = section.items[safe: indexPath.item] else {
      cell.configure(
        cellState: cellState,
        selectedDate: self.selectedDate,
        completedTasksCount: 0,
        plannedTasksCount: 0)
      return cell
    }
    
    cell.configure(
      cellState: cellState,
      selectedDate: self.selectedDate,
      completedTasksCount: item.completedTasksCount,
      plannedTasksCount: item.plannedTasksCount)
    return cell
  }

  func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
    let cell = cell as! CalendarCell
    
    if let section = calendarDataSource[safe: indexPath.section],
      let item = section.items[safe: indexPath.item] {
      cell.configure(
        cellState: cellState,
        selectedDate: self.selectedDate,
        completedTasksCount: item.completedTasksCount,
        plannedTasksCount: item.plannedTasksCount)
      return
    }
    
    cell.configure(
      cellState: cellState,
      selectedDate: self.selectedDate,
      completedTasksCount: 0,
      plannedTasksCount: 0)
  }
  
  func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
    if let cell = cell as? CalendarCell {
      selectedDate = date
      calendarViewModel.selectedDate.accept(date)
      cell.backgroundColor = Style.Cells.Calendar.Selected
      
      guard let section = calendarDataSource[safe: indexPath.section],
            let item = section.items[safe: indexPath.item] else {
        cell.dateLabel.textColor = .white
        return
      }
      cell.dateLabel.textColor = item.completedTasksCount == 0 ? .white : Style.App.text
    }
  }
  
  func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
    if let cell = cell as? CalendarCell {
      cell.backgroundColor = .clear
      cell.dateLabel.textColor = Style.App.text
    }
  }
  
  func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    if let firstItemOfMonth = visibleDates.monthDates.first {
      displayDate = firstItemOfMonth.date
      calendarViewModel.displayDate.accept(firstItemOfMonth.date)
    }
  }
}
