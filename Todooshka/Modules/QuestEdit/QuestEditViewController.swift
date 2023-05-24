//
//  DealViewController.swift
//  DragoDo
//
//  Created by Pavel Petakov on 07.11.2022.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class QuestEditViewController: TDViewController {
  public var viewModel: QuestEditViewModel!
  
  private let disposeBag = DisposeBag()
  
  private let titleTextField: TDTaskTextField = {
    let textField = TDTaskTextField(placeholder: "Что надо сделать?")
    let spacer = UIView()
    textField.returnKeyType = .done
    textField.rightView = spacer
    textField.rightViewMode = .always
    spacer.anchor(
      widthConstant: Sizes.TextFields.TDTaskTextField.heightConstant,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant)
    return textField
  }()
  
  private let titleSaveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.tickSquare.image.template, for: .normal)
    button.tintColor = .black
    return button
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel(text: "Подробное описание:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let descriptionTextView: PlaceholderTextView = {
    let textView = PlaceholderTextView()
    textView.borderWidth = 0
    textView.backgroundColor = .clear
    textView.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    textView.placeholder = "Рецепт или набор упраждений"
    return textView
  }()
  
  private let descriptionSaveButton: UIButton = {
      let button = UIButton(type: .system)
      button.setImage(Icon.tickSquare.image.template, for: .normal)
      button.tintColor = .black
      return button
    }()
  
  private let coverLabel: UILabel = {
    let label = UILabel(text: "Обложка:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let editCoverButton: UIButton = {
    let attrString = NSAttributedString(
      string: "Редактировать обложку",
      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)])
    let button = UIButton(type: .system)
    button.setAttributedTitle(attrString, for: .normal)
    button.setTitleColor(Style.App.text, for: .normal)
    button.cornerRadius = 8
    button.borderWidth = 1.0
    button.borderColor = Style.App.text
    return button
  }()
  
  private let coverImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.cornerRadius = 12
    imageView.backgroundColor = Palette.SingleColors.Portage.withAlphaComponent(0.3)
    return imageView
  }()
  
  private let coverTextLabelContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = Palette.SingleColors.Portage
    return view
  }()
  
  private let coverTextLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 10, weight: .light)
    label.textAlignment = .center
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    return label
  }()
  
  private let saveDescriptionSaveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(Icon.tickSquare.image.template, for: .normal)
    button.tintColor = .black
    return button
  }()
  
  private let dividerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.31, green: 0.329, blue: 0.549, alpha: 1)
    return view
  }()
  
  private let questImagesLabel: UILabel = {
    let label = UILabel(text: "Фото от автора:")
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .left
    return label
  }()
  
  private let publishButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Опубликовать", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = Palette.SingleColors.Rose
    button.cornerRadius = 8
    return button
  }()
  
  private var questImagesCollectionView: UICollectionView!
  private var questImagesDataSource: RxCollectionViewSectionedAnimatedDataSource<QuestImageSection>!
  
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureQuestImagesDataSource()
    bindViewModel()
  }
  
  func configureUI() {
    backButton.isHidden = false
    moreButton.isHidden = false
    
    titleLabel.text = "Задание"
    hideKeyboardWhenTappedAround()
    
    questImagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: authorExamplesCompositionalLayout())
    questImagesCollectionView.backgroundColor = .clear
    questImagesCollectionView.register(QuestImageCell.self, forCellWithReuseIdentifier: QuestImageCell.reuseID)
    
    view.addSubviews([
      titleTextField,
      titleSaveButton,
      descriptionLabel,
      descriptionTextView,
      descriptionSaveButton,
      dividerView,
      questImagesLabel,
      questImagesCollectionView,
      coverLabel,
      editCoverButton,
      coverImageView,
      publishButton
    ])
    
    coverImageView.addSubviews([
      coverTextLabelContainerView,
      coverTextLabel
    ])
    
    titleTextField.anchor(
      top: headerView.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextFields.TDTaskTextField.heightConstant
    )
    
    titleSaveButton.centerYAnchor.constraint(equalTo: titleTextField.centerYAnchor).isActive = true
    titleSaveButton.anchor(
      right: titleTextField.rightAnchor,
      widthConstant: 24,
      heightConstant: 24
    )
    
    descriptionLabel.anchor(
      top: titleTextField.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 12,
      leftConstant: 16,
      rightConstant: 16
    )
    
    descriptionTextView.anchor(
      top: descriptionLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 4,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.TextViews.TaskDescriptionTextView.height
    )
    
    descriptionSaveButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor).isActive = true
    descriptionSaveButton.anchor(
      right: view.rightAnchor,
      rightConstant: 16,
      widthConstant: 24,
      heightConstant: 24
    )
    
    dividerView.anchor(
      left: descriptionTextView.leftAnchor,
      bottom: descriptionTextView.bottomAnchor,
      right: descriptionTextView.rightAnchor,
      heightConstant: 1.0
    )
    
    questImagesLabel.anchor(
      top: descriptionTextView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 8,
      leftConstant: 16
    )
    
    questImagesCollectionView.anchor(
      top: questImagesLabel.bottomAnchor,
      left: view.leftAnchor,
      right: view.rightAnchor,
      topConstant: 8,
      leftConstant: 16,
      rightConstant: 16,
      heightConstant: 200
    )
    
    editCoverButton.anchor(
      top: questImagesCollectionView.bottomAnchor,
      left: view.leftAnchor,
      topConstant: 12,
      leftConstant: 16,
      widthConstant: 185,
      heightConstant: 30
    )
    
    publishButton.anchor(
      left: view.leftAnchor,
      bottom: view.safeAreaLayoutGuide.bottomAnchor,
      right: view.rightAnchor,
      leftConstant: 16,
      bottomConstant: 16,
      rightConstant: 16,
      heightConstant: Sizes.Buttons.AppButton.height
    )
    
  }
  
  private func authorExamplesCompositionalLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
      return self.section()
    }
  }
  
  private func section() -> NSCollectionLayoutSection {
    let itemWidth = UIScreen.main.bounds.width / 3
    let itemHeight = itemWidth * 1.5
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(itemHeight))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3) // set item count per row here
    group.interItemSpacing = .fixed(5)  // set inter-item spacing here
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.interGroupSpacing = 5  // set inter-group spacing here
    section.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    return section
  }
  
  // MARK: - Bind View Model
  func bindViewModel() {
    titleTextField.insertText(viewModel.quest.name)
    descriptionTextView.insertText(viewModel.quest.description)
    
    let input = QuestEditViewModel.Input(
      // header
      backButtonClickTrigger: backButton.rx.tap.asDriver(),
      moreButtonClickTrigger: moreButton.rx.tap.asDriver(),
      // title
      titleTextField: titleTextField.rx.text.orEmpty.asDriver(),
      titleSaveButtonClickTrigger: titleSaveButton.rx.tap.asDriver(),
      // descriptionTextView
      descriptionTextView: descriptionTextView.rx.text.orEmpty.asDriver(),
      descriptionSaveButtonClickTrigger: descriptionSaveButton.rx.tap.asDriver(),
      // author photo
      authorImagesSelection: questImagesCollectionView.rx.itemSelected.asDriver(),
      // cover
      previewButtonClickTrigger: editCoverButton.rx.tap.asDriver(),
      // publish
      publishButtonClickTrigger: publishButton.rx.tap.asDriver()
    )
    
    let outputs = viewModel.transform(input: input)
    
    [
      // header
      outputs.navigateBack.drive(),
      outputs.navigateToSettings.drive(),
      outputs.navigateToPreview.drive(),
      // title
      outputs.titleTextSaveButtonIsHidden.drive(titleSaveButton.rx.isHidden),
      // description
      outputs.descriptionSaveButtonIsHidden.drive(descriptionSaveButton.rx.isHidden),
      // author images
      outputs.authorImagesSections.drive(questImagesCollectionView.rx.items(dataSource: questImagesDataSource)),
      outputs.authorImagesAddImage.drive(),
      outputs.authorImagesOpenGallery.drive(),
      // save
      outputs.saveTitle.drive(),
      outputs.saveDescription.drive(),
      // bottom buttons
      outputs.publishButtonIsEnabled.drive(publishButtonIsEnabledBinder)
    ]
      .forEach { $0.disposed(by: disposeBag) }
  }
  
  var publishButtonIsEnabledBinder: Binder<Bool> {
    return Binder(self, binding: { vc, isEnabled in
      if isEnabled {
        vc.publishButton.isEnabled = true
        vc.publishButton.backgroundColor = Palette.SingleColors.Rose
      } else {
        vc.publishButton.isEnabled = false
        vc.publishButton.backgroundColor = Palette.SingleColors.Rose.withAlphaComponent(0.2)
      }
    })
  }
  
  // MARK: - Configure Data Source
  private func configureQuestImagesDataSource() {
    questImagesCollectionView.dataSource = nil
    
    questImagesDataSource = RxCollectionViewSectionedAnimatedDataSource<QuestImageSection>(
      configureCell: { _, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestImageCell.reuseID, for: indexPath) as! QuestImageCell
        cell.configure(with: item)
        return cell
      })
  }
}
