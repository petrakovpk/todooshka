//
//  CalendarViewController.swift
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

enum ScrollToIndexPath {
  case initial
  case ready
  case scrolled
}

class CalendarViewController: UIViewController {

  // MARK: - Const
  private var needScrollToToday: Bool = true
  private let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "LLLL"
    return formatter
  }()

  // MARK: - Sprite Kit
  private let scene: BranchScene? = {
    let scene = SKScene(fileNamed: "BranchScene") as? BranchScene
    scene?.scaleMode = .aspectFill
    return scene
  }()

  private let sceneView: SKView = {
    let view = SKView(frame: CGRect(
      center: .zero,
      size: CGSize(
        width: Style.Scene.width,
        height: Style.Scene.height)))
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
    button.cornerRadius = min(Sizes.Buttons.CalendarShopButton.height / 2, 12.adjustByHeight)
    button.titleLabel?.font = UIFont.systemFont(ofSize: min(14.adjustByWidth, 14.adjustByHeight), weight: .medium)
    return button
  }()

  private let calendarHeaderView: UILabel = {
    let label = UILabel()
    label.text = "Ваши результаты"
    label.textAlignment = .center
    return label
  }()

  private let calendarBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = Style.Views.Calendar.Background
    view.cornerRadius = 11
    return view
  }()

  private let calendarDividerView: UIView = {
    let view = UIView()
    view.backgroundColor = Style.Views.CalendarDivider.Background
    return view
  }()

  private var calendarView = CalendarView(frame: .zero, collectionViewLayout: CalendarViewLayout())

  // MARK: - MVVM
  var viewModel: CalendarViewModel!
  var sceneModel: BranchSceneModel!

  // MARK: - Rx
  private let disposeBag = DisposeBag()

  // MARK: - Rx DataSources
  public var dataSource: [CalendarSection] = []

  fileprivate var needsDelayedScrolling: ScrollToIndexPath = .initial

  private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "MMMM"
    return formatter
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    configureScene()
    configureUI()
    bindViewModel()
    bindSceneModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    scene?.reloadData()
    sceneModel.willShow.accept(())
    navigationController?.tabBarController?.tabBar.isHidden = false
  }

  // MARK: - Configure UI
  func configureScene() {
    // adding
    view.addSubview(sceneView)

    // sceneView
    sceneView.presentScene(scene)
    sceneView.anchor(top: view.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor,     heightConstant: sceneView.frame.height)
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
    view.backgroundColor = Style.App.background

    // settingsButton
    settingsButton.configure(image: UIImage(named: "setting")?.template, blurEffect: false)
    settingsButton.anchor(
      top: sceneView.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: Sizes.Buttons.CalendarSettingsButton.width,
      heightConstant: Sizes.Buttons.CalendarSettingsButton.height
    )

    // shopButton
    shopButton.anchor(
      top: sceneView.bottomAnchor,
      right: settingsButton.leftAnchor,
      topConstant: 16,
      rightConstant: 16,
      widthConstant: (UIScreen.main.bounds.width - 32) / 2 - 56 - 8,
      heightConstant: Sizes.Buttons.CalendarShopButton.height
    )

    // pointsBackgroundView
    pointsBackgroundView.backgroundColor = .clear
    pointsBackgroundView.anchor(
      top: sceneView.bottomAnchor,
      left: view.leftAnchor,
      right: shopButton.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 40
    )

    // featherBackgroundView
    featherBackgroundView.borderColor = Palette.SingleColors.BrilliantRose
    featherBackgroundView.borderWidth = 0.5
    featherBackgroundView.layer.cornerRadius = 15
    featherBackgroundView.anchor(
      top: pointsBackgroundView.topAnchor,
      left: pointsBackgroundView.leftAnchor,
      bottom: pointsBackgroundView.bottomAnchor,
      widthConstant: (UIScreen.main.bounds.width - 32) / 2 / 2 - 8
    )

    // diamondBackroundView
    diamondBackroundView.borderColor = Palette.SingleColors.PictonBlue
    diamondBackroundView.borderWidth = 0.5
    diamondBackroundView.layer.cornerRadius = 15
    diamondBackroundView.anchor(
      top: pointsBackgroundView.topAnchor,
      bottom: pointsBackgroundView.bottomAnchor,
      right: pointsBackgroundView.rightAnchor,
      widthConstant: (UIScreen.main.bounds.width - 32) / 2 / 2 - 8
    )

    // feathersImageView
    feathersImageView.anchor(
      top: featherBackgroundView.topAnchor,
      bottom: featherBackgroundView.bottomAnchor,
      right: featherBackgroundView.rightAnchor,
      topConstant: 4,
      bottomConstant: 4,
      rightConstant: 8,
      widthConstant: 20,
      heightConstant: 40
    )

    // featherLabel
    featherLabel.textAlignment = .center
    featherLabel.anchor(
      top: featherBackgroundView.topAnchor,
      left: featherBackgroundView.leftAnchor,
      bottom: featherBackgroundView.bottomAnchor,
      right: feathersImageView.leftAnchor,
      topConstant: 4,
      leftConstant: 8,
      bottomConstant: 4,
      rightConstant: 8
    )

    // diamondsImageView
    diamondsImageView.anchor(
      top: diamondBackroundView.topAnchor,
      bottom: diamondBackroundView.bottomAnchor,
      right: diamondBackroundView.rightAnchor,
      topConstant: 4,
      bottomConstant: 4,
      rightConstant: 8,
      widthConstant: 20,
      heightConstant: 40
    )

    // diamondLabel
    diamondLabel.textAlignment = .center
    diamondLabel.anchor(
      top: diamondBackroundView.topAnchor,
      left: diamondBackroundView.leftAnchor,
      bottom: diamondBackroundView.bottomAnchor,
      right: diamondsImageView.leftAnchor,
      topConstant: 4,
      leftConstant: 8,
      bottomConstant: 4,
      rightConstant: 8
    )

    // calendarBackgroundView
    calendarBackgroundView.anchor(
      top: shopButton.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 30,
      leftConstant: 16,
      bottomConstant: 30,
      rightConstant: 16
    )

    // calendarHeaderView
    calendarHeaderView.anchor(
      top: calendarBackgroundView.topAnchor,
      left: calendarBackgroundView.leftAnchor,
      right: calendarBackgroundView.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: 30
    )

    // calendarDividerView
    calendarDividerView.anchor(
      top: calendarHeaderView.bottomAnchor,
      left: calendarBackgroundView.leftAnchor,
      right: calendarBackgroundView.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: 1
    )

    // calendarView
    calendarView.delegate = self
    calendarView.dataSource = self
    calendarView.calendarViewDelegate = self
    calendarView.anchor(
      top: calendarDividerView.bottomAnchor,
      left: calendarBackgroundView.leftAnchor,
      bottom: calendarBackgroundView.bottomAnchor,
      right: calendarBackgroundView.rightAnchor,
      topConstant: 8,
      leftConstant: 8,
      bottomConstant: 8,
      rightConstant: 8
    )
  }

  // MARK: - Bind View Model
  func bindViewModel() {

    let input = CalendarViewModel.Input(
      settingsButtonClickTrigger: settingsButton.rx.tap.asDriver(),
      shopButtonClickTrigger: shopButton.rx.tap.asDriver(),
      featherBackgroundViewClickTrigger: featherBackgroundView
        .rx
        .tapGesture()
        .when(.recognized)
        .map { _ in return () }
        .asDriver(onErrorJustReturn: ()),
      diamondBackgroundViewClickTrigger: diamondBackroundView
        .rx
        .tapGesture()
        .when(.recognized)
        .map { _ in return () }
        .asDriver(onErrorJustReturn: ()),
      selection: calendarView.rx.itemSelected.asDriver(),
      willDisplayCell: calendarView.rx.willDisplayCell.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.dataSource.drive(dataSourceBinder),
      outputs.settingsButtonClickHandler.drive(),
      outputs.shopButtonClickHandler.drive(),
      outputs.openTaskList.drive(),
      outputs.saveSelectedDate.drive(),
      outputs.featherScoreLabel.drive(featherLabel.rx.text),
      outputs.diamondScoreLabel.drive(diamondLabel.rx.text),
      outputs.featherBackgroundViewClickHandler.drive(),
      outputs.diamondBackgroundViewClickHandler.drive(),
      outputs.willDisplayCell.drive(),
      outputs.scrollToCurrentMonth.drive(scrollToCurrentMonthBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })

  }

  func bindSceneModel() {
    let input = BranchSceneModel.Input()
    let outputs = sceneModel.transform(input: input)

    [
      outputs.background.drive(sceneBackgroundBinder),
      outputs.dataSource.drive(sceneDataSourceBinder)
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }

  // MARK: - Binder
  var sceneBackgroundBinder: Binder<UIImage?> {
    return Binder(self, binding: { (vc, image) in
      if let image = image, let scene = vc.scene {
        scene.setup(with: image)
      }
    })
  }

  var sceneDataSourceBinder: Binder<[BirdActionType]> {
    return Binder(self, binding: { (vc, actions) in
      if let scene = vc.scene {
        scene.setup(with: actions)
        if vc.isVisible {
          scene.reloadData()
        }
      }
    })
  }

  var scrollToCurrentMonthBinder: Binder<(trigger: Bool, withAnimation: Bool)> {
    return Binder(self, binding: { vc, scrollEvent in

      if scrollEvent.trigger {
        // иначе не получим лейаут
        vc.calendarView.layoutIfNeeded()

        // получаем секцию куда будем скролить
        guard
          let sectionIndex = self.dataSource.firstIndex(where: { $0.startOfPeriod.month == Date().month }),
          let layoutAttributesForSupplementaryElement = vc.calendarView.layoutAttributesForSupplementaryElement(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: sectionIndex)
          )
        else { return }

        // Скроллим
        vc.calendarView.collectionViewLayout.invalidateLayout()
        vc.calendarView.collectionViewLayout.prepare()
        vc.calendarView.setContentOffset(CGPoint(x: 0, y: layoutAttributesForSupplementaryElement.frame.origin.y), animated: scrollEvent.withAnimation)
      }

    })
  }

  var dataSourceBinder: Binder<[CalendarSection]> {
    return Binder(self, binding: { vc, newDataSource in
      let oldDataSource = self.dataSource
      self.dataSource = newDataSource

      // Добавляем предыдущий месяц - если в новом dataSource первый месяц меньше, чем в старом dataSource
      if let oldFirstSection = oldDataSource.first,
         let newFirstSection = newDataSource.first,
         case .month(let oldFirstMonth) = oldFirstSection.type,
         case .month(let newFirstMonth) = newFirstSection.type,
         oldFirstMonth > newFirstMonth {

        // получаем лейауты
        guard
          let firstSectionHeaderLayout = vc.calendarView.layoutAttributesForSupplementaryElement(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
          ),
          let firstItemFirstSectionLayout = vc.calendarView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        else { return }

        // получаем количество строк в первой секции
        let firstSectionRowCount = ceilf(newFirstSection.items.count.float / 7).cgFloat

        UIView.performWithoutAnimation {
          vc.calendarView.insertSections(IndexSet(integer: 0))
          vc.calendarView.contentOffset.y = vc.calendarView.contentOffset.y
          + firstSectionHeaderLayout.bounds.height
          + firstSectionRowCount * (firstItemFirstSectionLayout.bounds.height + vc.calendarView.layoutMargins.top)
          + Sizes.Views.Calendar.sectionInset.bottom
        }
      }

      if let oldLastSection = oldDataSource.last,
         let newLastSection = newDataSource.last,
         case .month(let oldLastMonth) = oldLastSection.type,
         case .month(let newLastMonth) = newLastSection.type,
         oldLastMonth < newLastMonth {
        vc.calendarView.insertSections(IndexSet(integer: newDataSource.count - 1))
      }

      // Перегружаем
      for (newSectionIndex, newSection) in newDataSource.enumerated() {
        for oldSection in oldDataSource where oldSection.identity == newSection.identity {
          for (newItemIndex, newItem) in newSection.items.enumerated() {
            for oldItem in oldSection.items {
              guard case .day(let newDate, let newIsSelected, let newCompletedTasksCount, let newPlannedTasksCount) = newItem.type else { continue }
              guard case .day(let oldDate, let oldIsSelected, let oldCompletedTasksCount, let oldPlannedTasksCount) = oldItem.type else { continue }
              guard Calendar.current.isDate(newDate, inSameDayAs: oldDate) else { continue }
              if newIsSelected != oldIsSelected
                  || newCompletedTasksCount != oldCompletedTasksCount
                  || newPlannedTasksCount != oldPlannedTasksCount {
                vc.calendarView.reloadItems(at: [IndexPath(item: newItemIndex, section: newSectionIndex)])
              }
            }
          }
        }
      }
    })
  }
}

