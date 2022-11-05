//
//  DayTaskListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DayTaskListViewController: UIViewController {

  // MARK: - Properties
  let disposeBag = DisposeBag()

  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>!
  var viewModel: DayTaskListViewModel!

  // MARK: - UI Elements
  private let backButton = UIButton(type: .custom)
  private let addTaskButton = UIButton(type: .custom)

  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()

  private let deleteAlertButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Удалить",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
    )

    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()

  private let cancelAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(UIColor(named: "appText")!.withAlphaComponent(0.5), for: .normal)
    return button
  }()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }

  // MARK: - Configure UI
  func configureUI() {
    view.backgroundColor = UIColor(named: "appBackground")

    let headerView = UIView()
    headerView.backgroundColor = UIColor(named: "navigationBarBackground")

    view.addSubview(headerView)
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)

    let titleLabel = UILabel()

    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.text = "Выполненные задачи"

    headerView.addSubview(titleLabel)
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)

    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.imageView?.tintColor = UIColor(named: "appText")

    headerView.addSubview(backButton)
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)

    addTaskButton.setImage(UIImage(named: "plus-custom"), for: .normal)
    addTaskButton.cornerRadius = addTaskButton.bounds.width / 2

    headerView.addSubview(addTaskButton)
    addTaskButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)

    let dividerView = UIView()
    dividerView.backgroundColor = UIColor(named: "navigationBarDividerBackground")

    headerView.addSubview(dividerView)
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,     heightConstant: 1.0)

    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    collectionView.register(TaskListCollectionViewCell.self, forCellWithReuseIdentifier: TaskListCollectionViewCell.reuseID)
    collectionView.register(TaskListCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskListCollectionReusableView.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.layer.masksToBounds = false
    collectionView.backgroundColor = .clear

    view.addSubview(collectionView)
    collectionView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }

  private func configureAlert() {
    view.addSubview(alertBackgroundView)
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

    let alertWindowView = UIView()
    alertWindowView.cornerRadius = 27
    alertWindowView.backgroundColor = UIColor(named: "appBackground")

    alertBackgroundView.addSubview(alertWindowView)
    alertWindowView.anchor(widthConstant: 287, heightConstant: 171)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()

    let alertLabel = UILabel(text: "Удалить задачу?")
    alertLabel.textColor = UIColor(named: "appText")
    alertLabel.textAlignment = .center
    alertLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)

    alertWindowView.addSubview(alertLabel)
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171 / 4)

    alertWindowView.addSubview(deleteAlertButton)
    deleteAlertButton.anchor(widthConstant: 94, heightConstant: 30)
    deleteAlertButton.cornerRadius = 15
    deleteAlertButton.anchorCenterXToSuperview()
    deleteAlertButton.anchorCenterYToSuperview(constant: 15)

    alertWindowView.addSubview(cancelAlertButton)
    cancelAlertButton.anchor(top: deleteAlertButton.bottomAnchor, topConstant: 10)
    cancelAlertButton.anchorCenterXToSuperview()
  }

  // MARK: - Collection View
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
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
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
    section.boundarySupplementaryItems = [header]
    return section
  }

  // MARK: - Bind To
  func bindViewModel() {

    let input = DayTaskListViewModel.Input(
      addTaskButtonClickTrigger: addTaskButton.rx.tap.asDriver(),
      backTaskButtonClickTrigger: backButton.rx.tap.asDriver(),

      deleteAlertButtonClickTrigger: deleteAlertButton.rx.tap.asDriver(),
      cancelAlertButtonClickTrigger: cancelAlertButton.rx.tap.asDriver(),

      selection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.openTask.drive(),
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.alertIsHidden.drive(alertBackgroundView.rx.isHidden),
      outputs.addTaskButtonClick.drive(),
      outputs.backTaskButtonClick.drive(),
      outputs.deleteAlertButtonClick.drive(),
      outputs.cancelAlertButtonClick.drive()
    ]
      .forEach({ $0.disposed(by: disposeBag) })

  }

  // MARK: - Binders  
  func configureDataSource() {
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>(configureCell: { (_, collectionView, indexPath, task) in
      guard
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: TaskListCollectionViewCell.reuseID,
          for: indexPath
        ) as? TaskListCollectionViewCell
      else { return UICollectionViewCell() }
      let cellViewModel = TaskListCollectionViewCellModel(services: self.viewModel.services, task: task)
      cell.viewModel = cellViewModel
      cell.delegate = cellViewModel
      cell.disposeBag = DisposeBag()
      cell.bindViewModel()
      return cell
    }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
      guard let section = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: TaskListCollectionReusableView.reuseID,
        for: indexPath
      ) as? TaskListCollectionReusableView else { return UICollectionReusableView() }
      section.configure(text: dataSource[indexPath.section].header)
      return section
    })

  }

}
