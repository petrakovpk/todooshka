//
//  AddThemeViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 10.11.2022.
//


import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class AddThemeViewController: TDViewController {
  
  public var viewModel: AddThemeViewModel!
  
  private let disposeBag = DisposeBag()
  
  private let nameTextField: UITextField = {
    let spacer = UIView()
    spacer.anchor(widthConstant: 16, heightConstant: 54)
    let textField = UITextField()
    textField.leftView = spacer
    textField.leftViewMode = .always
    textField.placeholder = "Название темы"
    textField.cornerRadius = 5.0
    textField.borderWidth = 1.0
    textField.borderColor = .black
    textField.font = UIFont.systemFont(ofSize: 12, weight: .thin)
    return textField
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "Описание"
    return label
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 5.0
    textView.borderWidth = 1.0
    textView.borderColor = .black
    textView.backgroundColor = .clear
    return textView
  }()
  
  private let imageLabel: UILabel = {
    let label = UILabel()
    label.text = "Обложка"
    return label
  }()
  
  private let addImageButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(UIImage(named: "plus")?.template, for: .normal)
    button.tintColor = .black
    button.cornerRadius = 75.0 / 2
    button.borderWidth = 1.0
    button.borderColor = .black
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

  func configureUI() {
    // header
    backButton.isHidden = false
    saveButton.isHidden = false
    hideKeyboardWhenTappedAround()
    
    // collectionView
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
    
    // adding
    view.addSubviews([
      nameTextField,
      descriptionLabel,
      descriptionTextView,
      imageLabel,
      addImageButton,
      collectionView
    ])
    
    // nameLabel
    nameTextField.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 30
    )
    
    // descriptionLabel
    descriptionLabel.anchor(
      top: nameTextField.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    // descriptionTextView
    descriptionTextView.anchor(
      top: descriptionLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 100
    )
    
    // imageLabel
    imageLabel.anchor(
      top: descriptionTextView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    // addImageButton
    addImageButton.anchor(
      top: imageLabel.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16,
      widthConstant: 75,
      heightConstant: 75
    )
    
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
      top: addImageButton.bottomAnchor,
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
    let input = AddThemeViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      selection: collectionView.rx.itemSelected.asDriver()
    )

    let outputs = viewModel.transform(input: input)

    [
      outputs.dataSource.drive(collectionView.rx.items(dataSource: dataSource)),
      outputs.navigateBack.drive(),
      outputs.openThemeDay.drive()
    ]
      .forEach { $0.disposed(by: disposeBag) }
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

