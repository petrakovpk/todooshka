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
  
  // MARK: - UI Element
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
  
  private let startThemeButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 15
    button.setTitle("Начать курс", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.borderWidth = 1.0
    button.borderColor = .systemGray.withAlphaComponent(0.3)
    return button
  }()
  
  private let stepsLabel: UILabel = {
    let label = UILabel()
    label.text = "Шаги:"
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let addStepButton: UIButton = {
    let button = UIButton(type: .system)
    button.cornerRadius = 5
    button.borderWidth = 1.0
    button.borderColor = .black
    button.setTitle("Добавить шаг", for: .normal)
    button.setTitleColor(.black, for: .normal)
    return button
  }()
  
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
    stepsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // adding
    view.addSubviews([
      nameLabel,
      nameTextField,
      imageAndDescriptionLabel,
      addImageButton,
      imageView,
      descriptionTextView,
      stepsLabel,
      addStepButton,
      stepsCollectionView,
      startThemeButton
    ])
    
    // stepsCollectionView
    stepsCollectionView.alwaysBounceVertical = true
    stepsCollectionView.backgroundColor = .clear
    stepsCollectionView.delegate = self
    stepsCollectionView.register(
      ThemeStepCell.self,
      forCellWithReuseIdentifier: ThemeStepCell.reuseID)
    stepsCollectionView.register(
      ThemeStepHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: ThemeStepHeader.reuseID)
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
      // nameLabel
      nameLabel.anchor(
        top: headerView.bottomAnchor,
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
    
    // stepsLabel
    stepsLabel.anchor(
      top: addImageButton.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 16,
      leftConstant: 16
    )
    
    // addStepButton
    addStepButton.centerYAnchor.constraint(equalTo: stepsLabel.centerYAnchor, constant: 0).isActive = true
    addStepButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16,
      widthConstant: 120,
      heightConstant: 30
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

    // collectionView
    stepsCollectionView.anchor(
      top: stepsLabel.bottomAnchor,
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
      settingsButton.isHidden = false
      startThemeButton.isHidden = true
    case .view:
      addImageButton.isHidden = true
      nameTextField.isHidden = true
      descriptionTextView.isEditable = false
      imageView.isHidden = false
      saveButton.isHidden = true
      settingsButton.isHidden = true
      startThemeButton.isHidden = false
    }
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    
    let input = ThemeViewModel.Input(
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      settingsButtonClickTrigger: settingsButton.rx.tap.asDriver(),
      saveButtonClickTrigger: saveButton.rx.tap.asDriver(),
      name: nameTextField.rx.text.orEmpty.asDriver(),
      addImageButtonClickTrigger: addImageButton.rx.tap.asDriver(),
      description: descriptionTextView.rx.text.orEmpty.asDriver(),
      addStepButtonClickTrigger: addStepButton.rx.tap.asDriver(),
      stepSelection: stepsCollectionView.rx.itemSelected.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      outputs.initData.drive(initBinder),
      outputs.navigateBack.drive(),
      outputs.openSettings.drive(),
      outputs.saveTheme.drive(),
      outputs.title.drive(titleLabel.rx.text),
      outputs.stepsDataSource.drive(stepsCollectionView.rx.items(dataSource: stepsDataSource)),
      outputs.addStep.drive(),
      outputs.openStep.drive(),
    ]
      .forEach { $0.disposed(by: disposeBag) }
    
  }
  
  var initBinder: Binder<Theme> {
    return Binder(self, binding: { vc, theme in
      vc.nameTextField.insertText(theme.name)
      vc.descriptionTextView.insertText(theme.description)
      vc.configureUI(with: theme.status == .draft ? .edit : .view)
    })
  }
  
  // MARK: - Configure Data Source
  private func configureDataSource() {
    stepsCollectionView.dataSource = nil
    
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
  }
}


extension ThemeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: floor((collectionView.bounds.width - 16.0) / 3.0), height: 75)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    UIEdgeInsets.zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    8.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    8.0
  }
}
