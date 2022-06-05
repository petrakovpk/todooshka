//
//  DeletedTaskTypesListViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.09.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DeletedTaskTypesListViewController: UIViewController {
  
  //MARK: - Properties
  let disposeBag = DisposeBag()
  
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>!
  var viewModel: DeletedTaskTypesListViewModel!
  
  //MARK: - UI Elements
  private let backButton = UIButton(type: .custom)
  private let removeAllButton = UIButton(type: .custom)
  
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
    button.setTitleColor(Theme.App.text!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  private let headerView = UIView()
  private let titleLabel = UILabel()
  private let dividerView = UIView()
  private let alertWindowView = UIView()
  private let alertLabel = UILabel(text: "Удалить ВСЕ задачи?")
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    configureUI()
    configureAlert()
    configureDataSource()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(headerView)
    view.addSubview(collectionView)
    headerView.addSubview(titleLabel)
    headerView.addSubview(backButton)
    headerView.addSubview(removeAllButton)
    headerView.addSubview(dividerView)
    
    // view
    view.backgroundColor = Theme.App.background
    
    // headerView
    headerView.backgroundColor = UIColor(named: "navigationHeaderViewBackgroundColor")
    headerView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, heightConstant: isModal ? 55 : 96)
    
    // titleLabel
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    titleLabel.text = "Удаленные типы"
    titleLabel.anchorCenterXToSuperview()
    titleLabel.anchor(bottom: headerView.bottomAnchor, bottomConstant: 20)
    
    // backButton
    backButton.setImage(UIImage(named: "arrow-left")?.template, for: .normal)
    backButton.imageView?.tintColor = Theme.App.text
    backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // removeAllButton
    removeAllButton.setImage(UIImage(named: "trash-custom")?.original, for: .normal)
    removeAllButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, widthConstant: UIScreen.main.bounds.width / 6)
    
    // dividerView
    dividerView.backgroundColor = UIColor(named: "navigationDividerViewBackgroundColor")
    dividerView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor,  heightConstant: 1.0)
    
    // collectionView
    collectionView.register(TaskTypeListCollectionViewCell.self, forCellWithReuseIdentifier: TaskTypeListCollectionViewCell.reuseID)
    collectionView.alwaysBounceVertical = true
    collectionView.backgroundColor = .clear
    collectionView.layer.masksToBounds = false
    collectionView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16)
  }
  
  private func configureAlert() {
    
    // adding
    view.addSubview(alertBackgroundView)
    alertBackgroundView.addSubview(alertWindowView)
    alertWindowView.addSubview(alertLabel)
    alertWindowView.addSubview(deleteAlertButton)
    alertWindowView.addSubview(cancelAlertButton)
    
    // alertBackgroundView
    alertBackgroundView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    
    // alertWindowView
    alertWindowView.cornerRadius = 27
    alertWindowView.backgroundColor = Theme.App.background
    alertWindowView.anchor(widthConstant: 287, heightConstant: 171)
    alertWindowView.anchorCenterXToSuperview()
    alertWindowView.anchorCenterYToSuperview()
    
    // alertLabel
    alertLabel.textColor = Theme.App.text
    alertLabel.textAlignment = .center
    alertLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    alertLabel.anchorCenterXToSuperview()
    alertLabel.anchorCenterYToSuperview(constant: -1 * 171 / 4)
    
    // deleteAlertButton
    deleteAlertButton.anchor(widthConstant: 94, heightConstant: 30)
    deleteAlertButton.cornerRadius = 15
    deleteAlertButton.anchorCenterXToSuperview()
    deleteAlertButton.anchorCenterYToSuperview(constant: 15)
    
    // cancelAlertButton
    cancelAlertButton.anchor(top: deleteAlertButton.bottomAnchor, topConstant: 10)
    cancelAlertButton.anchorCenterXToSuperview()
  }
  
  //MARK: - Setup Collection View
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
  func bindTo(with viewModel: DeletedTaskTypesListViewModel) {
    self.viewModel = viewModel
    
    backButton.rx.tap.bind { viewModel.leftBarButtonBackItemClick() }.disposed(by: disposeBag)
    removeAllButton.rx.tapGesture().when(.recognized).bind { _ in viewModel.removeAllTaskTypesButtonClick() }.disposed(by: disposeBag)
    deleteAlertButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.alertDeleteButtonClicked() }.disposed(by: disposeBag)
    cancelAlertButton.rx.tapGesture().when(.recognized).bind{ _ in viewModel.alertCancelButtonClicked() }.disposed(by: disposeBag)
    
    viewModel.showAlert.bind{ [weak self] showAlert in
      guard let self = self else { return }
      self.alertBackgroundView.isHidden = !showAlert
    }.disposed(by: disposeBag)
  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<TaskTypeListSectionModel>(configureCell: { (_, collectionView, indexPath, type) in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeListCollectionViewCell.reuseID, for: indexPath) as! TaskTypeListCollectionViewCell
      let cellViewModel = TaskTypeListCollectionViewCellModel(services: self.viewModel.services, type: type)
      cell.viewModel = cellViewModel
      return cell
    })
    
    viewModel.dataSource.asDriver()
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}