extension CalendarViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    dataSource.count
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    dataSource[section].items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch dataSource[indexPath.section].type {
    case .month(let startOfMonth):

      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: CalendarCell.reuseID,
        for: indexPath
      ) as? CalendarCell else { return UICollectionViewCell() }

      let item = dataSource[indexPath.section].items[indexPath.item]

      switch item.type {
      case .empty:
        cell.configureAsEmpty()
      case .day(let date, let isSelected, let completedTasksCount, let plannedTasksCount):
        cell.configure(date: date, isSelected: isSelected, completedTasksCount: completedTasksCount, plannedTasksCount: plannedTasksCount)
      }
      return cell
    case .year(let year):
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: CalendarYearCell.reuseID,
        for: indexPath
      ) as? CalendarYearCell else { return UICollectionViewCell() }
      cell.configure(year: year)
      return cell
    }
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

    guard let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: CalendarReusableView.reuseID,
      for: indexPath
    ) as? CalendarReusableView else { return UICollectionReusableView() }

    switch dataSource[indexPath.section].type {
    case .month(let startOfMonth):
      header.label.text = monthFormatter.string(from: startOfMonth)
    case .year:
      header.label.text = nil
    }

    header.label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    header.label.textAlignment = .left
    header.label.text?.firstCharacterUppercased()
    return header
  }
}

extension CalendarViewController: CalendarViewDelegate {

  func appendPastData() {
    viewModel.appendPastData()
  }

  func appendFutureData() {
    viewModel.appendFutureData()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: Sizes.Cells.CalendarCell.width, height: Sizes.Cells.CalendarCell.height)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    Sizes.Views.Calendar.sectionInset
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    CGSize(width: collectionView.bounds.width, height: Sizes.Views.Calendar.headerSizeHeight)
  }

}
