//
//  MainCalendarViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 27.01.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SpriteKit
import SwipeCellKit
import JTAppleCalendar

class MainCalendarViewController: UIViewController {
  public var viewModel: MainCalendarViewModel!
  public var sceneModel: MainCalendarSceneModel!
  
  private let disposeBag = DisposeBag()
  
  private var isCalendarAnimationRunning: Bool = false
  private var calendarMode: CalendarMode = .long
  private var displayDate: Date = Date()
  
  private var calendarData: Dictionary<Date, CalendarItem> = [
    Date().startOfDay: CalendarItem(date: Date(), isSelected: false, completedTasksCount: 2, plannedTasksCount: 0)
  ]
  
  // MARK: - UI Elements - Scene
  private let scene: MainCalendarScene? = {
    let scene = SKScene(fileNamed: "MainCalendarScene") as? MainCalendarScene
    scene?.scaleMode = .aspectFill
    return scene
  }()
  
  // MARK: - UI Elements - Calendar
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
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSection>!
  
  private let sceneView: SKView = {
    let view = SKView(
      frame: CGRect(
        center: .zero,
        size: CGSize(
          width: Style.Scene.width,
          height: Style.Scene.height)))
    return view
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
  }
  
  // MARK: - Configure UI
  func configureUI() {
    calendarNavigateButtonsStackView = UIStackView(arrangedSubviews: [monthLabelSpacerLeftView, monthLabel, changeCalendarModeButton])
    calendarNavigateButtonsStackView.axis = .horizontal
    calendarNavigateButtonsStackView.distribution = .fillProportionally
    calendarNavigateButtonsStackView.spacing = 0
    
    calendarDayNamesStackView = UIStackView(arrangedSubviews: [mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel, sundayLabel])
    calendarDayNamesStackView.axis = .horizontal
    calendarDayNamesStackView.distribution = .fillEqually
    calendarDayNamesStackView.spacing = 0
    calendarDayNamesStackView.backgroundColor = Style.Views.Calendar.Background
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createCompositionalLayout())
    
    view.backgroundColor = Style.App.background
    
    view.addSubviews([
      sceneView,
      taskListButton,
      shopButton,
      calendarNavigateButtonsStackView,
      calendarDayNamesStackView,
      calendarView,
      scrollToPreviousPeriodButton,
      scrollToNextPeriodButton,
      dayTasksLabel,
      addTaskButton,
      collectionView
    ])
    
