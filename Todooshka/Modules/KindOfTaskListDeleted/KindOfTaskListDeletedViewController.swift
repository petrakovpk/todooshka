//
//  KindOfTaskListDeletedViewController.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 14.09.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class KindOfTaskListDeletedViewController: TDViewController {
  
  //MARK: - Properties
  var collectionView: UICollectionView!
  var dataSource: RxCollectionViewSectionedAnimatedDataSource<KindOfTaskListSection>!
  let disposeBag = DisposeBag()
  var viewModel: KindOfTaskListDeletedViewModel!
  
  //MARK: - UI Elements
  private let alertBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.isHidden = true
    return view
  }()
  
  private let alertDeleteButton: UIButton = {
    let attrString = NSAttributedString(string: "Удалить", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    let button = UIButton(type: .system)
    button.backgroundColor = Theme.Buttons.AlertRoseButton.Background
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let alertCancelButton: UIButton = {
    let button = UIButton(type: .system)
    let attrString = NSAttributedString(string: "Отмена", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)])
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Theme.App.text!.withAlphaComponent(0.5) , for: .normal)
    return button
  }()
  
  private let alertWindowView = UIView()
  private let alertLabel = UILabel(text: "Удалить ВСЕ задачи?")
  
  //MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureAlert()
    configureDataSource()
    bindViewModel()
  }
  
  //MARK: - Configure UI
  func configureUI() {
    
    // settings
    titleLabel.text = "Удаленные типы"
    removeAllButton.isHidden = false
    
    // collection view
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubview(collectionView)

    // view
    view.backgroundColor = Theme.App.background
    
    // collectionView
    collectionView.register(KindOfTaskListCell.self, forCellWithReuseIdentifier: KindOfTaskListCell.reuseID)
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
    alertWindowView.addSubview(alertDeleteButton)
    alertWindowView.addSubview(alertCancelButton)
    
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
    alertDeleteButton.anchor(widthConstant: 94, heightConstant: 30)
    alertDeleteButton.cornerRadius = 15
    alertDeleteButton.anchorCenterXToSuperview()
    alertDeleteButton.anchorCenterYToSuperview(constant: 15)
    
    // cancelAlertButton
    alertCancelButton.anchor(top: alertDeleteButton.bottomAnchor, topConstant: 10)
    alertCancelButton.anchorCenterXToSuperview()
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
  func bindViewModel() {

    let input = KindOfTaskListDeletedViewModel.Input(
      alertCancelButtonClickTrigger: alertCancelButton.rx.tap.asDriver(),
      alertDeleteButtonClickTrigger: alertDeleteButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      removeAllButtonClickTrigger: removeAllButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.hideAlert.drive(hideAlertBinder),
      outputs.navigateBack.drive(),
      outputs.removeAll.drive(),
      outputs.repeatKindOfTask.drive(),
      outputs.showAlert.drive(showAlertBinder),
    ]
      .forEach({ $0.disposed(by: disposeBag) })
  }
  
  // MARK: - Binders
  var hideAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertBackgroundView.isHidden = true
    })
  }
  
  var showAlertBinder: Binder<Void> {
    return Binder(self, binding: { (vc, _) in
      vc.alertBackgroundView.isHidden = false
    })
  }
  
  func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<KindOfTaskListSection>(configureCell: { (_, collectionView, indexPath, kindOfTask) in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KindOfTaskListCell.reuseID, for: indexPath) as! KindOfTaskListCell
      cell.configure(with: kindOfTask, mode: .WithRepeatButton)
      cell.repeatButton.rx.tap.map{ _ -> IndexPath in indexPath }.asDriver(onErrorJustReturn: nil).drive(self.repeatButtonBinder).disposed(by: cell.disposeBag)
      return cell
    })
  }
  
  var repeatButtonBinder: Binder<IndexPath?> {
    return Binder(self, binding: { (vc, indexPath) in
      guard let indexPath = indexPath else { return }
      self.viewModel.repeatKindOfTask(indexPath: indexPath)
    })
  }
}

