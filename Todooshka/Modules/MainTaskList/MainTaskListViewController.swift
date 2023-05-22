//
//  MainTaskListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 17.05.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwipeCellKit
import RxGesture
import Lottie
import JTAppleCalendar

class MainTaskListViewController: UIViewController {
  public var viewModel: MainTaskListViewModel!
  
  private let disposeBag = DisposeBag()
  
  private var calendarSections: [CalendarSection] = []

  // MARK: - UI Elements
  private let coolImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "top")
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .lightGray.withAlphaComponent(0.2)
    imageView.clipsToBounds = true
    return imageView
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
  
  private let calendarButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    button.setImage(Icon.calendar.image.template, for: .normal)
    button.tintColor = Style.TabBar.Unselected
    button.cornerRadius = 20
    return button
  }()
  
  private let calendarContainerView: UIView = {
    let view = UIView()
    view.cornerRadius = 8
    view.backgroundColor = Style.Views.Calendar.Background
    return view
  }()
  
  private let calendarMonthLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = Style.Buttons.OverduedOrIdea.Background
    label.tintColor = Style.App.text
    label.text = "Апрель"
    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    label.textAlignment = .center
    return label
  }()
  
  private var calendarDayNamesStackView: UIStackView!
  
  public let mondayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
    label.text = "ПН"
    return label
  }()
  
  public let tuesdayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
    label.text = "ВТ"
    return label
  }()
  
  public let wednesdayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
    label.text = "СР"
    return label
  }()
  
  public let thursdayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
    label.text = "ЧТ"
    return label
  }()
  
  public let fridayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
    label.text = "ПТ"
    return label
  }()
  
  public let saturdayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
    label.text = "СБ"
    return label
  }()
  
  public let sundayLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
    label.text = "ВС"
    return label
  }()
  
  private let calendarView: JTACMonthView = {
    let calendarView = JTACMonthView()
    calendarView.layer.cornerRadius = 8
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

  // Alert
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
    bindViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    collectionView.reloadData()
    navigationController?.tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - Configure UI
  private func configureUI() {
    calendarDayNamesStackView = UIStackView(arrangedSubviews: [mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel, sundayLabel])
    calendarDayNamesStackView.axis = .horizontal
    calendarDayNamesStackView.distribution = .fillEqually
    calendarDayNamesStackView.spacing = 0
    calendarDayNamesStackView.backgroundColor = Style.Views.Calendar.Background
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    view.backgroundColor = Style.App.background
    
    view.addSubviews([
      coolImageView,
      dragonContainerView,
      overduedTasksButton,
      ideaTasksButton,
      collectionView,
      calendarButton,
      calendarContainerView,
      alertContainerView
    ])

    alertContainerView.addSubviews([
      alertView
    ])
    
    dragonContainerView.addSubviews([
      dragonImageView
    ])
    
    alertView.addSubviews([
      alertLabel,
      alertDeleteButton,
      alertCancelButton
    ])
    
    coolImageView.anchor(
      top: view.topAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      heightConstant: 200
    )
    
    overduedTasksButton.anchor(
      top: coolImageView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: (UIScreen.main.bounds.width - 2 * 16) / 2 - 8,
      heightConstant: 30
    )

    ideaTasksButton.anchor(
      top: coolImageView.bottomAnchor,
      left: overduedTasksButton.rightAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 8,
      rightConstant: 16,
      heightConstant: 30
    )

    collectionView.register(TaskListCell.self, forCellWithReuseIdentifier: TaskListCell.reuseID)
    collectionView.register(
      TaskListReusableView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TaskListReusableView.reuseID)
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
    
    calendarButton.anchor(
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      bottomConstant: 16,
      rightConstant: 16,
      widthConstant: calendarButton.cornerRadius * 2,
      heightConstant: calendarButton.cornerRadius * 2
    )
    
    calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
    calendarContainerView.transform = CGAffineTransform(translationX: 0, y: 300)
    
    calendarContainerView.addSubviews([
      calendarMonthLabel,
      calendarDayNamesStackView,
      calendarView
    ])
    
    calendarContainerView.cornerRadius = 15
    
    calendarContainerView.anchorCenterXToSuperview()
    calendarContainerView.anchor(
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      bottomConstant: 16,
      widthConstant: 7 * Sizes.Cells.CalendarCell.size,
      heightConstant: 5 * Sizes.Cells.CalendarCell.size + Sizes.Cells.CalendarCell.header + 40
    )
    
    calendarView.calendarDataSource = self
    calendarView.calendarDelegate = self
    
    calendarView.anchor(
      bottom: calendarContainerView.bottomAnchor,
      widthConstant: 7 * Sizes.Cells.CalendarCell.size,
      heightConstant: 5 * Sizes.Cells.CalendarCell.size
    )

    calendarDayNamesStackView.anchorCenterXToSuperview()
    calendarDayNamesStackView.anchor(
      bottom: calendarView.topAnchor,
      widthConstant: 7 * Sizes.Cells.CalendarCell.size,
      heightConstant: Sizes.Cells.CalendarCell.header
    )
    
    calendarMonthLabel.anchor(
      top: calendarContainerView.topAnchor,
      left: calendarContainerView.leftAnchor,
      bottom: calendarDayNamesStackView.topAnchor,
      right: calendarContainerView.rightAnchor
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCell.reuseID, for: indexPath) as! TaskListCell
        cell.configure(with: item)
        cell.delegate = self
        return cell
      },
      configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskListReusableView.reuseID, for: indexPath) as! TaskListReusableView
        header.configure(text: dataSource[indexPath.section].header)
        return header
      }
    )
  }
  
  // MARK: - Bind
  func bindViewModel() {
    let input = MainTaskListViewModel.Input(
      // overdued
      overduedButtonClickTrigger: overduedTasksButton.rx.tap.asDriver(),
      // idea
      ideaButtonClickTrigger: ideaTasksButton.rx.tap.asDriver(),
      // task list
      taskSelected: collectionView.rx.itemSelected.asDriver(),
      // calendar
      calendarMonthLabelClickTrigger: calendarMonthLabel.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
      calendarButtonClickTrigger: calendarButton.rx.tap.asDriver(),
      // alert
      alertDeleteButtonClick: alertDeleteButton.rx.tap.asDriver(),
      alertCancelButtonClick: alertCancelButton.rx.tap.asDriver()
    )

    let outputs = viewModel.transform(input: input)
    
    [
      // overdued
      outputs.overduredTaskListOpen.drive(),
      // idea
      outputs.ideaTaskListOpen.drive(),
      // task list
      outputs.taskListSections.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.taskListOpenTask.drive(),
      // calendar
      outputs.calendarMonthLabelText.drive(calendarMonthLabel.rx.text),
      outputs.calendarSections.drive(calendarSectionsBinder),
      outputs.calendarIsHidden.drive(calendarIsHiddenBinder),
      outputs.calendarButtonImage.drive(calendarButtonBinder),
      outputs.calendarScrollToDate.drive(calendarScrollToDateBinder),
      // alert
      outputs.deleteAlertIsHidden.drive(alertContainerView.rx.isHidden),
      // task
      outputs.saveTask.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }

  }
  
  var calendarSectionsBinder: Binder<[CalendarSection]> {
    return Binder(self, binding: { vc, calendarSections in
      vc.calendarSections = calendarSections
      vc.calendarView.reloadData()
      vc.calendarView.scrollToDate(vc.viewModel.calendarVisibleMonth.value, animateScroll: false)
    })
  }
  
  var calendarScrollToDateBinder: Binder<Date> {
    return Binder(self, binding: { vc, date in
      vc.calendarView.scrollToDate(date)
    })
  }
  
  var calendarButtonBinder: Binder<UIImage> {
    return Binder(self, binding: { vc, image in
      vc.calendarButton.setImage(image, for: .normal)
    })
  }
  
  var calendarIsHiddenBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isHidden in
      if isHidden {
        vc.hideCalendar()
      } else {
        vc.showCalendar()
      }
    })
  }
  
  func showCalendar() {
    UIView.animate(withDuration: 0.25) {
      self.calendarContainerView.transform = .identity
    }
  }
  
  func hideCalendar() {
    UIView.animate(withDuration: 0.25) {
      self.calendarContainerView.transform = CGAffineTransform(translationX: 0, y: 300)
    }
  }
}