    sceneView.presentScene(scene)
    sceneView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      widthConstant: sceneView.frame.width,
      heightConstant: sceneView.frame.height
    )
    
    taskListButton.anchor(
      top: sceneView.bottomAnchor,
      left: view.leftAnchor,
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
      top: sceneView.bottomAnchor,
      topConstant: 16,
      widthConstant: 7 * Sizes.Cells.CalendarCell.size,
      heightConstant: Sizes.Cells.CalendarCell.size
    )
    
    shopButton.anchor(
      top: sceneView.bottomAnchor,
      right: view.rightAnchor,
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
    configureCalendarUISecondStep(calendarMode: .long)
  }
  
  func configureCalendarUISecondStep(calendarMode: CalendarMode) {
    let nomberOfRows: Int
    let changeCalendarModeButtonImage: UIImage
    
    switch calendarMode{
    case .short:
      nomberOfRows = 1
      changeCalendarModeButtonImage = Icon.arrowBottom.image.template
    case .long:
      nomberOfRows = 6
      changeCalendarModeButtonImage = Icon.arrowTop.image.template
    }
    
    calendarView.removeAllConstraints()
    calendarView.anchorCenterXToSuperview()
    calendarView.anchor(
      top: calendarDayNamesStackView.bottomAnchor,
      widthConstant: 7 * Sizes.Cells.CalendarCell.size,
      heightConstant: nomberOfRows.cgFloat * Sizes.Cells.CalendarCell.size
    )
    
    changeCalendarModeButton.setImage(changeCalendarModeButtonImage, for: .normal)

    scrollToPreviousPeriodButton.anchor(
      top: calendarDayNamesStackView.topAnchor,
      left: view.leftAnchor,
      bottom: calendarView.bottomAnchor,
      right: calendarView.leftAnchor,
      leftConstant: 16,
      rightConstant: 16
    )
    
    scrollToNextPeriodButton.anchor(
      top: calendarDayNamesStackView.topAnchor,
      left: calendarView.rightAnchor,
      bottom: calendarView.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      rightConstant: 16
    )
    
    dayTasksLabel.anchor(
      top: calendarView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    addTaskButton.centerYAnchor.constraint(equalTo: dayTasksLabel.centerYAnchor).isActive = true
    addTaskButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16
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
      top: dayTasksLabel.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16
    )
  }
  
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
  func bindSceneModel() {
    let input = MainCalendarSceneModel.Input()
    let outputs = sceneModel.transform(input: input)

    [
      outputs.backgroundImage.drive(backgroundImageBinder),
      outputs.dataSource.drive(sceneDataBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  func bindViewModel() {
    let input = MainCalendarViewModel.Input(
      taskListButtonClickTrigger: taskListButton.rx.tap.asDriver(),
      monthLabelClickTrigger: monthLabel.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      changeCalendarModeButtonClickTrigger: changeCalendarModeButton.rx.tap
        .filter { _ in !self.isCalendarAnimationRunning }.mapToVoid().asDriverOnErrorJustComplete(),
      shopButtonClickTrigger: shopButton.rx.tap.asDriver(),
      scrollToPreviousPeriodButtonClickTrigger: scrollToPreviousPeriodButton.rx.tap.asDriver(),
      scrollToNextPeriodButtonClickTrigger: scrollToNextPeriodButton.rx.tap.asDriver(),
      addTaskButtonClickTrigger: addTaskButton.rx.tap.asDriver(),
      calendarTaskListSelection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.openMainTaskList.drive(),
      outputs.calendarMode.drive(calendarModeBinder),
      outputs.openShop.drive(),
      outputs.calendarAddMonths.drive(),
      outputs.calendarDataSource.drive(calendarDataSourceBinder),
      outputs.scrollToDate.drive(scrollToDateBinder),
      outputs.monthButtonTitle.drive(monthLabel.rx.text),
      outputs.addTask.drive(),
      outputs.calendarTaskListLabel.drive(dayTasksLabel.rx.text),
      outputs.calendarTaskListDataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.openCalendarTask.drive(),
      outputs.changeTaskStatusToIdea.drive(),
      outputs.changeTaskStatusToDeleted.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  // MARK: - Scene Binders
  var backgroundImageBinder: Binder<UIImage?> {
    return Binder(self, binding: { vc, image in
      if let image = image, let scene = vc.scene {
        scene.setup(with: image)
      }
    })
  }

  var sceneDataBinder: Binder<[BirdActionType]> {
    return Binder(self, binding: { vc, actions in
      if let scene = vc.scene {
        scene.setup(with: actions)
        if vc.isVisible {
          scene.reloadData()
        }
      }
    })
  }
  
  // MARK: - Calendar Binders
  var calendarModeBinder: Binder<CalendarMode> {
    return Binder(self, binding: { vc, calendarMode in
      UIView.animate(withDuration: 0.5) {
        vc.isCalendarAnimationRunning = true
        vc.calendarMode = calendarMode
        vc.configureCalendarUISecondStep(calendarMode: calendarMode)
      } completion: { _ in
        vc.isCalendarAnimationRunning = false
        vc.calendarView.reloadData()
        vc.calendarView.scrollToDate(vc.displayDate, animateScroll: false)
      }
    })
  }

  var calendarDataSourceBinder: Binder<Dictionary<Date, CalendarItem>> {
    return Binder(self, binding: { vc, dataSource in
      vc.calendarData = dataSource
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

// MARK: - JTAppleCalendarViewDataSource
extension MainCalendarViewController: JTACMonthViewDataSource {
  func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
    let startDate = calendarData.keys.sorted { $0 < $1 }.first ?? Date().startOfMonth
    let endDate = calendarData.keys.sorted { $0 < $1 }.last ?? Date().endOfMonth
    let nomberOfRows: Int
    
    switch self.calendarMode {
    case .short:
      nomberOfRows = 1
    case .long:
      nomberOfRows = 6
    }
    
    return ConfigurationParameters(
      startDate: startDate,
      endDate: endDate,
      numberOfRows: nomberOfRows,
      calendar: Calendar.current,
      firstDayOfWeek: .monday
    )
  }
}

// MARK: - JTACMonthViewDelegate
extension MainCalendarViewController: JTACMonthViewDelegate {
  func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarCell.reuseID, for: indexPath) as! CalendarCell
    
    if let item = calendarData[date] {
      cell.configure(
        cellState: cellState,
        isSelected: item.isSelected,
        completedTasksCount: item.completedTasksCount,
        plannedTasksCount: item.plannedTasksCount
      )
    } else {
      cell.configure(
        cellState: cellState,
        isSelected: false,
        completedTasksCount: 0,
        plannedTasksCount: 0
      )
    }
    return cell
  }

  func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
    let cell = cell as! CalendarCell
    
    if let item = calendarData[date] {
      cell.configure(
        cellState: cellState,
        isSelected: item.isSelected,
        completedTasksCount: item.completedTasksCount,
        plannedTasksCount: item.plannedTasksCount
      )
    } else {
      cell.configure(
        cellState: cellState,
        isSelected: false,
        completedTasksCount: 0,
        plannedTasksCount: 0
      )
    }
  }
  
  func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
    if cellState.dateBelongsTo == .thisMonth {
      viewModel.selectedDate.accept(date)
    }
  }
  
  func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
    if let cell = cell as? CalendarCell, let item = calendarData[date] {
      cell.configure(
        cellState: cellState,
        isSelected: item.isSelected,
        completedTasksCount: item.completedTasksCount,
        plannedTasksCount: item.plannedTasksCount)
    }
  }
  
  func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    if let firstItemOfMonth = visibleDates.monthDates.first {
      displayDate = firstItemOfMonth.date
      viewModel.displayDate.accept(firstItemOfMonth.date)
    }
  }
}

// MARK: - SwipeCollectionViewCellDelegate
extension MainCalendarViewController: SwipeCollectionViewCellDelegate {
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
