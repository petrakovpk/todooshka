//
//  ThemeViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class ThemeViewController: TDViewController {
  
  // MARK: - MVVM
  public var viewModel: ThemeViewModel!
  
  // MARK: - RX Elements
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Elements
  private let nameTextField: UITextField = {
    let spacer = UIView()
    spacer.anchor(widthConstant: 16, heightConstant: 54)
    let textField = UITextField()
    textField.borderWidth = 1.0
    textField.borderColor = .black
    textField.cornerRadius = 5.0
    textField.font = UIFont.systemFont(ofSize: 12, weight: .thin)
    textField.isHidden = true
    textField.leftView = spacer
    textField.leftViewMode = .always
    textField.placeholder = "Название темы"
    return textField
  }()
  
  private let addImageButton: UIButton = {
    let button = UIButton(type: .system)
    button.borderColor = .black
    button.borderWidth = 1.0
    button.cornerRadius = 15
    button.setImage(UIImage(named: "plus"), for: .normal)
    button.tintColor = .black
    return button
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .systemRed.withAlphaComponent(0.2)
    imageView.isHidden = true
    return imageView
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 15
    textView.font = UIFont.systemFont(ofSize: 12, weight: .thin)
    textView.text = "bla bla bla"
    textView.textAlignment = .center
    return textView
  }()
  
  private let startButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitle("Начать курс", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.borderWidth = 1.0
    button.borderColor = .systemGray.withAlphaComponent(0.3)
    return button
  }()
  
  private var collectionView: UICollectionView!
  private var dataSource: RxCollectionViewSectionedAnimatedDataSource<ThemeDaySection>!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureDataSource()
    bindViewModel()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    descriptionTextView.centerVerticalText()
  }
  
  func configureUI() {
    // header
    backButton.isHidden = false
    hideKeyboardWhenTappedAround()
    
    // collectionView
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubviews([
      nameTextField,
      addImageButton,
      imageView,
      descriptionTextView,
      startButton,
      collectionView
    ])
    
    // nameTextField
    nameTextField.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 30
    )
    
    // addImageButton
    addImageButton.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 150,
      heightConstant: 150
    )
    
    // imageView
    imageView.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 150,
      heightConstant: 150
    )
    
    // descriptionTextView
    descriptionTextView.anchor(
      top: headerView.bottomAnchor,
      left: imageView.rightAnchor,
      bottom: imageView.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16)
    
    // startButton
    startButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: 50)
    
    // collectionView
    collectionView.alwaysBounceVertical = false
    collectionView.backgroundColor = .clear
    collectionView.register(
      ThemeDayCell.self,
      forCellWithReuseIdentifier: ThemeDayCell.reuseID)
    collectionView.register(
      ThemeDayHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ThemeDayHeader.reuseID)
    collectionView.anchor(
      top: imageView.bottomAnchor,
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    let input = ThemeViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.name.drive(titleLabel.rx.text),
      outputs.navigateBack.drive(),
      outputs.openThemeDay.drive(),
      outputs.openViewControllerMode.drive(openViewControllerModeBinder)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  var openViewControllerModeBinder: Binder<OpenViewControllerMode> {
    return Binder(self, binding: { vc, mode in
      switch mode {
      case .edit:
        vc.addImageButton.isHidden = false
        vc.descriptionTextView.isEditable = true
        vc.imageView.isHidden = true
        vc.saveButton.isHidden = false
      case .view:
        vc.addImageButton.isHidden = true
        vc.descriptionTextView.isEditable = false
        vc.imageView.isHidden = false
        vc.saveButton.isHidden = true
      }
    })
  }
  
  // MARK: - Configure Data Source
  private func configureDataSource() {
    collectionView.dataSource = nil
    dataSource = RxCollectionViewSectionedAnimatedDataSource<ThemeDaySection>(
      configureCell: { _, collectionView, indexPath, day in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: ThemeDayCell.reuseID,
          for: indexPath
        ) as? ThemeDayCell else { return UICollectionViewCell() }
        cell.configure(with: day)
        return cell
      }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: ThemeDayHeader.reuseID,
          for: indexPath
        ) as? ThemeDayHeader else { return UICollectionReusableView() }
        header.configure(with: dataSource[indexPath.section])
        return header
      })
  }
  
  
  // MARK: - Setup CollectionView
  private func createCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    // item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .estimated(50.0),
      heightDimension: .estimated(50.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    // group
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(50.0))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(5.0)
    // header
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30.0))
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top )
    // section
    let section = NSCollectionLayoutSection(group: group)
    section.boundarySupplementaryItems = [header]
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 5, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
}
