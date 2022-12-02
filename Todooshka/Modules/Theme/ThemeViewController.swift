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
  
  public var viewModel: ThemeViewModel!
  
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
    textField.leftView = spacer
    textField.leftViewMode = .always
    textField.placeholder = "Отказываемся от сахара"
    return textField
  }()
  
  private let addImageButton: UIButton = {
    let button = UIButton(type: .system)
    button.borderColor = .black
    button.borderWidth = 1.0
    button.cornerRadius = 15
    button.setImage(Icon.plus.image, for: .normal)
    button.tintColor = .black
    return button
  }()
  
  private let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.cornerRadius = 15
    textView.font = UIFont.systemFont(ofSize: 12, weight: .thin)
    textView.textAlignment = .center
    return textView
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .systemRed.withAlphaComponent(0.2)
    imageView.isHidden = true
    return imageView
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "Название:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let imageAndDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "Изображение и описание:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let sendThemeForVerificationButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitle("Отправить на проверку", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.borderWidth = 1.0
    button.borderColor = .systemGray.withAlphaComponent(0.3)
    return button
  }()
  
  private let startThemeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitle("Начать курс", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.borderWidth = 1.0
    button.borderColor = .systemGray.withAlphaComponent(0.3)
    return button
  }()
  
  private let typeLabel: UILabel = {
    let label = UILabel()
    label.text = "Тип:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private var typeCollectionView: UICollectionView!
  private var typeDataSource: RxCollectionViewSectionedAnimatedDataSource<ThemeTypeSection>!
  
  private var stepsCollectionView: UICollectionView!
  private var stepsDataSource: RxCollectionViewSectionedAnimatedDataSource<ThemeStepSection>!
  
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
    typeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createTypeCompositionalLayout())
    stepsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createDayCompositionalLayout())
    
    // adding
    view.addSubviews([
      typeLabel,
      nameLabel,
      nameTextField,
      imageAndDescriptionLabel,
      addImageButton,
      imageView,
      descriptionTextView,
      sendThemeForVerificationButton,
      startThemeButton,
      typeCollectionView,
      stepsCollectionView
    ])
    // stepsCollectionView
    stepsCollectionView.alwaysBounceVertical = false
    stepsCollectionView.backgroundColor = .clear
    stepsCollectionView.register(
      ThemeStepCell.self,
      forCellWithReuseIdentifier: ThemeStepCell.reuseID)
    stepsCollectionView.register(
      ThemeStepHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ThemeStepHeader.reuseID)
    
    // typeCollectionView
    typeCollectionView.alwaysBounceVertical = false
    typeCollectionView.backgroundColor = .clear
    typeCollectionView.register(
      ThemeTypeCell.self,
      forCellWithReuseIdentifier: ThemeTypeCell.reuseID)
  }
  
  func configureUI(with mode: OpenViewControllerMode) {
    
    switch mode {
    case .view:
      // imageView
      imageView.anchor(
        top: headerView.bottomAnchor,
        left: view.leftAnchor,
        topConstant: 16,
        leftConstant: 16,
        widthConstant: 150,
        heightConstant: 150
      )
    case .edit:
      // typeLabel
      typeLabel.anchor(
        top: headerView.bottomAnchor,
        left: view.leftAnchor,
        topConstant: 16,
        leftConstant: 16
      )
      // typeCollectionView
      typeCollectionView.anchor(
        top: typeLabel.bottomAnchor,
        left: view.leftAnchor,
        right: view.rightAnchor,
        topConstant: 16,
        leftConstant: 16,
        rightConstant: 16,
        heightConstant: 50
      )
      // nameLabel
      nameLabel.anchor(
        top: typeCollectionView.bottomAnchor,
        left: view.leftAnchor,
        topConstant: 16,
        leftConstant: 16
      )
      // nameTextField
      nameTextField.anchor(
        top: nameLabel.bottomAnchor,
        left: view.leftAnchor,
        right: view.rightAnchor,
        topConstant: 16,
        leftConstant: 16,
        rightConstant: 16,
        heightConstant: 54
      )
      // imageAndDescriptionLabel
      imageAndDescriptionLabel.anchor(
        top: nameTextField.bottomAnchor,
        left: view.leftAnchor,
        topConstant: 16,
        leftConstant: 16
      )
      
      // addImageButton
      addImageButton.anchor(
        top: imageAndDescriptionLabel.bottomAnchor,
        left: view.leftAnchor,
        topConstant: 16,
        leftConstant: 16,
        widthConstant: 150,
        heightConstant: 150
      )
    }
    
    // descriptionTextView
    descriptionTextView.anchor(
      top: mode == .view ? imageView.topAnchor : addImageButton.topAnchor,
      left: mode == .view ? imageView.rightAnchor : addImageButton.rightAnchor,
      bottom: mode == .view ? imageView.bottomAnchor : addImageButton.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      rightConstant: 16
    )

    // startThemeButton
    startThemeButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: 50)
    
    // sendThemeForVerificationButton
    sendThemeForVerificationButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: 50
    )
    
    // collectionView
    stepsCollectionView.anchor(
      top: descriptionTextView.bottomAnchor,
      left: view.leftAnchor,
      bottom: startThemeButton.topAnchor,
      right: view.rightAnchor,
      topConstant: 16,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16
    )
    
    // mode
    switch mode {
    case .edit:
      addImageButton.isHidden = false
      nameTextField.isHidden = false
      descriptionTextView.isEditable = true
      imageView.isHidden = true
      saveButton.isHidden = false
      sendThemeForVerificationButton.isHidden = false
      settingsButton.isHidden = false
      startThemeButton.isHidden = true
    case .view:
      addImageButton.isHidden = true
      nameTextField.isHidden = true
      descriptionTextView.isEditable = false
      imageView.isHidden = false
      saveButton.isHidden = true
      sendThemeForVerificationButton.isHidden = true
      settingsButton.isHidden = true
      startThemeButton.isHidden = false
    }
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    
    let input = ThemeViewModel.Input(
      addImageButtonClickTrigger: addImageButton.rx.tap.asDriver(),
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      daySelection: stepsCollectionView.rx.itemSelected.asDriver(),
      description: descriptionTextView.rx.text.orEmpty.asDriver(),
      name: nameTextField.rx.text.orEmpty.asDriver(),
      saveButtonClickTrigger: saveButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.mode.drive(modeBinder),
      outputs.navigateBack.drive(),
      outputs.openThemeStep.drive(),
      outputs.save.drive(),
      outputs.title.drive(titleLabel.rx.text),
      outputs.themeStepDataSource.drive(stepsCollectionView.rx.items(dataSource: stepsDataSource)),
      outputs.typeDataSource.drive(typeCollectionView.rx.items(dataSource: typeDataSource)),
    ]
      .forEach { $0.disposed(by: disposeBag) }
    
    // init
    nameTextField.insertText(viewModel.theme.name)
    descriptionTextView.insertText(viewModel.theme.description)
  }
  
  var modeBinder: Binder<OpenViewControllerMode> {
    return Binder(self, binding: { vc, mode in
      vc.configureUI(with: mode)
    })
  }
  
  // MARK: - Configure Data Source
  private func configureDataSource() {
    stepsCollectionView.dataSource = nil
    typeCollectionView.dataSource = nil
    
    stepsDataSource = RxCollectionViewSectionedAnimatedDataSource<ThemeStepSection>(
      configureCell: { _, collectionView, indexPath, day in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: ThemeStepCell.reuseID,
          for: indexPath
        ) as? ThemeStepCell else { return UICollectionViewCell() }
        cell.configure(with: day)
        return cell
      }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: ThemeStepHeader.reuseID,
          for: indexPath
        ) as? ThemeStepHeader else { return UICollectionReusableView() }
        header.configure(with: dataSource[indexPath.section])
        return header
      })
    
    typeDataSource = RxCollectionViewSectionedAnimatedDataSource<ThemeTypeSection>(
      configureCell: { _, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: ThemeTypeCell.reuseID,
          for: indexPath
        ) as? ThemeTypeCell else { return UICollectionViewCell() }
        cell.configure(with: item)
        return cell
      })
  }
  
  // MARK: - Type CompositionalLayout
  private func createTypeCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.typeSection()
    }
  }
  
  private func typeSection() -> NSCollectionLayoutSection {
    // item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(Sizes.Cells.ThemeTypeCell.width),
      heightDimension: .absolute(Sizes.Cells.ThemeTypeCell.height))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 5)
    // group
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .estimated(Sizes.Cells.ThemeTypeCell.width),
      heightDimension: .estimated(Sizes.Cells.ThemeTypeCell.height))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    // section
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .continuous
    return section
  }
  
  // MARK: - Setup CollectionView
  private func createDayCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.daySection()
    }
  }
  
  private func daySection() -> NSCollectionLayoutSection {
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