// MARK: - SwipeCollectionViewCellDelegate
extension MainTaskListViewController: SwipeCollectionViewCellDelegate {
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
    let buttonStyle: SwipeButtonStyle = .circular

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

// MARK: - JTAppleCalendarViewDataSource
extension MainTaskListViewController: JTACMonthViewDataSource {
  func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
    let startDate = calendarSections.min { $0.month < $1.month }?.month.startOfMonth ?? Date().startOfMonth
    let endDate = calendarSections.max { $0.month < $1.month }?.month.endOfMonth ?? Date().endOfMonth
    
    return ConfigurationParameters(
      startDate: startDate,
      endDate: endDate,
      numberOfRows: 6,
      calendar: Calendar.current,
      firstDayOfWeek: .monday
    )
  }
}

// MARK: - JTACMonthViewDelegate
extension MainTaskListViewController: JTACMonthViewDelegate {
  func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarCell.reuseID, for: indexPath) as! CalendarCell

    if let item = calendarSections[safe: indexPath.section]?.items.first { $0.date == date } {
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
    
    if let item = calendarSections[safe: indexPath.section]?.items.first { $0.date == date } {
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
      viewModel.calendarSelectedDate.accept(date)
    }
  }
  
  func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
    if let cell = cell as? CalendarCell,
       let item = calendarSections[safe: indexPath.section]?.items.first { $0.date == date } {
      cell.configure(
        cellState: cellState,
        isSelected: item.isSelected,
        completedTasksCount: item.completedTasksCount,
        plannedTasksCount: item.plannedTasksCount)
    }
  }
  
  func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    if let firstItemOfMonth = visibleDates.monthDates.first {
      viewModel.calendarVisibleMonth.accept(firstItemOfMonth.date)
    }
  }
}
