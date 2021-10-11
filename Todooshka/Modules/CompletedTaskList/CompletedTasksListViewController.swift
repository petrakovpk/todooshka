//
//  CompletedTasksListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 24.06.2021.
//


import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CompletedTasksListViewController: UIViewController {
  
  //MARK: - Properties
  let disposeBag = DisposeBag()
  
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>!
  var viewModel: CompletedTasksListViewModel!
  
  //MARK: - UI Elements
  private let backButton = UIButton(type: .custom)
  private let addTaskButton = UIButton(type: .custom)
  
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let deleteAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    button.backgroundColor = UIColor(hexString: "#FF005C")
    let attrString = NSAttributedString(string: "Удалить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let cancelAlertButton: UIButton = {
    let button = UIButton(type: .custom)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(UIColor(named: "appText")!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    configureAlert()
    configureDataSource()
    configureColor()
  }
  
  //MARK: - Configure UI
  func configureUI() {
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
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    collectionView.register(TaskListCollectionViewCell.self, forCellWithReuseIdentifier: TaskListCollectionViewCell.reuseID)
    collectionView.register(TaskListCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TaskListCollectionReusableView.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.layer.masksToBounds = false
    
    view.addSubview(collectionView)
    collectionView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
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
  
  //MARK: - Collection View
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
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
    section.boundarySupplementaryItems = [header]
    return section
  }
  
  //MARK: - Bind To
  func bindTo(with viewModel: CompletedTasksListViewModel) {
    self.viewModel = viewModel
    
    addTaskButton.rx.tap.bind { viewModel.rightBarButtonAddItemClick() }.disposed(by: disposeBag)
    backButton.rx.tap.bind { viewModel.leftBarButtonBackItemClick() }.disposed(by: disposeBag)
    
    deleteAlertButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.alertDeleteButtonClicked() }.disposed(by: disposeBag)
    cancelAlertButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.alertCancelButtonClicked() }.disposed(by: disposeBag)
    
    viewModel.showAlert.bind{ [weak self] showAlert in
      guard let self = self else { return }
      self.alertBackgroundView.isHidden = !showAlert
    }.disposed(by: disposeBag)
  }
  
  func configureDataSource() {
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskListSectionModel>(configureCell: { [weak self] (_, collectionView, indexPath, task) in
      guard let self = self else { return UICollectionViewCell() }
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskListCollectionViewCell.reuseID, for: indexPath) as! TaskListCollectionViewCell
      let cellViewModel = TaskListCollectionViewCellModel(services: self.viewModel.services, task: task)
      cell.bindToViewModel(viewModel: cellViewModel)
      return cell
    }, configureSupplementaryView: { dataSource , collectionView, kind, indexPath in
      let section = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskListCollectionReusableView.reuseID, for: indexPath) as! TaskListCollectionReusableView
      section.configure(text: dataSource[indexPath.section].header)
      return section
    })
    
    viewModel.dataSource.asDriver()
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    collectionView.rx.itemSelected.bind { self.viewModel.openTask(indexPath: $0) }.disposed(by: disposeBag)
  }
  
}
